#!/bin/bash

# Check and kill any existing xidlehook process
if pidof xidlehook >/dev/null; then
  killall xidlehook
fi 

sleep 0.5

# Start xidlehook fresh
# dunstify -u low --replace=10034 "xidlehook" "Started"

xidlehook \
  --not-when-fullscreen \
  --not-when-audio \
  --timer 60 \
    'brightnessctl set 30%' \
    'brightnessctl set 100%' \
    --timer 300 \
    'dunstify -u low --replace=1669 "Display" "Turning off screen"; xset dpms force off' '' \
  --timer 600 \
    'dunstify -u low --replace=1669 "Locking" "Locking the screen"; brightnessctl set 100%; betterlockscreen -l dim' '' \
  --timer 900 \
    'dunstify -u low --replace=1669 "Suspending" "System will now suspend"; systemctl suspend' '' \
  --socket "/tmp/xidlehook.sock"

