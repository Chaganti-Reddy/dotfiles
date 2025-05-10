#!/usr/bin/env bash 

export SSH_AUTH_SOCK
export GPG_AGENT_INFO
export GNOME_KEYRING_CONTROL
export GNOME_KEYRING_PID

if [[ ! `pidof gnome-polkit` ]]; then
	/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
fi
# /usr/bin/emacs --daemon &
numlockx &
nm-applet &
dunst -conf ~/.config/dunst/dunstrc_xorg &
xscreensaver --no-splash &
# clipmenud &
# flameshot &
blueman-applet &
xcompmgr &
mpd &

slstatus &

/usr/bin/udiskie --smart-tray &
if [ -d ~/.cache/wallheaven ]; then
    rm -rf ~/.cache/wallheaven
fi

xsetroot -cursor_name left_ptr

# if [ -d /tmp/redyt/ ]; then 
#   rm -rf /tmp/redyt 
# fi

~/.dwm/newlook &
~/.dwm/scripts/mouse &

/usr/bin/gnome-keyring-daemon --start

if [ -z "$(pgrep xfce4-clipman)" ]; then
    xfce4-clipman &
fi

# Run ollama serve in the background silently.
ollama serve > /dev/null 2>&1 &
