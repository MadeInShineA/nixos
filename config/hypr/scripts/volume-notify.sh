#!/usr/bin/env bash
# Adjust volume
pamixer "$@"

# Get current volume and mute state
VOLUME=$(pamixer --get-volume)
MUTED=$(pamixer --get-mute)

# Send notification using tag-based replacement (no ID file needed)
if [ "$MUTED" = "true" ]; then
    notify-send -t 1000 -a "Volume" \
        -h int:value:"$VOLUME" \
        -h string:category:volume \
        -h string:x-dunst-stack-tag:volume \
        'Volume' '🔇 Muted'
else
    notify-send -t 1000 -a "Volume" \
        -h int:value:"$VOLUME" \
        -h string:category:volume \
        -h string:x-dunst-stack-tag:volume \
        'Volume' "🔊 ${VOLUME}%"
fi
