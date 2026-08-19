# TODO

## Machine pro (Omarchy) — migration vers la nouvelle arbo

- [x] **Fait.** Le pull a été fait sans `stow -D` préalable : les liens de
      l'ancienne arbo plate se sont retrouvés orphelins, `install.sh` a écarté
      les vrais fichiers puis stow a tout avorté sur un conflit — la machine
      s'est retrouvée sans ancienne config ni nouvelle.

`install.sh` ne peut plus produire cet état : il migre les restes de l'ancienne
arbo, retire les liens morts qui pointent dans le repo, écarte aussi les liens
étrangers (pas seulement les vrais fichiers), et s'arrête avec un message
explicite si stow refuse malgré tout. **L'ordre n'a donc plus d'importance :
`git pull && ./install.sh` suffit, y compris sur une machine encore en arbo
plate.**

Ce qu'`install.sh` fait de spécifique à Omarchy : lie `theme/nurburgreen` dans
`~/.config/omarchy/themes/` pour que le sélecteur, Waybar et Hyprland le voient,
puis `omarchy restart waybar`.

Vérifié après coup :
- [x] la statusbar tmux affiche bien le statut Claude — `status-right` (généré
      par `render.sh`) appelle `tmux-claude-status`, qui répond
- [x] les modules waybar todo répondent — `waybar-claude-todo` était cassé en
      repli (motif `grep` commençant par un tiret), corrigé
- [x] tpm charge depuis `~/.config/tmux/plugins` et non `~/.tmux`
- [x] ghostty prend ses couleurs de `~/.config/theme/current/`, plus d'Omarchy
- [x] les shims mise passent devant les binaires pacman
- [ ] `~/.tmux/plugins` traîne encore, vide, depuis l'ancienne install — à supprimer

## Converger le socle shell

Le socle vient d'Omarchy sur la machine pro et de `init.bash` sur Pop : rien ne
garantit qu'ils soient identiques. `init.bash` a été reconstitué sans accès à la
machine pro — c'est la dernière approximation qui reste dans le repo.

```bash
# sur la machine pro
dots-shell-dump > ~/shell-pro.txt
# puis comparer avec la référence Pop déjà générée
diff ~/shell-pro.txt ~/shell-Heartbeat.txt
```

- [ ] recopier dans `common/.config/bash/init.bash` tout ce qui apparaît côté
      Omarchy et manque côté Pop (alias, fonctions, variables)
- [ ] re-differ jusqu'à ce qu'il ne reste que les écarts assumés (profil, polices)

## Claude Code

La config vit maintenant dans `common/.claude/` (voir README). Reste à faire :

- [ ] passer la machine perso : `git pull && ./install.sh`, puis vérifier que
      `settings.json` arrive **sans** `autoMode` et que Claude démarre. Son
      ancienne config part dans `~/.dotfiles-backup/<horodatage>/`.
- [ ] rejouer les serveurs MCP à la main sur la machine perso (`anytype`,
      `mongodb`) — ils vivent dans `~/.claude.json` avec l'OAuth et les chaînes
      de connexion, jamais dans un dépôt public
- [ ] observer si Claude Code finit par remplacer le lien `~/.claude/settings.json`
      par un vrai fichier (écriture atomique). `install.sh` sait le récupérer,
      mais on ne sait pas encore si le cas se produit vraiment
- [ ] la mémoire de projet (`~/.claude/projects/<projet>/memory/`) n'est pas
      suivie — elle vit sous les 169 Mo de `projects/`. À remonter dans un
      paquet à part si on veut qu'elle suive

## Divers

- [x] ~~pousser la branche et merger dans `master`~~ — fait, la machine Pop est validée
- [ ] uniformiser l'emplacement du repo entre les deux machines (`~/.dots` vs `~/.dotfiles`)
- [ ] `common/.config/nvim/colors/nurburgreen.lua` a encore la palette en dur —
      seul endroit qui ne dérive pas de `colors.toml`
- [ ] `bin/oh-my-posh` (19 Mo) reste dans l'historique git ; un `filter-repo`
      allégerait les clones, mais réécrit les hashes
- [ ] COSMIC : `corner_radii` laissé au barème stock, on pourrait l'aligner sur
      le `rounding = 10` d'Hyprland (voir `popos/README.md`)
