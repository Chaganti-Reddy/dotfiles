#!/bin/bash
TITLE="scratchpad-music"
CLASS="Music"

if swaymsg -t get_tree | grep -q "\"name\": \"$TITLE\""; then
  swaymsg [title="$TITLE"] scratchpad show
else
  st -c "$CLASS" -e ~/.ncmpcpp/scripts/ncmpcpp-art &
fi
