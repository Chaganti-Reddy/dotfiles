#!/bin/bash
TITLE="scratchpad-calc"
CLASS="qalculate-gtk"

if swaymsg -t get_tree | grep -q "\"name\": \"$TITLE\""; then
  swaymsg [title="$TITLE"] scratchpad show
else
  qalculate-gtk --class "$CLASS" --title "$TITLE" &
fi
