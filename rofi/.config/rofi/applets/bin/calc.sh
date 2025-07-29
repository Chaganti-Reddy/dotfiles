#! /usr/bin/env bash

dir="$HOME/.config/rofi/launchers/type-1"
theme='style-5'

## Run
rofi \
    -show calc -modi calc -no-show-match -no-sort  \
    -theme ${dir}/${theme}.rasi
