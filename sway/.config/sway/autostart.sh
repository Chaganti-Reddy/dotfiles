#!/bin/bash

export SSH_AUTH_SOCK
export GPG_AGENT_INFO
export GNOME_KEYRING_CONTROL
export GNOME_KEYRING_PID

# Authentication agent
if [[ ! `pidof gnome-polkit` ]]; then
	/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
fi
/usr/bin/gnome-keyring-daemon --start &

# Notifications
dunst -conf ~/.config/dunst/dunstrc_wayland &
mpd &
udiskie --smart-tray &
numlockx &
# ollama serve > /dev/null 2>&1 &
autotiling -l 2 &

# Clipboard management
clipse -listen &

# Tray applets
# nm-applet --indicator &
# blueman-applet &

