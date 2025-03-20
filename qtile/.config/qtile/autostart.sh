#!/usr/bin/env bash 

export SSH_AUTH_SOCK
export GPG_AGENT_INFO
export GNOME_KEYRING_CONTROL
export GNOME_KEYRING_PID

xinput --set-prop "DLL09D9:00 04F3:3147 Touchpad" "libinput Natural Scrolling Enabled" 1
xinput --set-prop "DLL09D9:00 04F3:3147 Touchpad" "libinput Tapping Enabled" 1
xinput --set-prop "pointer:Razer Razer DeathAdder Essential" "libinput Accel Speed" -0.8
xinput --set-prop "pointer:Razer Razer DeathAdder Essential" "libinput Accel Profile Enabled" 1, 0

### AUTOSTART PROGRAMS ###
# picom --daemon --config ~/.config/qtile/picom.conf &
# /usr/bin/emacs --daemon &
nm-applet &
dunst -conf ~/.config/dunst/dunstrc_xorg &
"$HOME"/.screenlayout/monitor.sh &
mpd &
udiskie --smart-tray &
# /usr/lib/polkit-kde-authentication-agent-1 &
if [[ ! `pidof gnome-polkit` ]]; then
	/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
fi
/usr/bin/gnome-keyring-daemon --start &
numlockx on &
xsetroot -cursor_name left_ptr

~/.config/qtile/qtile-wall.sh &
# ~/.config/qtile/wall.sh &

if [ -z "$(pgrep xfce4-clipman)" ]; then
    xfce4-clipman &
fi

# Run ollama serve in the background silently.
ollama serve > /dev/null 2>&1 &
