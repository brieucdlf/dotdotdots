# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Omarchy defaults (ne pas éditer directement)
source ~/.local/share/omarchy/default/bash/rc

# Personal config
source "$HOME/.config/bash/exports.bash"
source "$HOME/.config/bash/aliases.bash"

# Auto-attach tmux au démarrage
if [ -z "$TMUX" ]; then
  tmux
fi

# Machine-specific overrides (gitignored)
[[ -f "$HOME/.config/bash/local.bash" ]] && source "$HOME/.config/bash/local.bash"
