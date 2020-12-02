#!/bin/sh

rename-window dev
split-window -h
new-window -n flamingo
send "flamingo && npm start" C-m
new-window -n api
send "api && nf run -e .env npm run dev" C-m
new-window -n music
send "mpd && music"
