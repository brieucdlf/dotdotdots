#!/bin/sh

rename-window builds
split-window -h
new-window -n api
new-window -n misc
new-window -n ssh
# send "api && nf run -e .env npm run dev" C-m
