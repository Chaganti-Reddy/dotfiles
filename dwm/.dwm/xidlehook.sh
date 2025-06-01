#!/bin/bash

xidlehook \
  --not-when-fullscreen \
  --not-when-audio \
  --timer 60 \
    'dunstify -u low --replace=1669 "Idle" "Dimming screen to 30%"; brightnessctl set 30%' \
    'brightnessctl set 100%' \
  --timer 600 \
    'dunstify -u low --replace=1669 "Locking" "Locking the screen"; brightnessctl set 100%; betterlockscreen -l dim' '' \
  --timer 300 \
    'dunstify -u low --replace=1669 "Display" "Turning off screen"; xset dpms force off' '' \
  --timer 900 \
    'dunstify -u low --replace=1669 "Suspending" "System will now suspend"; systemctl suspend' '' \
  --socket "/tmp/xidlehook.sock"
