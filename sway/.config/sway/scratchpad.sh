#!/bin/bash
name="$1"
class="$2"
cmd="$3"
size="${4:-60x60}"
position="${5:-center}"

if swaymsg -t get_tree | grep -q "\"title\": \"$name\""; then
  swaymsg "[title=\"$name\"] scratchpad show"
else
  $cmd --class "$class" --title "$name" &
fi

