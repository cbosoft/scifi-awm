#!/usr/bin/env bash

run() {
    if ! pgrep -f "$1"; then
        $@ &
    fi
}


run picom
run /home/chris/.bin/scrput -f
run xset r rate 200 50
run xset -dpms
run setxkbmap -option caps:escape
