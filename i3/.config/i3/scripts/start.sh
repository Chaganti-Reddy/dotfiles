#!/usr/bin/env bash 

export SSH_AUTH_SOCK
export GPG_AGENT_INFO
export GNOME_KEYRING_CONTROL
export GNOME_KEYRING_PID

xinput --set-prop "DLL09D9:00 04F3:3147 Touchpad" "libinput Natural Scrolling Enabled" 1
xinput --set-prop "DLL09D9:00 04F3:3147 Touchpad" "libinput Tapping Enabled" 1
xinput --set-prop "pointer:Razer Razer DeathAdder Essential" "libinput Accel Speed" -0.5
xinput --set-prop "pointer:Razer Razer DeathAdder Essential" "libinput Accel Profile Enabled" 1, 0

if [ -z "$(pgrep xfce4-clipman)" ]; then
    xfce4-clipman &
fi

~/.screenlayout/monitor.sh &
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

autotiling &
numlockx &
dunst &
udiskie --smart-tray &
nm-applet &
xfce4-power-manager &

# Run ollama serve in the background silently.
ollama serve > /dev/null 2>&1 &
