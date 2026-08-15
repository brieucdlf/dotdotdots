#!/usr/bin/env bash
# Rend un thème vers ~/.config/theme/current à partir de son colors.toml.
#
# colors.toml est la SEULE source de vérité des couleurs. Tout ce qui affiche
# des couleurs (ghostty, tmux, fzf, eza, btop) lit ce qui est généré ici — plus
# aucune palette codée en dur dans les configs.
#
# Usage: render.sh [thème] [dossier de sortie]
set -euo pipefail

THEME="${1:-nurburgreen}"
OUT="${2:-$HOME/.config/theme/current}"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$THEME"

[[ -d $SRC ]] || { echo "render: thème introuvable: $SRC" >&2; exit 1; }

# --- lecture TOML (format simple: clé = "valeur"  # commentaire) ------------
declare -A C
read_toml() {
  [[ -f $1 ]] || return 0
  while IFS= read -r line; do
    [[ $line =~ ^[[:space:]]*([a-zA-Z0-9_]+)[[:space:]]*=[[:space:]]*\"([^\"]*)\" ]] || continue
    C[${BASH_REMATCH[1]}]="${BASH_REMATCH[2]}"
  done <"$1"
}
read_toml "$SRC/colors.toml"
read_toml "$SRC/ui.toml"

get() { # get clé [défaut] — échoue fort si absent et sans défaut
  local v="${C[$1]:-}"
  if [[ -z $v ]]; then
    if [[ $# -ge 2 ]]; then v="$2"; else
      echo "render: clé manquante dans $THEME: $1" >&2; exit 1
    fi
  fi
  printf '%s' "$v"
}

rgb() { # #rrggbb -> "r;g;b" (pour EZA_COLORS / séquences ANSI)
  local h="${1#\#}"
  printf '%d;%d;%d' "0x${h:0:2}" "0x${h:2:2}" "0x${h:4:2}"
}

mkdir -p "$OUT"

# --- ghostty ----------------------------------------------------------------
{
  echo "# généré par theme/render.sh depuis $THEME/colors.toml — ne pas éditer"
  echo "background = $(get background)"
  echo "foreground = $(get foreground)"
  echo "cursor-color = $(get cursor)"
  echo "selection-background = $(get selection_background)"
  echo "selection-foreground = $(get selection_foreground)"
  for i in {0..15}; do echo "palette = $i=$(get "color$i")"; done
} >"$OUT/ghostty.conf"

# --- shell (fzf + eza) ------------------------------------------------------
cat >"$OUT/colors.sh" <<EOF
#!/bin/bash
# généré par theme/render.sh depuis $THEME/colors.toml — ne pas éditer

export FZF_DEFAULT_OPTS=" \\
--color=bg+:$(get color4),bg:$(get background),spinner:$(get foreground),hl:$(get accent) \\
--color=fg:$(get foreground),header:$(get color13),info:$(get color13),pointer:$(get accent) \\
--color=marker:$(get accent),fg+:$(get color15),prompt:$(get color12),hl+:$(get color11) \\
--border='rounded' --border-label='' --preview-window='border-rounded' --prompt='> ' \\
--marker='>' --pointer='◆' --separator='─' --scrollbar='│' \\
--layout='reverse' --info='right' --height=80%"

export EZA_COLORS="\\
di=1;38;2;$(rgb "$(get foreground)"):\\
ln=38;2;$(rgb "$(get color14)"):\\
ex=38;2;$(rgb "$(get color10)"):\\
da=38;2;$(rgb "$(get color13)"):\\
sn=38;2;$(rgb "$(get color7)"):\\
sb=38;2;$(rgb "$(get color13)"):\\
uu=1;38;2;$(rgb "$(get color15)"):\\
gu=38;2;$(rgb "$(get color13)"):\\
ur=38;2;$(rgb "$(get color12)"):\\
uw=38;2;$(rgb "$(get color9)"):\\
ux=38;2;$(rgb "$(get color10)"):\\
gr=2;38;2;$(rgb "$(get color12)"):\\
gw=2;38;2;$(rgb "$(get color9)"):\\
gx=2;38;2;$(rgb "$(get color10)"):\\
tr=2;38;2;$(rgb "$(get color12)"):\\
tw=2;38;2;$(rgb "$(get color9)"):\\
tx=2;38;2;$(rgb "$(get color10)")"
EOF

# --- tmux -------------------------------------------------------------------
cat >"$OUT/tmux.conf" <<EOF
# généré par theme/render.sh depuis $THEME/colors.toml — ne pas éditer

set -g pane-border-style        "fg=$(get border_inactive)"
set -g pane-active-border-style "fg=$(get color12)"

set -g status-style "bg=$(get statusbar_bg),fg=$(get foreground)"
set -g status-left  "#[fg=$(get color0),bg=$(get color13),bold] #S #[fg=$(get color13),bg=$(get statusbar_bg),nobold]  "
set -g status-right "#[fg=$(get color5)]#(tmux-claude-status)  #[fg=$(get color12)] #(cd #{pane_current_path} && git branch --show-current 2>/dev/null)  #[fg=$(get color13)]⎈ #(kubectl config current-context 2>/dev/null) "

set -g window-status-format         "#[fg=$(get color5),bg=$(get statusbar_bg)] #I #{b:pane_current_path} "
set -g window-status-current-format "#[fg=$(get foreground),bg=$(get color8),bold] #I #{b:pane_current_path} #[fg=$(get color8),bg=$(get statusbar_bg),nobold]"

set -g message-style         "fg=$(get foreground),bg=$(get statusbar_bg)"
set -g message-command-style "fg=$(get foreground),bg=$(get statusbar_bg)"
set -g mode-style            "fg=$(get color0),bg=$(get color13)"
EOF

# --- fichiers statiques (pas de génération, juste exposés au même endroit) ---
for f in btop.theme neovim.lua icons.theme; do
  [[ -f $SRC/$f ]] && ln -sfn "$SRC/$f" "$OUT/$f"
done
[[ -d $SRC/backgrounds ]] && ln -sfn "$SRC/backgrounds" "$OUT/backgrounds"

echo "theme: $THEME rendu dans $OUT"
