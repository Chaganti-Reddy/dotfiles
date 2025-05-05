#!/bin/bash
TITLE="scratch-term"
CLASS="scratchpad-term"

if swaymsg -t get_tree | grep -q "\"name\": \"$TITLE\""; then
  swaymsg [title="$TITLE"] scratchpad show
else
  kitty --class "$CLASS" --title "$TITLE" &
fi

