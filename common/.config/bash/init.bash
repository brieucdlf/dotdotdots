#!/bin/bash
# Socle shell indépendant de la distro.
#
# Sur Omarchy, ~/.local/share/omarchy/default/bash/rc a déjà tout initialisé :
# chaque bloc ici est gardé et devient un no-op. Sur Pop!_OS (ou toute machine
# sans Omarchy), c'est ce fichier qui fournit le socle — sans lui : pas de
# prompt, pas de zoxide, pas d'alias de base.
#
# Règle : tout ce qui est ajouté ici doit être idempotent et gardé, pour que les
# deux machines convergent au lieu de diverger. `dots-shell-dump` compare.

# ── options shell ────────────────────────────────────────────────────────────
shopt -s histappend checkwinsize globstar 2>/dev/null
HISTCONTROL=ignoreboth
HISTSIZE=32768
HISTFILESIZE=32768

# ── environnement de base ────────────────────────────────────────────────────
export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-$EDITOR}"
export MANPAGER="${MANPAGER:-less -R}"
# SUDO_EDITOR est posé plus bas : il lui faut le PATH de mise.

# ── init des outils (chacun no-op si déjà fait par Omarchy) ──────────────────
if command -v mise &>/dev/null && [[ -z ${MISE_SHELL:-} ]]; then
  eval "$(mise activate bash)"
fi

# `sudo` remplace le PATH par le secure_path de /etc/sudoers, qui ne contient
# évidemment pas ~/.local/share/mise/installs : `sudo nvim` -> command not
# found. La bonne porte est `sudo -e` (sudoedit), qui édite une copie temporaire
# avec NOTRE éditeur sous NOTRE utilisateur, puis réécrit le fichier en root.
# Encore faut-il qu'il retrouve l'éditeur : le nom nu est cherché dans le PATH
# restreint, donc on résout en absolu. Ici et pas plus haut : il faut que mise
# ait déjà peuplé le PATH. Le fallback couvre Omarchy, où nvim est en /usr/bin.
export SUDO_EDITOR="$(command -v "$EDITOR" 2>/dev/null || echo "$EDITOR")"

if command -v starship &>/dev/null && [[ ${PROMPT_COMMAND:-} != *starship* ]]; then
  eval "$(starship init bash)"
fi

if command -v fzf &>/dev/null && ! declare -F __fzf_history__ &>/dev/null; then
  eval "$(fzf --bash)" 2>/dev/null || true
fi

# zoxide EN DERNIER, après starship — c'est ce que demande son doctor.
# starship ne concatène pas PROMPT_COMMAND : il l'écrase par `starship_precmd`
# et rejoue l'ancien contenu via $STARSHIP_PROMPT_COMMAND. Le hook tournait
# donc bel et bien (la base était à jour), mais `zoxide doctor` ne regarde que
# PROMPT_COMMAND et hurlait « possible configuration issue » à chaque `z`.
# Initialisé après, le hook s'ajoute derrière starship_precmd : plus de
# STARSHIP_PROMPT_COMMAND, plus d'avertissement, et un seul appel par prompt.
if command -v zoxide &>/dev/null && ! declare -F __zoxide_z &>/dev/null; then
  eval "$(zoxide init bash)"
fi

# complétion bash (chemin différent selon la distro)
if ! declare -F _init_completion &>/dev/null; then
  for f in /usr/share/bash-completion/bash_completion /etc/bash_completion; do
    [[ -r $f ]] && { source "$f"; break; }
  done
fi

# ── alias de base ────────────────────────────────────────────────────────────
# Repris de la base Omarchy pour que Pop!_OS ait le même vocabulaire.
# `alias X &>/dev/null ||` : on ne réécrit jamais ce qu'Omarchy a déjà posé.
if command -v eza &>/dev/null; then
  alias ls  &>/dev/null || alias ls='eza -lh --group-directories-first --icons=auto'
  alias lsa &>/dev/null || alias lsa='eza -lha --group-directories-first --icons=auto'
  alias lt  &>/dev/null || alias lt='eza --tree --level=2 --long --icons --git'
  alias lta &>/dev/null || alias lta='lt -a'
fi

# `cd` via zoxide, avec fallback builtin si zoxide absent
if declare -F __zoxide_z &>/dev/null && ! declare -F zd &>/dev/null; then
  zd() {
    if [[ $# -eq 0 ]]; then builtin cd ~ && return
    elif [[ -d $1 ]]; then builtin cd "$1"
    else z "$@" && printf ' %s\n' "$PWD"
    fi
  }
  alias cd='zd'
fi

alias ..   &>/dev/null || alias ..='cd ..'
alias ...  &>/dev/null || alias ...='cd ../..'
alias .... &>/dev/null || alias ....='cd ../../..'

alias n &>/dev/null || alias n='nvim'
alias g &>/dev/null || alias g='git'
alias d &>/dev/null || alias d='docker'
alias t &>/dev/null || alias t='tmux'

command -v fastfetch &>/dev/null && { alias ff &>/dev/null || alias ff='fastfetch'; }

# ── couleurs du thème (fzf + eza) ────────────────────────────────────────────
# Généré par theme/render.sh — plus aucune palette codée en dur ici.
[[ -f "$HOME/.config/theme/current/colors.sh" ]] && source "$HOME/.config/theme/current/colors.sh"
