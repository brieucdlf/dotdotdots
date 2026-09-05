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

# On rend dans un dossier temporaire, et on ne PUBLIE qu'après vérification.
# Sans ça, une clé manquante écrivait un `accent = ""` par-dessus la config
# vivante avant que quoi que ce soit puisse s'en apercevoir.
DEST="$OUT"
OUT="$(mktemp -d)"
MISSING="$(mktemp)"
trap 'rm -rf "$OUT" "$MISSING"' EXIT HUP INT TERM

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

get() { # get clé [défaut] — note l'absence, la sortie est refusée à la fin
  local v="${C[$1]:-}"
  if [[ -z $v ]]; then
    if [[ $# -ge 2 ]]; then v="$2"; else
      # PAS d'`exit 1` ici : `get` n'est appelé qu'en $(...), presque toujours
      # dans un heredoc. Le `exit` ne tuerait que le sous-shell de la
      # substitution — le `cat` englobant réussirait, `set -e` ne verrait rien,
      # et le fichier partirait avec une valeur VIDE en rendant 0. On enregistre
      # donc dans un fichier (un sous-shell ne peut pas écrire une variable du
      # parent) et la publication est refusée en bas.
      echo "$1" >>"$MISSING"
    fi
  fi
  printf '%s' "$v"
}

rgb() { # #rrggbb -> "r;g;b" (pour EZA_COLORS / séquences ANSI)
  local h="${1#\#}"
  # Une clé manquante arrive ici en chaîne vide et `printf %d 0x` crie trois
  # fois par appel, juste avant le vrai message. Le rendu est refusé de toute
  # façon : on rend un noir muet pour que l'erreur utile reste lisible.
  [[ $h =~ ^[0-9a-fA-F]{6}$ ]] || { printf '0;0;0'; return; }
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

# --- palette brute ----------------------------------------------------------
# colors.sh n'expose que FZF_DEFAULT_OPTS et EZA_COLORS, déjà mis en forme.
# Tout script qui veut dessiner a besoin des couleurs elles-mêmes ; le seul
# consommateur aujourd'hui est le crochet theme-set, pour THEME_ACCENT.
# Fichier séparé et non fusionné dans colors.sh : celui-ci est sourcé par chaque
# shell, inutile d'y injecter vingt variables pour un seul consommateur.
{
  echo "#!/bin/bash"
  echo "# généré par theme/render.sh depuis $THEME/colors.toml — ne pas éditer"
  for k in accent cursor foreground background selection_foreground \
           selection_background border_inactive statusbar_bg; do
    printf 'export THEME_%s="%s"\n' "$(echo "$k" | tr '[:lower:]' '[:upper:]')" "$(get "$k")"
  done
  for i in {0..15}; do
    printf 'export THEME_COLOR%d="%s"\n' "$i" "$(get "color$i")"
  done
} >"$OUT/palette.sh"

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

# --- herdr -------------------------------------------------------------------
# Seulement les deux sections de thème : le reste de ~/.config/herdr/config.toml
# (raccourcis, prefix, new_cwd) vient d'Omarchy et lui appartient. Le crochet
# theme-set greffe ce bloc dedans, entre marqueurs.
#
# `name = "terminal"` et non un thème intégré : herdr prend alors la palette
# ANSI du terminal, que ghostty.conf ci-dessus vient justement de dériver du
# même colors.toml. Les jetons ci-dessous ne recouvrent que ce que « terminal »
# ne sait pas peindre — les surfaces du châssis.
cat >"$OUT/herdr-theme.toml" <<EOF
# généré par theme/render.sh depuis $THEME/colors.toml — ne pas éditer
[theme]
name = "terminal"

[theme.custom]
accent        = "$(get accent)"
panel_bg      = "$(get launcher_rail "$(get color0)")"
sidebar_bg    = "$(get launcher_rail "$(get color0)")"
active_row_bg = "$(get statusbar_bg)"
selection_bg  = "$(get border_inactive)"
surface0      = "$(get color0)"
surface1      = "$(get color8)"
surface_dim   = "$(get statusbar_bg)"
overlay0      = "$(get herdr_overlay0 "$(get color5)")"
overlay1      = "$(get color7)"
text          = "$(get foreground)"
subtext0      = "$(get color7)"
# Les sept sémantiques viennent de herdr_* dans ui.toml et NON des slots ANSI.
# herdr les pose en avant-plan sur ses surfaces, ligne sélectionnée comprise :
# sur nurburgreen, color4 y tombait à 1,00:1 — même luminance que le fond,
# donc invisible. Le repli sur la rampe « bright » vaut mieux que la sombre
# pour un thème qui n'aurait pas encore ces clés, sans être une garantie :
# c'est à chaque thème de vérifier les siennes (voir le bloc dans ui.toml).
mauve         = "$(get herdr_mauve    "$(get color13)")"
green         = "$(get herdr_green    "$(get color10)")"
yellow        = "$(get accent)"
red           = "$(get herdr_red      "$(get color9)")"
blue          = "$(get herdr_blue     "$(get color12)")"
teal          = "$(get herdr_teal     "$(get color14)")"
peach         = "$(get herdr_peach    "$(get color9)")"
EOF

# --- COSMIC (Pop!_OS) ------------------------------------------------------
# Fichier importable via Réglages > Apparence > Importer un thème.
#
# ATTENTION au schéma. Les fichiers de /usr/share/cosmic-themes livrés par le
# système sont dans un format ANCIEN (couleurs en structs de flottants,
# `is_frosted: bool`). Le schéma que le parseur attend réellement — celui des
# thèmes communautaires qui fonctionnent — utilise des chaînes "#RRGGBBAA",
# un enum `frosted`, et les champs frosted_*/alpha_map. Un fichier à l'ancien
# format s'applique visuellement mais ne persiste pas.
#
# La palette sémantique stock (accents, bright_*, ext_*) est reprise telle
# quelle ; on ne surcharge que la rampe neutre, qui porte tout le chrome.
COSMIC_STOCK="$(dirname "${BASH_SOURCE[0]}")/cosmic/palette-stock-dark.txt"

hexa() { # #rrggbb -> "#RRGGBBAA" (alpha opaque)
  printf '#%sFF' "$(printf '%s' "${1#\#}" | tr '[:lower:]' '[:upper:]')"
}

if [[ -f $COSMIC_STOCK ]]; then
  {
    echo "("
    echo "    palette: Dark(("
    echo '        name: "cosmic-dark",'
    while IFS= read -r line; do
      [[ -n $line ]] || continue
      key="${line%%:*}"
      # la rampe neutre et les gris passent en carbone BRG, le reste reste stock
      case $key in
        neutral_*|gray_*) printf '        %s: "%s",\n' "$key" "$(hexa "$(get "cosmic_$key")")" ;;
        *)                printf '        %s\n' "$line" ;;
      esac
    done < <(cat "$COSMIC_STOCK"; echo)
    cat <<EOF
    )),
    spacing: (
        space_none: 0,
        space_xxxs: 4,
        space_xxs: 8,
        space_xs: 12,
        space_s: 16,
        space_m: 24,
        space_l: 32,
        space_xl: 48,
        space_xxl: 64,
        space_xxxl: 128,
    ),
    corner_radii: (
        radius_0: (0.0, 0.0, 0.0, 0.0),
        radius_xs: (4.0, 4.0, 4.0, 4.0),
        radius_s: (8.0, 8.0, 8.0, 8.0),
        radius_m: (16.0, 16.0, 16.0, 16.0),
        radius_l: (32.0, 32.0, 32.0, 32.0),
        radius_xl: (160.0, 160.0, 160.0, 160.0),
    ),
    neutral_tint: None,
    bg_color: Some("$(hexa "$(get background)")"),
    primary_container_bg: None,
    secondary_container_bg: None,
    text_tint: None,
    accent: Some("$(hexa "$(get accent)")"),
    success: Some("$(hexa "$(get color10)")"),
    warning: Some("$(hexa "$(get color11)")"),
    destructive: Some("$(hexa "$(get color9)")"),
    frosted: Medium,
    gaps: (0, 8),
    active_hint: 2,
    window_hint: Some("$(hexa "$(get foreground)")"),
    frosted_windows: true,
    frosted_system_interface: false,
    frosted_panel: true,
    frosted_applets: true,
    alpha_map: (
        extremely_low: 0.9,
        extremely_low_2: 0.87692,
        very_low: 0.85385,
        very_low_2: 0.83076,
        low: 0.80769,
        low_2: 0.78461,
        medium: 0.76154,
        medium_2: 0.73846,
        high: 0.71538,
        high_2: 0.69231,
        very_high: 0.66023,
        very_high_2: 0.64615,
        extremely_high: 0.62308,
        extremely_high_2: 0.6,
    ),
)
EOF
  } >"$OUT/cosmic-$THEME-dark.ron"
