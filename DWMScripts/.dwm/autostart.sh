#!/bin/bash
#
#
# xinput set-prop "DLL09D9:00 04F3:3147 Touchpad" "libinput Tapping Enabled" 1
# xinput set-prop "DLL09D9:00 04F3:3147 Touchpad" "libinput Natural Scrolling Enabled" 1
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
# /usr/bin/emacs --daemon &
numlockx &
nm-applet &
dunst &
xscreensaver --no-splash &
# clipmenud &
# flameshot &
blueman-applet &
xcompmgr &
mpd &
slstatus &
~/.dwm/scripts/mouse &
/usr/bin/udiskie --smart-tray &
if [ -d ~/.cache/wallheaven ]; then
    rm -rf ~/.cache/wallheaven
fi

# if [ -d /tmp/redyt/ ]; then 
#   rm -rf /tmp/redyt 
# fi

~/.dwm/newlook &
# /home/ram/.dwm/scripts/whatsapp_start &
/usr/bin/gnome-keyring-daemon --start
export SSH_AUTH_SOCK
export GPG_AGENT_INFO
export GNOME_KEYRING_CONTROL
export GNOME_KEYRING_PID



if [ -z "$(pgrep xfce4-clipman)" ]; then
    xfce4-clipman &
fi

# if [ -z "$(pgrep ferdium)" ]; then
#     ferdium &
# fi
