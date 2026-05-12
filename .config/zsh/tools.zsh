#!/bin/zsh
# Tool initializations — chaque bloc est conditionnel

# nvm
export NVM_DIR="${XDG_CONFIG_HOME:-$HOME}/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# auto-switch node version selon .nvmrc
autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"
  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")
    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

# krew (kubectl plugins)
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# brew (linuxbrew)
[[ -d "$HOME/.linuxbrew" ]] && export PATH="$HOME/.linuxbrew/bin:$PATH"

# Angular CLI completion
command -v ng &>/dev/null && source <(ng completion script)

# kubectl completion
if command -v kubectl &>/dev/null; then
  source <(kubectl completion zsh)
fi

# VSCode shell integration
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"

# atuin (shell history)
command -v atuin &>/dev/null && eval "$(atuin init zsh)"

# zoxide (smart cd)
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# TMUX — auto-attach au démarrage si pas déjà dans une session
if command -v tmux &>/dev/null && [[ -z "$TMUX" ]]; then
  exec tmux
fi
