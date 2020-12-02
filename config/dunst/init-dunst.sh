#!/bin/sh

pidof dunst && killall dunst
dunst &

notify-send "dunst started5"
