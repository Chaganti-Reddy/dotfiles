#!/bin/bash

# if not create the directory
if [ ! -d "$HOME/Pictures/Screenshots" ]; then
    mkdir -p "$HOME/Pictures/Screenshots"
fi

# Take the screenshot and save it
name=$(date +'%m%d%S.png')
grim "$HOME/Pictures/Screenshots/$name"

# Ask to save the file through rofi
if [ -x "$(command -v rofi)" ]; then
    save_confirmation=$(echo -e "No\nYes" | rofi -dmenu -i -p "Save the screenshot?")
    if [ "$save_confirmation" != "Yes" ]; then
        rm "$HOME/Pictures/Screenshots/$name"  # Remove the screenshot if not saving
        dunstify -u low -t 2000 "Screenshot discarded."
        exit 0  # Exit if not saving
    fi
fi

# Ask to rename the file through rofi
if [ -x "$(command -v rofi)" ]; then
    new_name=$(echo -e "No\nYes" | rofi -dmenu -i -p "Rename the file?")
    if [ "$new_name" = "Yes" ]; then
        new_name=$(echo -e "" | rofi -dmenu -i -p "Enter new name")
        mv "$HOME/Pictures/Screenshots/$name" "$HOME/Pictures/Screenshots/$new_name.png"
        name=$new_name.png
    fi
fi

# Notify user
dunstify -u low -t 2000 "Screenshot saved to $HOME/Pictures/Screenshots/$name"

# Copy the screenshot to clipboard
if [ -x "$(command -v rofi)" ]; then
    if [ "$(echo -e "No\nYes" | rofi -dmenu -i -p "Copy to clipboard?")" = "Yes" ]; then
        clipse -a "$HOME/Pictures/Screenshots/$name"
        dunstify -u low -t 2000 "Screenshot copied to clipboard"
    fi
fi

# Give an option to open the screenshot in sxiv
if [ -x "$(command -v rofi)" ]; then
    if [ "$(echo -e "No\nYes" | rofi -dmenu -i -p "Open with sxiv?")" = "Yes" ]; then
        sxiv "$HOME/Pictures/Screenshots/$name"
    fi
fi
