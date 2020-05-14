#!/usr/bin/env sh

# Terminate already running polybar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch polybar
polybar main &
polybar external &

# Multi monitor test
# for m in $(polybar --list-monitors | cut -d":" -f1); do
#   MONITOR=$m polybar --reload main & 
# done
