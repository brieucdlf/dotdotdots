#!/bin/zsh

# shell
alias ls='ls --color=auto'
alias ll='ls -l'
alias la='ls -A'
alias cp="cp -i"
alias mv='mv -i'
alias rm='rm -i'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# process info
alias pssh="ps aux | grep ssh"
alias psmem='ps auxf | sort -nr -k 4 | head -5'
alias pscpu='ps auxf | sort -nr -k 3 | head -5'
alias listp='sudo lsof -nP -iTCP -sTCP:LISTEN'

# nvim via fzf
alias v="fd --type f --hidden --exclude .git | fzf-tmux -p | xargs nvim"
alias vim="v"

# lazygit
command -v lazygit &>/dev/null && alias lg="lazygit"

# mods (AI CLI)
command -v mods &>/dev/null && alias ai="mods"

# wireguard
alias wgdeco="sudo wg-quick down wg0"
alias wgco="sudo wg-quick up wg0"
alias wgshow="sudo wg show"

# git
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

# work (bloomflow) — chargé uniquement si le repo existe
[[ -d "$HOME/Repos/bloomflow" ]] && source "$HOME/.config/zsh/work.zsh"
