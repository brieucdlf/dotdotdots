# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Base Omarchy quand elle est présente (machine pro) — ne pas éditer.
# Absente sur Pop!_OS : init.bash prend le relais juste après.
[[ -f "$HOME/.local/share/omarchy/default/bash/rc" ]] && source "$HOME/.local/share/omarchy/default/bash/rc"

# Socle commun aux deux machines (no-op sur ce qu'Omarchy a déjà fait)
source "$HOME/.config/bash/init.bash"

# Config perso
source "$HOME/.config/bash/exports.bash"
source "$HOME/.config/bash/aliases.bash"

# Auto-attach tmux au démarrage.
# DOTS_NO_TMUX=1 permet d'ouvrir un shell interactif sans tmux (outillage,
# scripts d'inspection type dots-shell-dump).
if [ -z "$TMUX" ] && [ -z "$DOTS_NO_TMUX" ] && command -v tmux &>/dev/null; then
  tmux
fi

# Machine-specific overrides (gitignored) — sourcé en dernier, override tout
[[ -f "$HOME/.config/bash/local.bash" ]] && source "$HOME/.config/bash/local.bash"
