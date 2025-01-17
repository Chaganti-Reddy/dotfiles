#!/usr/bin/env bash

## Author  : Aditya Shakya (adi1090x)
## Github  : @adi1090x
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
layout=$(cat ${theme} | grep 'USE_ICON' | cut -d'=' -f2)
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

# Notification and Sound
notify_view() {
	local file_path=$1
	local is_video=$2
	local notify_icon=$3
	local notify_message=$4
	
	paplay /usr/share/sounds/freedesktop/stereo/screen-capture.oga &>/dev/null &
	dunstify -u low -h string:x-dunst-stack-tag:obscreenshot -i "$notify_icon" "$notify_message"
	
		viewnior "$file_path"
}

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

# Directories
screenshot_dir="$HOME/Pictures/Screenshots"
recording_dir="$HOME/Pictures/Recordings"

if [[ ! -d "$screenshot_dir" ]]; then
	mkdir -p "$screenshot_dir"
fi
if [[ ! -d "$recording_dir" ]]; then
	mkdir -p "$recording_dir"
fi

# Timestamp
timestamp=$(date +%Y-%m-%d-%H-%M-%S)

# Screenshot Functions
shotnow() {
	file="$screenshot_dir/desktop_${timestamp}.png"
	grim "$file"
	notify_view "$file" false "/usr/share/icons/dunst/picture.png" "Screenshot Saved: $file"
}

shotarea() {
	file="$screenshot_dir/region_${timestamp}.png"
	grim -g "$(slurp)" "$file"
	notify_view "$file" false "/usr/share/icons/dunst/picture.png" "Screenshot Saved: $file"
}

shotarea_clipboard() {
	grim -g "$(slurp)" - | wl-copy
	dunstify -u low -h string:x-dunst-stack-tag:obscreenshot -i "/usr/share/icons/dunst/picture.png" "Screenshot copied to clipboard."
}

# Screen Recording Functions
start_recording_with_audio() {
	file="$recording_dir/screen_recording_${timestamp}.mp4"
	wf-recorder -f "$file" --audio &
	dunstify -u low -h string:x-dunst-stack-tag:obscreenshot -i "/usr/share/icons/dunst/video.png" "Recording Started (with Audio)"
}

start_recording_no_audio() {
	file="$recording_dir/screen_recording_${timestamp}.mp4"
	wf-recorder -f "$file" &
	dunstify -u low -h string:x-dunst-stack-tag:obscreenshot -i "/usr/share/icons/dunst/video.png" "Recording Started (No Audio)"
}

exit_recording() {
	killall wf-recorder
	dunstify -u low -h string:x-dunst-stack-tag:obscreenshot -i "/usr/share/icons/dunst/video.png" "Recording Stopped"
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
chosen=$(run_rofi)
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
