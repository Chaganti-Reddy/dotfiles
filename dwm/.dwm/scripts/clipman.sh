#!/bin/bash

# Check if xfce4-clipman is running
if pgrep -x "xfce4-clipman" > /dev/null
then
    # If running, do nothing
    echo "xfce4-clipman is already running."
else
    # If not running, start xfce4-clipman
    echo "xfce4-clipman is not running. Starting it now..."
    xfce4-clipman &
fi

