#!/bin/bash

# Check if wallpaper path is provided
if [ -z "$1" ]; then
    echo "Usage: $0 /path/to/wallpaper"
    exit 1
fi

WALLPAPER_PATH="$1"
WAL_CACHE_DIR="$HOME/.cache/wal"
COLORS_PY="$HOME/.config/qtile/colors.py"

# Run wal to generate colors
wal -i "$WALLPAPER_PATH" > /dev/null 2>&1

# Check if colors.json exists
if [ ! -f "$WAL_CACHE_DIR/colors.json" ]; then
    echo "Error: Failed to generate colors with wal."
    exit 1
fi

# Extract colors from wal's colors.json
COLORS=($(jq -r '.colors | .color0, .color1, .color2, .color3, .color4, .color5, .color6, .color7, .color8, .color9' "$WAL_CACHE_DIR/colors.json"))

# Generate the new color scheme for colors.py without extra newline before WalColors
NEW_COLORS=$(cat <<EOF
WalColors = [
    ["${COLORS[0]}", "${COLORS[0]}"], # bg
    ["${COLORS[1]}", "${COLORS[1]}"], # fg
    ["${COLORS[2]}", "${COLORS[2]}"], # color01
    ["${COLORS[3]}", "${COLORS[3]}"], # color02
    ["${COLORS[4]}", "${COLORS[4]}"], # color03
    ["${COLORS[5]}", "${COLORS[5]}"], # color04
    ["${COLORS[6]}", "${COLORS[6]}"], # color05
    ["${COLORS[7]}", "${COLORS[7]}"], # color06
    ["${COLORS[8]}", "${COLORS[8]}"], # color15
    ["${COLORS[9]}", "${COLORS[9]}"], # color[9]
]
EOF
)

# Check if WalColors exists in colors.py
if grep -q "WalColors" "$COLORS_PY"; then
    # If it exists, delete the entire WalColors block, including everything under it
    sed -i '/WalColors = \[/,/^\]/d' "$COLORS_PY"
fi

# Append the new WalColors block to the end of the file
echo -e "$NEW_COLORS" >> "$COLORS_PY"

echo "Colors updated in $COLORS_PY"

# Restart qtile
qtile cmd-obj -o cmd -f reload_config
