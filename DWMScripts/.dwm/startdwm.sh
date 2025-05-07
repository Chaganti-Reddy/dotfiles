#!/bin/sh

# Optional: background and keyboard layout setup
# feh --bg-scale ~/Downloads/wp.png
# setxkbmap us,ru -option 'grp:caps_toggle'

# Start dwmblocks in background
dwmblocks &

# Loop to restart dwm only on error/quit({1})
while true; do
    # Log stderr to a file
    dwm 2>~/.dwm.log

    # Get dwm's exit status
    status=$?

    # Exit loop if dwm quit with status 1
    [ $status -eq 1 ] && break
done

