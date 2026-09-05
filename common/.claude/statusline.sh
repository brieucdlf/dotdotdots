#!/usr/bin/env bash
# Statusline Claude Code. Reçoit le JSON de session sur stdin (schéma :
# https://code.claude.com/docs/en/statusline).
#
# AFFICHER une ligne compacte sous le prompt, et rien d'autre. Ce script
# déposait aussi `rate_limits` et un résumé par session dans
# ~/.cache/claude-panel/ — le panneau tmux qui les relisait n'existe plus, et
# ce cache n'avait plus aucun lecteur (ni ici, ni dans ~/.claude/hooks, ni
# dans ~/.local/bin). Le dépôt tournait à chaque rafraîchissement, une dizaine
# de processus pour des fichiers que personne n'ouvrait.
#
# À savoir si le besoin revient : `rate_limits`, `cost.total_cost_usd` et
# `context_window.used_percentage` ne sont exposés QU'ICI, au stdin de la
# statusline. Ni la CLI ni les transcripts ne les portent.
#
# Les couleurs sont les index ANSI 0-15, donc la palette du thème telle que
# ghostty la pose : rien de codé en dur ici non plus.
set -uo pipefail

in=$(cat)

# Index ANSI 0-15. Au-delà de 7 c'est la rampe « bright » (90-97) et NON
# \033[38m, qui introduit les couleurs étendues et ne colore rien tout seul.
c() {
  if (($1 < 8)); then printf '\033[3%dm%s\033[0m' "$1" "$2"
  else printf '\033[9%dm%s\033[0m' "$(($1 - 8))" "$2"
  fi
}

# IFS sur la TABULATION, et surtout pas de `tr '\t' ' '` : le nom de modèle
# contient des espaces (« Opus 5 (1M context) »), les convertir décalait tous
# les champs d'un cran.
IFS=$'\t' read -r model effort ctx cost five seven < <(
  jq -r '[
    (.model.display_name // "?"),
    (.effort.level // "-"),
    (.context_window.used_percentage // 0 | floor),
    (.cost.total_cost_usd // 0),
    (.rate_limits.five_hour.used_percentage // -1 | floor),
    (.rate_limits.seven_day.used_percentage // -1 | floor)
  ] | @tsv' <<<"$in"
)

# Vert sous 50 %, jaune sous 80 %, rouge au-delà — même barème pour le contexte
# et pour les quotas.
tint() { local p=$1; ((p < 50)) && echo 2 || { ((p < 80)) && echo 3 || echo 1; }; }

out="$(c 3 "$model")  $(c 8 "$effort")  $(c "$(tint "$ctx")" "${ctx}% ctx")"
((five  >= 0)) && out+="  $(c 8 '5h') $(c "$(tint "$five")"  "${five}%")"
((seven >= 0)) && out+="  $(c 8 '7j') $(c "$(tint "$seven")" "${seven}%")"
out+="  $(c 8 "\$$(printf '%.2f' "$cost")")"
# Testé AVANT la coloration : une chaîne vide entourée de codes ANSI n'est
# plus vide, et le segment s'afficherait hors dépôt.
branch=$(git branch --show-current 2>/dev/null)
[[ -n $branch ]] && out+="  $(c 6 "$branch")"

printf '%s\n' "$out"
