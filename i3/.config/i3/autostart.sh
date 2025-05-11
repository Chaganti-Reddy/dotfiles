#!/bin/bash

udiskie --smart-tray &
dunst -conf ~/.config/dunst/dunstrc_xorg &
nm-applet &
redshift -l 16.306652:80.436539 &
autotiling &
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
mpd &
picom &
# Run ollama serve in the background silently.
ollama serve > /dev/null 2>&1 &

betterlockscreen -u ~/.config/i3/lock.png &
