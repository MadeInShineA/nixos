#!/usr/bin/env bash

# nmcli WireGuard abstraction layer for Waybar
# Usage: ./wireguard.sh [short|menu|toggle NAME]

set -uo pipefail

# --- Configuration ---
ICON_ACTIVE=""
ICON_INACTIVE=""
WAYBAR_SIGNAL="SIGRTMIN+10"

# --- Checks ---
if ! command -v nmcli >/dev/null 2>&1; then
    echo "{\"text\": \"err: no nmcli\", \"class\": \"wg-error\"}"
    exit 1
fi

# --- Helper Functions ---

json_escape() {
    local str="$1"
    str="${str//\\/\\\\}"
    str="${str//\"/\\\"}"
    str="${str//$'\n'/\\n}"
    str="${str//$'\r'/\\r}"
    str="${str//$'\t'/\\t}"
    echo -n "$str"
}

strip_emoji() {
    local str="$1"
    echo "$str" | sed 's/^[✅⭕🔴] *//'
}

get_active_wg() {
    nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | \
        grep ":wireguard$" | \
        cut -d: -f1 || true
}

get_all_wg() {
    nmcli -t -f NAME,TYPE connection show 2>/dev/null | \
        grep ":wireguard$" | \
        cut -d: -f1 || true
}

is_active() {
    local conn="$1"
    nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | \
        grep -q "^${conn}:wireguard$"
}

wait_for_state() {
    local conn="$1"
    local target="$2"
    local max=10
    local i=0

    while [[ $i -lt $max ]]; do
        if [[ "$target" == "up" ]]; then
            is_active "$conn" && return 0
        else
            ! is_active "$conn" && return 0
        fi
        sleep 1
        i=$((i + 1))
    done
    return 0
}

# Send refresh signal to Waybar
refresh_waybar() {
    pkill -"$WAYBAR_SIGNAL" waybar 2>/dev/null || true
}

# --- Main Logic ---

nargs=${#}
mode="status"
target_conn=""

if [[ $nargs -eq 0 ]]; then
    mode="status"
elif [[ $nargs -eq 1 ]]; then
    case "$1" in
        menu) mode="menu" ;;
        short) mode="status_short" ;;
        *) echo "{\"text\": \"err: unknown arg\", \"class\": \"wg-error\"}"; exit 1 ;;
    esac
elif [[ $nargs -eq 2 ]]; then
    if [[ "$1" == "toggle" ]]; then
        mode="toggle"
        target_conn="$2"
    else
        echo "{\"text\": \"err: invalid args\", \"class\": \"wg-error\"}"; exit 1
    fi
else
    echo "{\"text\": \"err: too many args\", \"class\": \"wg-error\"}"; exit 1
fi

# --- Modes ---

if [[ "$mode" == "menu" ]]; then
    mapfile -t active < <(get_active_wg)
    mapfile -t all < <(get_all_wg)

    count_active=0
    for c in "${active[@]}"; do
        [[ -n "$c" ]] && count_active=$((count_active + 1))
    done

    if [[ ${#all[@]} -eq 0 ]] || [[ -z "${all[0]:-}" ]]; then
        echo "No WireGuard connections found"
    else
        for c in "${active[@]}"; do
            [[ -n "$c" ]] && echo "✅ $c"
        done

        for c in "${all[@]}"; do
            if [[ -n "$c" ]]; then
                if ! is_active "$c"; then
                    echo "⭕ $c"
                fi
            fi
        done

        [[ $count_active -gt 0 ]] && echo "🔴 Disconnect All"
    fi

elif [[ "$mode" == "toggle" ]]; then
    # Strip emoji from target connection name
    target_conn=$(strip_emoji "$target_conn")

    # Get fresh state for toggle
    mapfile -t active < <(get_active_wg)
    mapfile -t all < <(get_all_wg)

    # Handle Disconnect All
    if [[ "$target_conn" == "Disconnect All" ]]; then
        # Disconnect each connection and wait for it
        for c in "${active[@]}"; do
            if [[ -n "$c" ]]; then
                nmcli connection down "$c" 2>/dev/null || true
                wait_for_state "$c" "down"
            fi
        done

        # Refresh Waybar after all are disconnected
        refresh_waybar
        exit 0
    fi

    # Handle Individual Toggle
    found="no"

    # Check if active → toggle OFF (disconnect)
    for c in "${active[@]}"; do
        if [[ "$c" == "$target_conn" ]]; then
            nmcli connection down "$target_conn" 2>/dev/null || true
            wait_for_state "$target_conn" "down"
            found="yes"
            break
        fi
    done

    # Check if inactive → toggle ON (connect)
    if [[ "$found" == "no" ]]; then
        for c in "${all[@]}"; do
            if [[ "$c" == "$target_conn" ]]; then
                nmcli connection up "$target_conn" 2>/dev/null || true
                wait_for_state "$target_conn" "up"
                found="yes"
                break
            fi
        done
    fi

    if [[ "$found" == "no" ]]; then
        echo "err: connection '$target_conn' not found"
        exit 1
    fi

    refresh_waybar

elif [[ "$mode" == "status" || "$mode" == "status_short" ]]; then
    mapfile -t active < <(get_active_wg)

    count_active=0
    for c in "${active[@]}"; do
        [[ -n "$c" ]] && count_active=$((count_active + 1))
    done

    text=""
    tooltip=""
    class="wg-inactive"
    icon="$ICON_INACTIVE"

    if [[ $count_active -gt 0 ]]; then
        class="wg-active"
        icon="$ICON_ACTIVE"
        text="$icon $count_active"

        for c in "${active[@]}"; do
            [[ -z "$c" ]] && continue
            if [[ "$mode" == "status" ]]; then
                ip=$(nmcli -g ipv4.addresses connection show "$c" 2>/dev/null || echo "no-ip")
                tooltip="${tooltip}${c}: ${ip}"
            else
                tooltip="${tooltip}${c}"
            fi
        done
    else
        text="$icon Off"
        tooltip="No active WireGuard connections"
    fi

    text_esc=$(json_escape "$text")
    tooltip_esc=$(json_escape "$tooltip")
    class_esc=$(json_escape "$class")

    echo "{\"text\": \"$text_esc\", \"tooltip\": \"$tooltip_esc\", \"class\": \"$class_esc\"}"
fi
