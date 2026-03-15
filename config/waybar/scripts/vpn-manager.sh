#!/usr/bin/env bash

# VPN Manager for Waybar - WireGuard + Tailscale + Mullvad
# Usage: ./vpn-manager.sh [short|menu|toggle TYPE:NAME]

set -uo pipefail

# --- Configuration ---
readonly ICON_ACTIVE=""
readonly ICON_INACTIVE=""
readonly WAYBAR_SIGNAL="SIGRTMIN+10"

# --- Checks ---
command -v nmcli >/dev/null 2>&1 || { echo "{\"text\": \"err: no nmcli\", \"class\": \"vpn-error\"}"; exit 1; }

HAS_TAILSCALE="false"
command -v tailscale >/dev/null 2>&1 && HAS_TAILSCALE="true"

HAS_MULLVAD="false"
command -v mullvad >/dev/null 2>&1 && HAS_MULLVAD="true"

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
    echo "$1" | sed 's/^[✅⭕🔴⚠️⚪] *//' | sed 's/ *([^)]*)$//' | xargs
}

is_mullvad_interface() {
    [[ "$1" == *"wg"* && "$1" == *"mullvad"* ]]
}

# --- WireGuard Functions ---

get_active_wg() {
    nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | \
        grep ":wireguard$" | cut -d: -f1 | \
        while read -r conn; do
            is_mullvad_interface "$conn" || echo "$conn"
        done
}

get_all_wg() {
    nmcli -t -f NAME,TYPE connection show 2>/dev/null | \
        grep ":wireguard$" | cut -d: -f1 | \
        while read -r conn; do
            is_mullvad_interface "$conn" || echo "$conn"
        done
}

is_wg_active() {
    ! is_mullvad_interface "$1" && \
    nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | \
        grep -q "^${1}:wireguard$"
}

# --- Tailscale Functions ---

is_ts_active() {
    [[ "$HAS_TAILSCALE" == "true" ]] && tailscale status --json 2>/dev/null | grep -q '"BackendState": "Running"'
}

get_ts_ip() {
    if [[ "$HAS_TAILSCALE" == "true" ]]; then
        tailscale ip -4 2>/dev/null | head -1 || echo "no-ip"
    else
        echo "no-ip"
    fi
}

# --- Mullvad Functions ---

is_mv_active() {
    [[ "$HAS_MULLVAD" == "true" ]] && mullvad status 2>/dev/null | grep -q "Connected"
}

get_mv_ip() {
    if [[ "$HAS_MULLVAD" != "true" ]]; then
        echo "no-ip"
        return
    fi

    local ip
    # Get IPv4
    ip=$(mullvad status 2>/dev/null | grep "IPv4" | sed 's/.*IPv4:[[:space:]]*//' | tr -d '\r\n ' | xargs)

    # Fallback to IPv6
    if [[ -z "$ip" ]]; then
        ip=$(mullvad status 2>/dev/null | grep "IPv6" | sed 's/.*IPv6:[[:space:]]*//' | tr -d '\r\n ' | xargs)
    fi

    [[ -z "$ip" ]] && ip="no-ip"
    echo "$ip"
}

# --- Waybar Refresh ---

refresh_waybar() {
    pkill -"$WAYBAR_SIGNAL" waybar 2>/dev/null || true
}

# --- Wait for State Change ---

wait_for_state() {
    local type="$1" target="$2" conn="$3" max=20 i=0

    while [[ $i -lt $max ]]; do
        case "$type" in
            wg)
                if [[ "$target" == "up" ]]; then
                    is_wg_active "$conn" && return 0
                else
                    ! is_wg_active "$conn" && return 0
                fi
                ;;
            ts)
                if [[ "$target" == "up" ]]; then
                    is_ts_active && return 0
                else
                    ! is_ts_active && return 0
                fi
                ;;
            mv)
                if [[ "$target" == "up" ]]; then
                    is_mv_active && return 0
                else
                    ! is_mv_active && return 0
                fi
                ;;
        esac
        sleep 1
        ((i++))
    done
}

# --- Main Logic ---

mode="status"
target_type=""
target_conn=""

case $# in
    0) mode="status" ;;
    1)
        case "$1" in
            menu) mode="menu" ;;
            short) mode="status_short" ;;
            *) echo "{\"text\": \"err: unknown arg\", \"class\": \"vpn-error\"}"; exit 1 ;;
        esac
        ;;
    2)
        [[ "$1" == "toggle" ]] || { echo "{\"text\": \"err: invalid args\", \"class\": \"vpn-error\"}"; exit 1; }
        mode="toggle"
        target_conn=$(strip_emoji "$2")

        if [[ "$target_conn" =~ ^(wg|ts|mv):(.+)$ ]]; then
            target_type="${BASH_REMATCH[1]}"
            target_conn="${BASH_REMATCH[2]}"
        elif [[ "$target_conn" == "tailscale" ]]; then
            target_type="ts"
        elif [[ "$target_conn" == "mullvad" ]]; then
            target_type="mv"
        else
            target_type="wg"
        fi
        ;;
    *) echo "{\"text\": \"err: too many args\", \"class\": \"vpn-error\"}"; exit 1 ;;
esac

# --- Menu Mode ---