fi

# --- fichiers statiques (pas de génération, juste exposés au même endroit) ---
for f in btop.theme neovim.lua icons.theme; do
  [[ -f $SRC/$f ]] && ln -sfn "$SRC/$f" "$OUT/$f"
done
[[ -d $SRC/backgrounds ]] && ln -sfn "$SRC/backgrounds" "$OUT/backgrounds"

# --- vérification, PUIS publication -----------------------------------------
# Rien n'est publié tant qu'une clé manque. Le message liste toutes les clés
# d'un coup — chercher la suivante après chaque relance serait pénible — et le
# code de sortie est non nul, ce que `set -e` d'install.sh et le crochet
# theme-set voient enfin passer.
if [[ -s $MISSING ]]; then
  {
    echo "render: $THEME est incomplet, rien n'a été publié dans $DEST"
    echo "render: clés manquantes dans $SRC/{colors,ui}.toml :"
    sort -u "$MISSING" | sed 's/^/  - /'
  } >&2
  exit 1
fi

mkdir -p "$DEST"

# Ce que render.sh possède dans $DEST. Un fichier que le thème courant ne
# fournit PAS doit disparaître, sinon celui du thème précédent survit : c'est
# ce qui laissait neovim.lua pointer sur nurburgreen sous kreide.
for f in ghostty.conf colors.sh palette.sh tmux.conf herdr-theme.toml \
         btop.theme neovim.lua icons.theme backgrounds; do
  if [[ ! -e $OUT/$f && ! -L $OUT/$f ]] && [[ -e $DEST/$f || -L $DEST/$f ]]; then
    rm -rf "$DEST/$f"
  fi
done
# Idem pour les .ron des AUTRES thèmes, qui s'accumulaient un par thème rendu.
shopt -s nullglob
for f in "$DEST"/cosmic-*-dark.ron; do
  [[ $(basename "$f") == "cosmic-$THEME-dark.ron" ]] || rm -f "$f"
done
shopt -u nullglob

# -a : les liens sont recopiés en tant que liens (ils pointent en absolu vers
# $SRC), et les droits suivent.
cp -a "$OUT"/. "$DEST"/

echo "theme: $THEME rendu dans $DEST"
