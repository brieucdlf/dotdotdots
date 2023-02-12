#!/bin/sh

# shell
alias ll="ls"
alias la="ls -la"

# git most used
alias g="git"
alias ga="git add"
alias gcs="git commit -S"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gcl="git clone"
alias gcp="git cherry-pick"
alias gd="git diff"
alias gds="git diff --staged"
alias gfa="git fetch --all --prune"
alias ggu="git pull --rebase origin $(current_branch)"
alias gpsup="git push --set-upstream origin $(git_current_branch)"
alias gl="git pull"
alias gst="git status"
alias gss="git status -s"
