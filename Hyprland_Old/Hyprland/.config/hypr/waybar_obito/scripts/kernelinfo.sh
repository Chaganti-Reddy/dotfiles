#!/usr/bin/env sh

# Kernel version
kernel_version=$(uname -r)

# Check for available updates
available_updates=$(pacman -Qu | wc -l)

# Icons based on the number of updates
if [ "$available_updates" -gt 0 ]; then
    icon="󰻤" # icon for updates available
    updates_text="${available_updates} updates available"
else
    icon="󰾆" # icon for no updates
    updates_text="Up to date"
fi

# Print kernel info (json)
echo "{\"text\":\"${icon} ${kernel_version}\", \"tooltip\":\"${updates_text}\"}"
