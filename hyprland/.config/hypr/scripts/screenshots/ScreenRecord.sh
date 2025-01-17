#!/bin/bash

# Create the directory if it doesn't exist
RECORD_DIR="$HOME/Videos/Records"
mkdir -p "$RECORD_DIR"

VID="$RECORD_DIR/$(date +'%m%d%S.mp4')"
echo "$VID" > /tmp/recording.txt

# Ask for recording options
SELECTION1=$(echo -e "Entire Screen\nArea\nExit" | rofi -dmenu -p "Select Area Type")

# Define the command based on user selection
case "$SELECTION1" in
    "Area")
        SELECTION2=$(echo -e "With Audio\nWithout Audio" | rofi -dmenu -p "Select Audio Type")
        if [ "$SELECTION2" == "With Audio" ]; then
            CMD="wf-recorder -a -g \$(slurp) -f \"$VID\""
        else
            CMD="wf-recorder -g \$(slurp) -f \"$VID\""
        fi
        ;;
    "Entire Screen")
        SELECTION2=$(echo -e "With Audio\nWithout Audio" | rofi -dmenu -p "Select Audio Type")
        if [ "$SELECTION2" == "With Audio" ]; then
            CMD="wf-recorder -a -o eDP-1 -f \"$VID\""
        else
            CMD="wf-recorder -o eDP-1 -f \"$VID\""
        fi
        ;;
    "Exit")
        killall wf-recorder
        exit 0
        ;;
    *)
        dunstify -u low -t 2000 "Invalid Selection"
        exit 1
        ;;
esac

# Start recording
eval "$CMD" &>/dev/null

# Notify user
dunstify -u low -t 2000 "Screen Record saved to $VID"
