#!/bin/bash

export SSH_AUTH_SOCK
export GPG_AGENT_INFO
export GNOME_KEYRING_CONTROL
export GNOME_KEYRING_PID

# Authentication agent
# /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# Notifications
dunst &
mpd &
udiskie --smart-tray &
numlockx on &
ollama serve > /dev/null 2>&1 &

# Clipboard management
clipse -listen &

# Tray applets
nm-applet --indicator &
# blueman-applet &
