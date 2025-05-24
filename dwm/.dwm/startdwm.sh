#!/bin/sh

# Optional: background and keyboard layout setup
# feh --bg-scale ~/Downloads/wp.png
# setxkbmap us,ru -option 'grp:caps_toggle'

# Start dwmblocks in background
# dwmblocks &

while true; do
    # Log stderr to a file
    dwm 2>~/.dwm.log

done

