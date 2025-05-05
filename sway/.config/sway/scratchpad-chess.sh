#!/bin/bash
TITLE="scratchpad-chess"
CLASS="chess-nativefier-b30d50"
APP_PATH="$HOME/apps/chess-linux-x64/chess"

if swaymsg -t get_tree | grep -q "\"name\": \"$TITLE\""; then
  swaymsg [title="$TITLE"] scratchpad show
else
  "$APP_PATH" --class "$CLASS" --title "$TITLE" &
fi
