# OMARCHY_PATH et les chemins d'outils, AVANT le test d'interactivité : c'est
# la seule partie dont un shell non interactif a besoin, et il y en a plus
# qu'on ne croit — `bash -lc` des hooks de thème Omarchy, les commandes SSH, le
# io.popen des configs Lua d'Hyprland. Omarchy 4 l'a sorti dans un fichier à
# part exprès ; en v3, tout était derrière le `return` ci-dessous.
[[ -r /usr/share/omarchy/default/bash/env-bootstrap ]] &&
  source /usr/share/omarchy/default/bash/env-bootstrap

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Base Omarchy quand elle est présente (machine pro) — ne pas éditer.
# Absente sur Pop!_OS : init.bash prend le relais juste après.
# $OMARCHY_PATH et non ~/.local/share/omarchy : depuis la v4, Omarchy est un
# paquet pacman dans /usr/share, et l'ancien chemin n'est plus qu'un lien de
# compatibilité posé par la migration. Le repli couvre la v3.
[[ -f "${OMARCHY_PATH:-$HOME/.local/share/omarchy}/default/bash/rc" ]] &&
  source "${OMARCHY_PATH:-$HOME/.local/share/omarchy}/default/bash/rc"

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
