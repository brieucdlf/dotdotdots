#!/bin/bash

# Simple script to handle a DIY shutdown menu. When run you should see a bunch of options (shutdown, reboot etc.)
#
# Requirements:
# - rofi
# - systemd, but you can replace the commands for OpenRC or anything else
#
# Instructions:
# - Save this file as power.sh or anything
# - Give it exec priviledge, or chmod +x /path/to/power.sh
# - Run it

#chosen=$(echo -e "[Cancel]\nLogout\nShutdown\nReboot\nSuspend\nHibernate\nHybrid-sleep\nSuspend-then-hibernate" | rofi -dmenu -i)
chosen=$(echo -e "lock\nlogout\nshutdown\nreboot\nsuspend\n[cancel]" | rofi -dmenu -lines 6 -width 11 -p "shutdown" -i)
# Info about some states are available here:
# https://www.freedesktop.org/software/systemd/man/systemd-sleep.conf.html#Description

if [[ $chosen = "lock" ]]; then
	betterlockscreen -l -w dim
elif [[ $chosen = "shutdown" ]]; then
	systemctl poweroff
elif [[ $chosen = "reboot" ]]; then
	systemctl reboot
elif [[ $chosen = "suspend" ]]; then
	systemctl suspend
fi