if [[ "$mode" == "menu" ]]; then
    mapfile -t active_wg < <(get_active_wg)
    mapfile -t all_wg < <(get_all_wg)

    any_active="false"

    for c in "${active_wg[@]}"; do
        [[ -n "$c" ]] && echo "✅ wg:$c" && any_active="true"
    done
    for c in "${all_wg[@]}"; do
        [[ -n "$c" ]] && ! is_wg_active "$c" && echo "⭕ wg:$c"
    done

    nmcli -t -f NAME,TYPE connection show 2>/dev/null | grep ":wireguard$" | cut -d: -f1 | \
    while read -r conn; do
        is_mullvad_interface "$conn" && echo "⚪ wg:$conn (managed by mullvad)"
    done

    if [[ "$HAS_TAILSCALE" == "true" ]]; then
        if is_ts_active; then
            echo "✅ tailscale"
            any_active="true"
        else
            echo "⭕ tailscale"
        fi
    fi

    if [[ "$HAS_MULLVAD" == "true" ]]; then
        if is_mv_active; then
            echo "✅ mullvad"
            any_active="true"
        else
            echo "⭕ mullvad"
        fi
    fi

    [[ "$any_active" == "true" ]] && echo "🔴 Disconnect All"

    if [[ ${#active_wg[@]} -eq 0 ]] && [[ "$HAS_TAILSCALE" != "true" ]] && [[ "$HAS_MULLVAD" != "true" ]]; then
        echo "No VPN connections configured"
    fi

    exit 0
fi

# --- Toggle Mode ---

if [[ "$mode" == "toggle" ]]; then
    if is_mullvad_interface "$target_conn"; then
        echo "err: Cannot toggle Mullvad's wg interface directly. Use 'mullvad' instead."
        exit 1
    fi

    if [[ "$target_conn" == "Disconnect All" ]]; then
        # Disconnect WireGuard
        mapfile -t active_wg < <(get_active_wg)
        for c in "${active_wg[@]}"; do
            if [[ -n "$c" ]]; then
                nmcli connection down "$c" 2>/dev/null
                wait_for_state "wg" "down" "$c"
            fi
        done

        # Disconnect Tailscale
        if [[ "$HAS_TAILSCALE" == "true" ]] && is_ts_active; then
            tailscale down 2>/dev/null
            wait_for_state "ts" "down"
        fi

        # Disconnect Mullvad
        if [[ "$HAS_MULLVAD" == "true" ]] && is_mv_active; then
            mullvad disconnect 2>/dev/null
            wait_for_state "mv" "down"
        fi

        refresh_waybar
        exit 0
    fi

    case "$target_type" in
        wg)
            mapfile -t active_wg < <(get_active_wg)
            mapfile -t all_wg < <(get_all_wg)
            found="false"

            for c in "${active_wg[@]}"; do
                if [[ "$c" == "$target_conn" ]]; then
                    nmcli connection down "$target_conn" 2>/dev/null
                    wait_for_state "wg" "down" "$target_conn"
                    found="true"
                    break
                fi
            done

            if [[ "$found" == "false" ]]; then
                for c in "${all_wg[@]}"; do
                    if [[ "$c" == "$target_conn" ]]; then
                        nmcli connection up "$target_conn" 2>/dev/null
                        wait_for_state "wg" "up" "$target_conn"
                        found="true"
                        break
                    fi
                done
            fi

            [[ "$found" == "false" ]] && { echo "err: WireGuard connection '$target_conn' not found"; exit 1; }
            ;;
        ts)
            [[ "$HAS_TAILSCALE" != "true" ]] && { echo "err: tailscale CLI not installed"; exit 1; }
            if is_ts_active; then
                tailscale down 2>/dev/null
                wait_for_state "ts" "down"
            else
                tailscale up 2>/dev/null
                wait_for_state "ts" "up"
            fi
            ;;
        mv)
            [[ "$HAS_MULLVAD" != "true" ]] && { echo "err: mullvad CLI not installed"; exit 1; }
            if is_mv_active; then
                mullvad disconnect 2>/dev/null
                wait_for_state "mv" "down"
            else
                mullvad connect 2>/dev/null
                wait_for_state "mv" "up"
            fi
            ;;
        *) echo "err: unknown type '$target_type'"; exit 1 ;;
    esac

    refresh_waybar
    exit 0
fi

# --- Status Mode ---

mapfile -t active_wg < <(get_active_wg)
count_wg=0
for c in "${active_wg[@]}"; do
    [[ -n "$c" ]] && ((count_wg++)) || true
done

ts_active="false"
ts_ip="no-ip"
if [[ "$HAS_TAILSCALE" == "true" ]] && is_ts_active; then
    ts_active="true"
    ts_ip=$(get_ts_ip)
fi

mv_active="false"
mv_ip="no-ip"
if [[ "$HAS_MULLVAD" == "true" ]] && is_mv_active; then
    mv_active="true"
    mv_ip=$(get_mv_ip)
fi

ts_count=0
[[ "$ts_active" == "true" ]] && ts_count=1
mv_count=0
[[ "$mv_active" == "true" ]] && mv_count=1
total_active=$((count_wg + ts_count + mv_count))

text=""
tooltip=""
class="vpn-inactive"
icon="$ICON_INACTIVE"

if [[ $total_active -gt 0 ]]; then
    class="vpn-active"
    icon="$ICON_ACTIVE"
    text="$icon $total_active"

    for c in "${active_wg[@]}"; do
        [[ -z "$c" ]] && continue
        ip=$(nmcli -g ipv4.addresses connection show "$c" 2>/dev/null || echo "no-ip")
        if [[ "$mode" == "status" ]]; then
            tooltip="${tooltip}WG:${c}(${ip}); "
        else
            tooltip="${tooltip}WG:${c}; "
        fi
    done

    [[ "$ts_active" == "true" ]] && tooltip="${tooltip}TS:${ts_ip}; "
    [[ "$mv_active" == "true" ]] && tooltip="${tooltip}MV:${mv_ip}; "
else
    text="$ICON_INACTIVE Off"
    tooltip="No active VPN connections"
fi

echo "{\"text\": \"$(json_escape "$text")\", \"tooltip\": \"$(json_escape "$tooltip")\", \"class\": \"$(json_escape "$class")\"}"
