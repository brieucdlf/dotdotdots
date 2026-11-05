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
# Deux traps, pas un seul : un gestionnaire de signal rend la main À L'ENDROIT
# interrompu, il ne sort pas. Avec HUP/INT/TERM sur le même trap que EXIT, un
# Ctrl-C effaçait $MISSING puis laissait le script CONTINUER — le garde plus
# bas passait (fichier disparu), la boucle de nettoyage vidait $DEST, et le
# `cp` final échouait : plus de thème du tout.
trap 'rm -rf "$OUT" "$MISSING"' EXIT
trap 'exit 130' HUP INT TERM

# --- lecture TOML (format simple: clé = "valeur"  # commentaire) ------------
VALUE_OK='^[A-Za-z0-9 #(),.%_/-]*$'
declare -A C
read_toml() {
  [[ -f $1 ]] || return 0
  while IFS= read -r line; do
    [[ $line =~ ^[[:space:]]*([a-zA-Z0-9_]+)[[:space:]]*=[[:space:]]*\"([^\"]*)\" ]] || continue
    # BASH_REMATCH est écrasé par le prochain =~ : on capture d'abord.
    local k="${BASH_REMATCH[1]}" v="${BASH_REMATCH[2]}"

    # Ces valeurs finissent RECOPIÉES dans deux fichiers qui sont SOURCÉS :
    # palette.sh, que lit le crochet theme-set, et colors.sh, que source
    # init.bash à CHAQUE shell interactif. Une valeur contenant $(...), un
    # accent grave ou une contre-oblique y devient du code exécuté à l'ouverture
    # de chaque terminal.
    #
    # Liste BLANCHE et non liste noire : une liste noire se trompe en silence
    # (la première version ratait la contre-oblique simple, et une valeur
    # terminée par « \ » suffisait à casser la syntaxe de palette.sh). Le
    # vocabulaire réel des deux thèmes tient en « #()0-9a-f g r » et l'espace ;
    # ce qui suit garde de la marge pour un nom de police ou un pourcentage.
    if [[ ! $v =~ $VALUE_OK ]]; then
      echo "render: caractère interdit dans $k (voir $1)" >&2
      exit 1
    fi

    # Un « # » en tête annonce une couleur : six chiffres hexadécimaux, pas
    # cinq. Sans ça une coquille passait jusque dans ghostty.conf et rendait
    # toute la palette eza noire, sans un mot.
    if [[ $v == \#* && ! $v =~ ^#[0-9a-fA-F]{6}$ ]]; then
      echo "render: couleur mal formée pour $k : $v" >&2
      exit 1
    fi

    C[$k]="$v"
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
      echo "clé manquante : $1" >>"$MISSING"
    fi
  fi
  printf '%s' "$v"
}

rgb() { # #rrggbb -> "r;g;b" (pour EZA_COLORS / séquences ANSI)
  local h="${1#\#}"
  # On ENREGISTRE avant de rendre un noir muet. Sans ça, seule une clé
  # *absente* était refusée : une clé présente mais mal formée passait ici,
  # ressortait en 0;0;0 et se publiait avec un code de retour 0.
  if [[ ! $h =~ ^[0-9a-fA-F]{6}$ ]]; then
    echo "valeur hexadécimale invalide : ${1:-<vide>}" >>"$MISSING"
    printf '0;0;0'; return
  fi
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

# --- app Herdr -----------------------------------------------------------------
# Un thème de l'app (~/.config/herdr-app/themes/<nom>.json) : la palette du
# terminal en entier, puis les couleurs des panneaux, que l'app dériverait
# sinon de background et foreground. settings.json choisit "dots", et la
# publication en bas recopie ce fichier sous ce nom : changer de thème repeint
# l'app à chaud, sans toucher sa config.
#
# Les couleurs de statut et des panneaux viennent de herdr_* dans ui.toml et
# NON des slots ANSI. L'app les pose en avant-plan sur ses surfaces, ligne
# sélectionnée comprise : sur nurburgreen, color4 y tombait à 1,00:1 — même
# luminance que le fond, donc invisible. Le repli sur la rampe « bright » vaut
# mieux que la sombre pour un thème qui n'aurait pas encore ces clés, sans être
# une garantie : c'est à chaque thème de vérifier les siennes (voir ui.toml).
#
# Le JSON n'a pas de commentaire : l'avertissement « ne pas éditer » est ici.
#
# herdr_app_theme <fichier> <alpha fond> <alpha canevas> <alpha panneaux> <alpha menus>
# Chaque alpha est un suffixe #rrggbbAA, vide pour opaque. "dots" est opaque ;
# "yoru" est translucide : c'est le thème propre au layout du même nom (l'app
# ne le propose que là), où le fond d'écran passe derrière les panneaux. Les
# terminaux, eux, ne deviennent translucides que par le terminal_opacity du
# layout : l'alpha de "background" (dans colors : le champ du haut refuse
# l'alpha) ne vaut que pour les cadres des menus et dialogues, que l'app peint
# dans cette couleur.
herdr_app_theme() {
  local file=$1 a_back=$2 a_canvas=$3 a_panel=$4 a_pop=$5
  local panel row
  panel="$(get herdr_panel_bg "$(get launcher_rail "$(get color0)")")"
  row="$(get herdr_row_bg "$(get statusbar_bg)")"
  cat >"$file" <<EOF
{
  "background": "$(get background)",
  "foreground": "$(get foreground)",
  "selection": "$(get selection_background)",
  "cursor": "$(get cursor)",
  "ansi": [
    "$(get color0)", "$(get color1)", "$(get color2)", "$(get color3)",
    "$(get color4)", "$(get color5)", "$(get color6)", "$(get color7)",
    "$(get color8)", "$(get color9)", "$(get color10)", "$(get color11)",
    "$(get color12)", "$(get color13)", "$(get color14)", "$(get color15)"
  ],
  "colors": {
    "background": "$(get background)$a_back",
    "canvas": "$panel$a_canvas",
    "chrome": "$panel$a_panel",
    "surface": "$(get herdr_surface0 "$(get color0)")$a_panel",
    "popover": "$(get statusbar_bg)$a_pop",
    "raised": "$(get herdr_surface1 "$(get color8)")",
    "input": "$(get herdr_surface0 "$(get color0)")",
    "hover": "$row",
    "selected": "$row",
    "border": "$(get border_inactive)",
    "muted": "$(get color7)",
    "dim": "$(get herdr_overlay1 "$(get color7)")",
    "accent": "$(get accent)",
    "accent_foreground": "$(get color0)",
    "working": "$(get herdr_yellow "$(get color11)")",
    "blocked": "$(get herdr_red "$(get color9)")",
    "done": "$(get herdr_green "$(get color10)")",
    "idle": "$(get herdr_overlay0 "$(get color5)")"
  }
}
EOF
}
herdr_app_theme "$OUT/herdr-app.json" "" "" "" ""
# Canevas transparent : c'est lui qui laisse voir l'image entre les îlots.
herdr_app_theme "$OUT/herdr-app-glass.json" "f2" "00" "e0" "f2"

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

# Le nom du thème rendu, pour que la prochaine exécution sache quoi reprendre.
# Sur Omarchy, `theme.name` fait foi ; ailleurs il n'existe pas, et sans cette
# trace `install.sh` retombait sur le défaut à chaque passage — `--theme` ne
# valait alors que pour une fois.
printf '%s\n' "$THEME" >"$OUT/.theme-name"

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
# Fail closed : si le témoin a disparu (signal, /tmp nettoyée) on ne peut PAS
# conclure que tout va bien.
if [[ ! -f $MISSING ]]; then
  echo "render: témoin de contrôle disparu, rien n'a été publié dans $DEST" >&2
  exit 1
fi
if [[ -s $MISSING ]]; then
  {
    echo "render: $THEME est incomplet, rien n'a été publié dans $DEST"
    echo "render: à corriger dans $SRC/{colors,ui}.toml :"
    sort -u "$MISSING" | sed 's/^/  - /'
  } >&2
  exit 1
fi

mkdir -p "$DEST"

# Ce que render.sh possède dans $DEST. Un fichier que le thème courant ne
# fournit PAS doit disparaître, sinon celui du thème précédent survit : c'est
# ce qui laissait neovim.lua pointer sur nurburgreen sous kreide.
for f in ghostty.conf colors.sh palette.sh tmux.conf herdr-app.json herdr-app-glass.json herdr-theme.toml \
         btop.theme neovim.lua icons.theme backgrounds .theme-name; do
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
# $SRC), et les droits suivent. `mktemp -d` crée en 0700 : sans ce chmod, le
# `.` de la source imposerait 0700 à $DEST, qui était en 0755.
chmod 755 "$OUT"
cp -a "$OUT"/. "$DEST"/

# L'app Herdr lit ses thèmes dans son propre dossier, pas dans $DEST. On n'y
# publie que pour la sortie par défaut : un rendu d'essai vers un autre dossier
# ne doit pas repeindre l'app ouverte. Écrit à côté puis renommé : l'app relit
# le fichier dès qu'il change et ne doit jamais le voir à moitié écrit.
if [[ $DEST == "$HOME/.config/theme/current" && -d $HOME/.config/herdr-app ]]; then
  mkdir -p "$HOME/.config/herdr-app/themes"
  cp -f "$DEST/herdr-app.json" "$HOME/.config/herdr-app/themes/.dots.json.tmp"
  mv -f "$HOME/.config/herdr-app/themes/.dots.json.tmp" "$HOME/.config/herdr-app/themes/dots.json"
  cp -f "$DEST/herdr-app-glass.json" "$HOME/.config/herdr-app/themes/.yoru.json.tmp"
  mv -f "$HOME/.config/herdr-app/themes/.yoru.json.tmp" "$HOME/.config/herdr-app/themes/yoru.json"
  # Le fond d'écran du layout yoru : le premier du thème, comme celui que pose
  # le bureau. L'app ne lit une image que dans son propre dossier, d'où la
  # copie ; un lien vers le thème casserait au rendu suivant, qui le remplace.
  wall="$(find -L "$DEST/backgrounds/" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) 2>/dev/null | sort | head -n 1)"
  if [[ -n $wall ]]; then
    mkdir -p "$HOME/.config/herdr-app/backgrounds"
    cp -f "$wall" "$HOME/.config/herdr-app/backgrounds/.dots.tmp"
    mv -f "$HOME/.config/herdr-app/backgrounds/.dots.tmp" "$HOME/.config/herdr-app/backgrounds/dots.jpg"
  fi
fi

echo "theme: $THEME rendu dans $DEST"
