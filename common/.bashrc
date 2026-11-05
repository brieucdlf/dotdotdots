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

# Multiplexeur au démarrage. DOTS_MUX choisit lequel : none (défaut, shell nu)
# ou tmux. DOTS_NO_TMUX=1 reste honoré — c'est l'ancien nom de none.
#
# Shell nu par défaut : c'est l'app Herdr qui multiplexe, et ses terminaux
# vivent dans herdr-core. Un multiplexeur lancé d'ici s'y emboîterait.
__dots_mux="${DOTS_MUX:-none}"
[ -n "${DOTS_NO_TMUX:-}" ] && __dots_mux=none

# HC_TERMINAL_ID est à herdr-core ce que TMUX est à tmux : posé seulement dans
# un de ses terminaux. Même un DOTS_MUX=tmux exporté ne doit pas s'y emboîter.
[ -n "${HC_TERMINAL_ID:-}" ] && __dots_mux=none

case "$__dots_mux" in
  tmux)
    if [ -z "${TMUX:-}" ] && command -v tmux &>/dev/null; then
      tmux
    fi
    ;;
esac
unset __dots_mux

# Machine-specific overrides (gitignored) — sourcé en dernier, override tout
[[ -f "$HOME/.config/bash/local.bash" ]] && source "$HOME/.config/bash/local.bash"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
