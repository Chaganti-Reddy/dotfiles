#!/bin/bash

# Define the directory where your wallpapers are stored
wallpaper_dir="$HOME/dotfiles/hypr_wall"

# Get a list of all images in the directory (recursively)
wallpapers=$(find "$wallpaper_dir" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" -o -iname "*.bmp" -o -iname "*.tiff" \))

# Check if the wallpaper list is empty
if [ -z "$wallpapers" ]; then
  echo "No wallpapers found in the specified directory."
  exit 1
fi

# Select a random wallpaper from the list
random_wallpaper=$(echo "$wallpapers" | shuf -n 1)

# Define a random transition type
transition_type=$(echo "wipe center random" | tr ' ' '\n' | shuf -n 1)

# Set the wallpaper with a random transition effect using swww
swww img "$random_wallpaper" --transition-type "$transition_type" --transition-step 20 --transition-fps 30 2>/dev/null

# Optional: You can adjust the transition parameters (step and fps) to control the smoothness and speed of the transition.
