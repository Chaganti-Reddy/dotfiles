#!/bin/bash

udiskie --smart-tray &
dunst -conf ~/.config/dunst/dunstrc_xorg &
~/.config/i3/redshift.sh &
# nm-applet &
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
mpd &
# picom &
# Run ollama serve in the background silently.
ollama serve > /dev/null 2>&1 &
~/.config/i3/random_wall &
