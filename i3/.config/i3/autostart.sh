#!/bin/bash

udiskie --smart-tray &
dunst -conf ~/.config/dunst/dunstrc_xorg &
~/.config/scripts/redshift.sh &
~/.config/scripts/check-battery.sh &
# nm-applet &
# xfce4-clipman &
greenclip daemon &
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
mpd &
# picom &
# Run ollama serve in the background silently.
ollama serve > /dev/null 2>&1 &
~/.config/i3/random_wall > /tmp/random_wall.log &
