#! /usr/bin/env bash

dir="$HOME/.config/rofi/"
theme='dt-center'

## Run
rofi \
    -modi emoji -show emoji  \
    -theme ${dir}/${theme}.rasi 
