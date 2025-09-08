# nvm
export NVM_DIR="$HOME/.nvm"
# Loads nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
# Loads nvm bash_completion
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# vscode
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"

# krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# brew
export PATH="$HOME/.linuxbrew/bin:$PATH"

# TMUX
if command -v tmux &>/dev/null; then
    [ -z "$TMUX" ] && exec tmux
fi

# Load Angular CLI autocompletion.
if command -v ng &> /dev/null; then
    source <(ng completion script)
fi

# enable kubectl completion
if command -v kubectl &> /dev/null; then
    source <(kubectl completion zsh)
else
    echo "kubectl is not installed. Please install it before proceeding."
fi

# FZF
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--border='rounded' --border-label='' --preview-window='border-rounded' --prompt='> ' \
--marker='>' --pointer='◆' --separator='.' --scrollbar='│' \
--layout='reverse' --info='right' --height=80%"

# add fd-find on T command to avoid ignored files
export FZF_DEFAULT_COMMAND="fd --type f"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
