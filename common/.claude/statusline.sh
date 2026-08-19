#!/usr/bin/env bash
# Statusline Claude Code. Reçoit le JSON de session sur stdin (schéma :
# https://code.claude.com/docs/en/statusline).
#
# Double rôle :
#  1. AFFICHER une ligne compacte sous le prompt ;
#  2. DÉPOSER dans un cache ce que `claude-panel` ne peut obtenir nulle part
#     ailleurs. Deux fichiers :
#       - rate-limits.json  : les quotas, propres au compte. C'est le SEUL
#         endroit où `rate_limits` est exposé — ni la CLI ni les transcripts
#         ne les portent, le panneau ne pourrait qu'estimer.
#       - sessions/<id>.json : modèle, effort, coût et contexte de CETTE
#         session. Le coût et le pourcentage de contexte ne sont calculés que
#         côté client, ils n'existent dans aucun fichier de session.
#
# Les couleurs sont les index ANSI 0-15, donc la palette du thème telle que
# ghostty la pose : rien de codé en dur ici non plus.
set -uo pipefail

in=$(cat)
cache="$HOME/.cache/claude-panel"

# Écriture atomique : le panneau lit ce fichier en parallèle, il ne doit jamais
# tomber sur un JSON à moitié écrit. mktemp dans le MÊME dossier, sinon `mv`
# traverse les systèmes de fichiers et perd son atomicité.
drop() {  # $1 = destination, $2 = filtre jq
  local dir tmp
  dir=$(dirname "$1")
  mkdir -p "$dir" 2>/dev/null || return 0
  tmp=$(mktemp "$dir/.drop.XXXXXX" 2>/dev/null) || return 0
  if jq -c "$2" <<<"$in" >"$tmp" 2>/dev/null; then mv -f "$tmp" "$1"; else rm -f "$tmp"; fi
}

drop "$cache/rate-limits.json" '{rate_limits: (.rate_limits // {}), at: now}'

sid=$(jq -r '.session_id // empty' <<<"$in" 2>/dev/null || true)
# Le nom du fichier vient d'une donnée externe : on n'accepte qu'un UUID, sinon
# un session_id fantaisiste écrirait où il veut.
if [[ $sid =~ ^[0-9a-fA-F-]{36}$ ]]; then
  drop "$cache/sessions/$sid.json" '{
    model:  (.model.display_name // null),
    effort: (.effort.level // null),
    cost:   (.cost.total_cost_usd // 0),
    ctx:    (.context_window.used_percentage // null),
    at:     now
  }'
fi

# Index ANSI 0-15. Au-delà de 7 c'est la rampe « bright » (90-97) et NON
# \033[38m, qui introduit les couleurs étendues et ne colore rien tout seul.
c() {
  if (($1 < 8)); then printf '\033[3%dm%s\033[0m' "$1" "$2"
  else printf '\033[9%dm%s\033[0m' "$(($1 - 8))" "$2"
  fi
}

read -r model effort ctx cost five seven < <(
  jq -r '[
    (.model.display_name // "?"),
    (.effort.level // "-"),
    (.context_window.used_percentage // 0 | floor),
    (.cost.total_cost_usd // 0),
    (.rate_limits.five_hour.used_percentage // -1 | floor),
    (.rate_limits.seven_day.used_percentage // -1 | floor)
  ] | @tsv' <<<"$in" | tr '\t' ' '
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
