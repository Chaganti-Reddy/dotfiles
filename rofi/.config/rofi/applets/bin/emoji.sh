#! /usr/bin/env bash

dir="$HOME/.config/rofi/launchers/type-1"
theme='style-5'

## Run
rofi \
    -modi emoji -show emoji  \
    -theme ${dir}/${theme}.rasi
