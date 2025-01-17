#!/usr/bin/env sh

# cpu model
model=$(grep 'model name' /proc/cpuinfo | head -n 1 | awk -F ': ' '{print $2}' | sed 's/@.*//' | sed 's/(r)//g' | sed 's/(tm)//g' | tr -d '"')

# total cpu utilization
total_utilization=$(mpstat -P ALL 1 1 | awk '/^Average/ && $2 ~ /all/ {printf "%.0f", 100 - $12}')

# per-core utilization (integer values)
per_core_utilization=$(mpstat -P ALL 1 1 | awk '/^Average/ && $2 ~ /^[0-9]+$/ {printf "Core %s: %d%%\\n", $2, int(100 - $12)}' | tr -d '"')

# clock speed
freqlist=$(grep "cpu MHz" /proc/cpuinfo | awk '{print $4}')
maxfreq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq | sed 's/...$//')
frequency=$(echo "$freqlist" | tr ' ' '\n' | awk -v maxfreq="$maxfreq" '{ sum+=$1 } END {printf "%.0f/%s MHz", sum/NR, maxfreq}')

# cpu temp
temp=$(sensors | awk '/Package id 0/ {print $4}' | awk -F '[+.]' '{print $2}')
if [ -z "$temp" ]; then
    temp=$(sensors | awk '/Tctl/ {print $2}' | tr -d '+°C')
fi
if [ -z "$temp" ]; then
    temp="n/a"
fi

# cpu cores
cores=$(grep -c ^processor /proc/cpuinfo)

# map icons
set_ico="{\"thermo\":{\"0\":\"󱃃\",\"45\":\"󰔏\",\"65\":\"󱃂\",\"85\":\"󰸁\"},\"util\":{\"0\":\"󰾆\",\"30\":\"󰾅\",\"60\":\"󰓅\",\"90\":\"󰀪\"}}"
eval_ico() {
    map_ico=$(echo "${set_ico}" | jq -r --arg aky "$1" --argjson avl "$2" '.[$aky] | keys_unsorted | map(tonumber) | map(select(. <= $avl)) | max')
    echo "${set_ico}" | jq -r --arg aky "$1" --arg avl "$map_ico" '.[$aky] | .[$avl]'
}

thermo=$(eval_ico thermo "$temp")
speedo=$(eval_ico util "$total_utilization")

# ensure JSON-safe strings
model=$(echo "$model" | sed 's/"/\\"/g')
per_core_utilization=$(echo "$per_core_utilization" | sed ':a;N;$!ba;s/\n/\\n/g')

# print cpu info (json)
echo "{\"text\":\"${thermo} ${temp}°C\", \"tooltip\":\"${model}\\ntemperature: ${temp}°C\\ntotal CPU utilization: ${total_utilization}%\\nper-core utilization:\\n${per_core_utilization}\\nclock speed: ${frequency}\"}"
