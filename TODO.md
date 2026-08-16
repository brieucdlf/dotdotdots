# TODO

## Machine pro (Omarchy) — migration vers `two-profiles`

⚠️ **L'ordre compte.** Le repo passe d'une arbo plate (`stow .`) à des paquets
stow (`common` + `profiles/omarchy`). Si tu pulls avant de dé-stower, les
anciens liens deviennent orphelins et stow refusera de poser les nouveaux.

```bash
cd ~/.dots                 # ou ~/.dotfiles — vérifier où il est là-bas
stow -D .                  # 1. dé-stow l'ANCIENNE arbo, AVANT le pull
git pull
git checkout two-profiles
./install.sh               # 2. détecte omarchy, re-stow, rend le thème, mise install
```

Ce qu'`install.sh` fait de spécifique à Omarchy : lie `theme/nurburgreen` dans
`~/.config/omarchy/themes/` pour que le sélecteur, Waybar et Hyprland le voient,
puis `omarchy restart waybar`.

À vérifier après coup :
- [ ] la statusbar tmux affiche bien le statut Claude (le chemin était cassé avant : `~/.dots/bin/...`)
- [ ] les modules waybar todo (`~/.local/bin/waybar-claude-todo`, `todo-popup`) répondent
- [ ] tpm charge depuis `~/.config/tmux/plugins` et non `~/.tmux`
- [ ] ghostty prend ses couleurs de `~/.config/theme/current/`, plus d'Omarchy
- [ ] les shims mise passent devant les binaires pacman (c'est voulu, mais à constater)

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

## Divers

- [ ] pousser la branche et merger dans `master` une fois les deux machines OK
- [ ] uniformiser l'emplacement du repo entre les deux machines (`~/.dots` vs `~/.dotfiles`)
- [ ] `common/.config/nvim/colors/nurburgreen.lua` a encore la palette en dur —
      seul endroit qui ne dérive pas de `colors.toml`
- [ ] `bin/oh-my-posh` (19 Mo) reste dans l'historique git ; un `filter-repo`
      allégerait les clones, mais réécrit les hashes
- [ ] COSMIC : `corner_radii` laissé au barème stock, on pourrait l'aligner sur
      le `rounding = 10` d'Hyprland (voir `profiles/popos/README.md`)
