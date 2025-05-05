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

  swaybg -m fill -i "$wallpaper" &

  # Cache current wallpaper path
  cp "$wallpaper" "$WALL_CACHE"
}

# Apply pywal theme
apply_theme() {
  wal -i "$1"

  pkill dunst
  sleep 0.5  # let it fully terminate
  dunst &
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
  waybar -c "$HOME/dotfiles/sway/.config/sway/waybar/config.jsonc" -s "$HOME/dotfiles/sway/.config/sway/waybar/style.css" >/dev/null 2>&1 &
}

# Reload Sway configuration
reload_sway_config() {
  swaymsg reload
  dunstify -u low "Sway configuration reloaded"
}

update_sway_borders() {
  local config_file="$HOME/.config/sway/config"
  local wal_colors="$HOME/.cache/wal/colors.json"

  # Extract necessary colors
  focused_border=$(jq -r '.colors.color3' "$wal_colors")
  background=$(jq -r '.colors.color0' "$wal_colors")
  text=$(jq -r '.colors.color7' "$wal_colors")
  accent=$(jq -r '.colors.color2' "$wal_colors")
  urgent=$(jq -r '.colors.color1' "$wal_colors")

  # Format lines
  focused_line="client.focused $focused_border $background $text $accent $focused_border"
  unfocused_line="client.unfocused $background $background $text $background $background"
  urgent_line="client.urgent $urgent $background $text $urgent $urgent"

  # Update or insert
  if grep -q "^client.focused " "$config_file"; then
    sed -i -E -e "s|^client.focused .*|$focused_line|" "$config_file"
  else
    echo "$focused_line" >> "$config_file"
  fi

  if grep -q "^client.unfocused " "$config_file"; then
    sed -i -E -e "s|^client.unfocused .*|$unfocused_line|" "$config_file"
  else
    echo "$unfocused_line" >> "$config_file"
  fi

  if grep -q "^client.urgent " "$config_file"; then
    sed -i -E -e "s|^client.urgent .*|$urgent_line|" "$config_file"
  else
    echo "$urgent_line" >> "$config_file"
  fi

  # dunstify -u low "Sway border colors updated"
}

# Main logic
main() {
  local wallpaper=$(get_random_wallpaper)
  [[ -z "$wallpaper" ]] && dunstify "No wallpapers found!" && exit 1

  set_wallpaper "$wallpaper"
  apply_theme "$wallpaper"
  reload_waybar
  update_sway_borders
  reload_sway_config
}

main

