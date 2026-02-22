
#!/usr/bin/env bash

# Check if powerprofilesctl exists
if ! command -v powerprofilesctl &> /dev/null; then
    notify-send "Error" "powerprofilesctl not found."
    exit 1
fi

# Get current profile (the line starting with *)
CURRENT=$(powerprofilesctl | grep "^\*" | awk '{print $2}' | tr -d ':')

# Extract all profile names (lines ending with :)
# Format them for rofi, marking the active one
OPTIONS=$(powerprofilesctl | grep ":$" | while read -r line; do
    # Check if this line starts with * (active)
    if echo "$line" | grep -q "^\*"; then
        profile=$(echo "$line" | sed 's/^\* //' | tr -d ':')
        echo " $profile (Active)"
    else
        profile=$(echo "$line" | tr -d ':' | xargs)
        echo "$profile"
    fi
done)

# Launch Rofi with some styling
CHOICE=$(echo "$OPTIONS" | rofi -dmenu -i -p "Power Profile" \
    -kb-row-up "Up,Control+k" \
    -kb-row-down "Down,Control+j")

if [ -n "$CHOICE" ]; then
    # Clean the choice (remove icon and status text)
    PROFILE=$(echo "$CHOICE" | sed 's/ //;s/ (Active)//' | xargs)
    
    # Set the new profile
    powerprofilesctl set "$PROFILE"
    
    notify-send "Power Profile" "Switched to $PROFILE"
fi
