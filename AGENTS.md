# dotfiles

Dépôt **public** (`brieucdlf/dotdotdots`) : rien de secret en clair. Les secrets
sont chiffrés sous `secrets/` (age + YubiKey) ; `common/.config/zed/.env` et
`common/.claude/settings.private.json` ne sont jamais commités.

- Paquets stow : `common/` plus un profil (`popos/` ou `omarchy/`), stowés en
  une seule invocation par `install.sh`.
- Un dossier qu'une app remplit (`~/.ssh`, `~/.codex`, `~/.config/herdr-app`…)
  est créé par `mkdir` **avant** stow. Sinon stow le plie en un lien vers le
  dépôt, et l'app y écrit ses clés ou son état.
- Un fichier qu'une app réécrit par-dessus son lien passe par `reclaim` et son
  témoin dans `install.sh`.
- Couleurs : `theme/<thème>/colors.toml` (et `ui.toml`) est la seule source,
  `theme/render.sh` génère le reste. Aucune couleur codée en dur ailleurs.
- `install.sh` reste idempotent et sûr sous `set -euo pipefail`. Une nouvelle
  étape se teste à part (faux `HOME` dans un dossier temporaire) avant d'être
  livrée.
- Commentaires en français, qui disent pourquoi. Le README documente chaque
  choix : il se met à jour dans le même commit.
- Multiplexeur et agents : l'app Herdr. Orca l'IDE (`orca-ide`, `stably-orca`)
  est abandonné, `install.sh` le retire (`leave_orca`). Homonyme sans rapport :
  le paquet système `orca` est le lecteur d'écran, dont dépendent
  `cosmic-session` et `pop-de-cosmic`. Le retirer emporterait le bureau.
