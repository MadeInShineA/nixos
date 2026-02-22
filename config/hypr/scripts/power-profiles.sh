#!/usr/bin/env bash

if ! command -v powerprofilesctl &> /dev/null; then
    notify-send "Error" "powerprofilesctl not found."
    exit 1
fi

# Simple capitalize using sed
capitalize() {
    echo "$1" | sed 's/./\U&/'
}

OPTIONS=$(powerprofilesctl | grep ":$" | while read -r line; do
    profile=$(echo "$line" | sed 's/^\* //;s/://;s/^[[:space:]]*//')
    display=$(capitalize "$profile")
    
    if echo "$line" | grep -q "^\*"; then
        echo "$display (Active)"
    else
        echo "$display"
    fi
done)

CHOICE=$(echo "$OPTIONS" | rofi -dmenu -i -p "Power profile" \
    -kb-row-up "Up,Control+k" \
    -kb-row-down "Down,Control+j")

if [ -n "$CHOICE" ]; then
    PROFILE=$(echo "$CHOICE" | sed 's/ //;s/ (Active)//' | tr '[:upper:]' '[:lower:]')
    powerprofilesctl set "$PROFILE"
    notify-send "Power Profile" "Switched to $(capitalize "$PROFILE")"
fi
