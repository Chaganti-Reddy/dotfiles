#!/bin/bash
killall waybar
SDIR="$HOME/.config/waybar"
waybar -c "$SDIR"/config1.jsonc -s "$SDIR"/style1.css &

