#!/bin/bash

# Configuration
PICTURES_DIR=~/Pictures/pix
WALL_CACHE=~/.cache/wal/current_wallpaper

# Function to select a random wallpaper
get_random_wallpaper() {
  find "$PICTURES_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" \) | shuf -n 1
}

# Function to set the wallpaper (Sway)
set_wallpaper() {
  local wallpaper="$1"
  [[ ! -f "$wallpaper" ]] && dunstify -u low "Wallpaper not found: $wallpaper" && exit 1

  # Use swaymsg to set the wallpaper
  swaymsg "output * bg \"$wallpaper\" fill"

  # Cache current wallpaper path
  cp "$wallpaper" "$WALL_CACHE"
}

# Apply pywal theme
apply_theme() {
  wal -i "$1"

  # Restart dunst
  pkill dunst && dunst &
}

# Reload Waybar with symlinked wal theme
reload_waybar() {
  local waybar_config_dir="$HOME/dotfiles/sway/.config/sway/waybar/"
  local wal_css="$HOME/.cache/wal/colors-waybar.css"
  local target_css="$waybar_config_dir/colors-waybar.css"

  # Create symlink if it doesn't exist or is broken
  if [[ ! -L "$target_css" || ! -e "$target_css" ]]; then
    ln -sf "$wal_css" "$target_css"
    dunstify -u low "Waybar theme linked"
  fi

  # Kill Waybar if running
  pkill -x waybar
  # Start Waybar manually
  waybar &
}

# Reload Sway configuration
reload_sway_config() {
  swaymsg reload
  dunstify -u low "Sway configuration reloaded"
}

# Main logic
main() {
  local wallpaper=$(get_random_wallpaper)
  [[ -z "$wallpaper" ]] && dunstify "No wallpapers found!" && exit 1

  set_wallpaper "$wallpaper"
  apply_theme "$wallpaper"
  reload_waybar
  reload_sway_config
}

main

