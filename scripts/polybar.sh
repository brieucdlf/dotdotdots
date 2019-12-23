#!/bin/sh

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Get all the monitor connected to display polybar
for m in $(polybar --list-monitors | cut -d":" -f1); do
  MONITOR=$m polybar --reload bartop &
done
