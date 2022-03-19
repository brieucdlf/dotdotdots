# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

fpath+=$HOME/.zsh/pure
ZSH_THEME=""

# minikube kubectl
plugins=(git zsh-autosuggestions vscode tmux zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# place this after nvm initialization!
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

test -r ~/.dir_colors && eval $(dircolors ~/.dir_colors)

autoload -U promptinit; promptinit

# turn on git stash status
zstyle :prompt:pure:git:stash show yes
alias gs='git status'
prompt pure

add-zsh-hook chpwd load-nvmrc
load-nvmrc
