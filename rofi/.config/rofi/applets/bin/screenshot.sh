#!/usr/bin/env bash

## Author  : Aditya Shakya (adi1090x)
## Github  : @adi1090x
#
## Applets : Screenshot + Screen Recording (Hyprland + grim + slurp + wf-recorder)

# Import Current Theme
source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"

# Theme Elements
prompt='Screenshot/Recording'
mesg="$HOME/Pictures/Screenshots"

if [[ "$theme" == *'type-1'* ]]; then
	list_col='1'
	list_row='4'
	win_width='400px'
elif [[ "$theme" == *'type-5'* ]]; then
	list_col='1'
	list_row='4'
	win_width='720px'
fi

# Options
layout=`cat ${theme} | grep 'USE_ICON' | cut -d'=' -f2`
if [[ "$layout" == 'NO' ]]; then
option_1=" Capture Region to Clipboard"
	option_2=" Capture Desktop"
	option_3="📋 Capture Region"
	option_4=" Start Screen Recording (with Audio)"
	option_5=" Start Screen Recording (No Audio)"
	option_6="❌ Exit Recording"
else
	option_1=""
	option_2=""
	option_3="📋"
	option_4=""
	option_5=""
	option_6="❌"
fi

# Rofi CMD
rofi_cmd() {
	rofi -theme-str "window {width: $win_width;}" \
		-theme-str "listview {columns: $list_col; lines: $list_row;}" \
		-theme-str 'textbox-prompt-colon {str: "";}' \
		-dmenu \
		-p "$prompt" \
		-mesg "$mesg" \
		-markup-rows \
		-theme ${theme}
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5\n$option_6" | rofi_cmd
}

# Screenshot/Recording directory (ensuring screenshots are saved in ~/Pictures/Screenshots)
dir="$HOME/Pictures/Screenshots"
if [[ ! -d "$dir" ]]; then
	mkdir -p "$dir"
fi

# Take screenshots using grim and slurp
timestamp=$(date +%Y-%m-%d-%H-%M-%S)

shotnow() {
	file="$dir/desktop_${timestamp}.png"
	sleep 1 && grim "$file"
	dunstify -u low --replace=699 "Screenshot Saved: $file"
}

shotarea() {
	file="$dir/region_${timestamp}.png"
	grim -g "$(slurp)" "$file"
	dunstify -u low --replace=699 "Screenshot Saved: $file"
}

shotarea_clipboard() {
	grim -g "$(slurp)" - | wl-copy
	dunstify -u low --replace=699 "Screenshot copied to clipboard."
}

# Start Screen Recording with Audio
dir1="$HOME/Pictures/Recordings"

if [[ ! -d "$dir1" ]]; then
  mkdir -p "$dir1"
fi

start_recording_with_audio() {
	file="$dir1/screen_recording_${timestamp}.mp4"
	wf-recorder -f "$file" --audio &
	dunstify -u low --replace=699 "Recording Started (with Audio)"
}

# Start Screen Recording without Audio
start_recording_no_audio() {
	file="$dir1/screen_recording_${timestamp}.mp4"
	wf-recorder -f "$file" &
	dunstify -u low --replace=699 "Recording Started (No Audio)"
}

# Exit Screen Recording (kill the wf-recorder process)
exit_recording() {
	killall wf-recorder
	dunstify -u low --replace=699 "Recording Stopped"
}

# Execute Command
run_cmd() {
	if [[ "$1" == '--opt1' ]]; then
		shotnow
	elif [[ "$1" == '--opt2' ]]; then
		shotarea
	elif [[ "$1" == '--opt3' ]]; then
		start_recording_with_audio
	elif [[ "$1" == '--opt4' ]]; then
		start_recording_no_audio
	elif [[ "$1" == '--opt5' ]]; then
		shotarea_clipboard
	elif [[ "$1" == '--opt6' ]]; then
		exit_recording
	fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    $option_1)
		run_cmd --opt5
        ;;
    $option_2)
		run_cmd --opt1
        ;;
    $option_3)
		run_cmd --opt2
        ;;
    $option_4)
		run_cmd --opt3
        ;;
    $option_5)
		run_cmd --opt4
        ;;
    $option_6)
		run_cmd --opt6
        ;;
esac
