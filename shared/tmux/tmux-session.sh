#!/bin/sh

rename-session dev
rename-window shell
split-window -h
new-window -n angular
send "web && npm start" C-m
new-window -n api
send "api && nf run -e .env npm run dev" C-m
