#!/usr/bin/env bash
# Adjust brightness
brightnessctl "$@"

# Get brightness as percentage
BRIGHTNESS_RAW=$(brightnessctl g)
BRIGHTNESS_MAX=$(brightnessctl m)
BRIGHTNESS=$(( BRIGHTNESS_RAW * 100 / BRIGHTNESS_MAX ))

# Send notification using tag-only replacement (no ID tracking needed)
notify-send -t 1000 \
    -h int:value:"$BRIGHTNESS" \
    -h string:x-dunst-stack-tag:brightness \
    'Brightness' "☀️ ${BRIGHTNESS}%"
