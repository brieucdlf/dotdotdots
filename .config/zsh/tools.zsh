#!/bin/zsh
# Tool initializations — chaque bloc est conditionnel

# mise (runtime version manager — remplace nvm/rvm/etc.)
command -v mise &>/dev/null && eval "$(mise activate zsh)"

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
