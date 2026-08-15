#!/bin/bash
# PATH et variables d'env. Les couleurs (fzf, eza) viennent de
# ~/.config/theme/current/colors.sh, généré par theme/render.sh — voir init.bash.

# PATH
export PATH="$HOME/.local/bin:$PATH"
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# fzf — les couleurs sont dans colors.sh, ici seulement les commandes
if command -v fd &>/dev/null; then
  export FZF_DEFAULT_COMMAND="fd --type f"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi
