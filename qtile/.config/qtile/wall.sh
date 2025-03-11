#!/bin/bash

# Use find with -print0 to handle spaces correctly and capture file paths
mapfile -d '' wallpapers < <(find "$HOME/Pictures/pix" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.bmp" \) -print0)

# Check if wallpapers were found
if [ ${#wallpapers[@]} -gt 0 ]; then
    # Pick a random wallpaper
    random_wallpaper="${wallpapers[RANDOM % ${#wallpapers[@]}]}"

    # Set the wallpaper using feh, properly quoting the path in case there are spaces
    feh --bg-scale "$random_wallpaper"
else
    echo "No wallpapers found."
fi
