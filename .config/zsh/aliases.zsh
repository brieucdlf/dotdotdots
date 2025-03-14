#!/bin/sh
# some useful commands taken from @chrisatmachine

# shell
alias ls='ls --color=auto'
alias ll='ls -l'
alias la='ls -A'
alias grep='grep --color=auto'
alias dot="cd $HOME/.dotfiles"
# confirm before overwriting something
alias cp="cp -i"
alias mv='mv -i'
alias rm='rm -i'
# Colorize grep output (good for log files)
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
# check open ssh process
alias pssh="ps aux | grep ssh"
# get top process eating memory
alias psmem='ps auxf | sort -nr -k 4 | head -5'
# get top process eating cpu ##
alias pscpu='ps auxf | sort -nr -k 3 | head -5'

# list used port
alias listp='sudo lsof -nP -iTCP -sTCP:LISTEN'

# lvim - nvim
alias v="fd --type f --hidden --exclude .git | fzf-tmux -p | xargs nvim"
alias vim="v"

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
alias ggu="git pull --rebase origin"
alias gpsup="git push --set-upstream origin"
alias gp="git push"
alias gl="git pull"
alias gst="git status"
alias gss="git status -s"
alias grbi="git rebase -i"
alias grbc="git rebase --continue"
alias grba="git rebase --abort"
alias gpf="git push --force"
alias glog="git log --oneline --decorate --graph"
alias gloga="git log --oneline --decorate --graph --all"

# kubectl
alias k="kubectl"
alias kctx="kubectl config use-context"
alias loki="kubectl -n loki get pods"
alias monito="kubectl -n monitoring get pods"

# works only
alias front="cd $HOME/Repos/bloomflow/sflow-flamingo"
alias api="cd $HOME/Repos/bloomflow/api-platform"
alias bo="cd $HOME/Repos/bloomflow/back-office"
alias infra="cd $HOME/Repos/bloomflow/sflow-infra"
alias deploy="cd $HOME/Repos/bloomflow/sflow-deploy"
alias e2e="cd $HOME/Repos/bloomflow/automated-e2e"
alias cubejs="cd $HOME/Repos/bloomflow/cubejs"
