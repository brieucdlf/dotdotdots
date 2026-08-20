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
diff ~/shell-pro.txt ~/shell-perso.txt
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

## Secrets (chaîne age + YubiKey)

En place : `secrets/` chiffré dans le repo, `dots-secrets`, déchiffrement
automatique par `install.sh`. Voir `secrets/README.md`.

- [x] `pcscd` installé et activé par socket
- [x] `dots-secrets enroll` sur les deux YubiKeys — 2 destinataires distincts
- [x] `dots-secrets verify` avec chaque clé — les deux ouvrent
- [x] `dots-secrets label` sur chaque clé — USB-C quotidien, USB-A coffre
- [ ] recréer les deux secrets, absents de cette machine : `dots-secrets edit
      local.bash`, `edit work.gitconfig`
- [ ] rejouer la chaîne sur la machine Omarchy (`pcsclite` + `ccid` côté Arch)

## SSH

`~/.ssh/config` versionné, github.com épinglé sur la YubiKey. Voir README.

- [x] config SSH dans le paquet stow, `~/.ssh` protégé du pliage
- [x] une clé `sk` **résidente** par YubiKey, testée token par token : chacune
      n'est acceptée que par le sien. `ssh-keygen -K` les régénère après un
      reset, rien à sauvegarder
- [x] clé logicielle retirée de GitHub — l'épinglage n'était qu'une préférence
      locale tant que le compte l'acceptait encore
- [x] anciennes `sk` non résidentes écartées dans `~/.dotfiles-backup/`
- [ ] « The Framework » garde une clé logicielle sur le compte : c'est le
      maillon faible restant. Même bascule à faire sur cette machine
- [ ] `id_ed25519_heartbeat` (clé des autres hôtes) porte encore
      `contact@brieucdlf.fr` en commentaire : `ssh-keygen -c -C heartbeat -f`
- [x] signature des commits par SSH : `gpg.format = ssh`, `commit.gpgsign`,
      `allowed_signers` committé, `signingkey` dans identity.gitconfig chiffré
- [ ] enregistrer les deux `sk` chez GitHub en type **signing** (elles n'y sont
      qu'en `authentication`) — demande `gh auth refresh -s admin:ssh_signing_key`.
      Sans ça les commits sont signés mais affichés « Unverified »
- [ ] la clé GPG expirée `3B98056CF6BD3B32` ne sert plus à rien et porte
      l'adresse purgée : à révoquer ou supprimer du trousseau

## Divers

- [x] ~~pousser la branche et merger dans `master`~~ — fait, la machine Pop est validée
- [ ] uniformiser l'emplacement du repo entre les deux machines (`~/.dots` vs `~/.dotfiles`)
- [ ] `common/.config/nvim/colors/nurburgreen.lua` a encore la palette en dur —
      seul endroit qui ne dérive pas de `colors.toml`
- [ ] `bin/oh-my-posh` (19 Mo) reste dans l'historique git ; un `filter-repo`
      allégerait les clones, mais réécrit les hashes
- [ ] COSMIC : `corner_radii` laissé au barème stock, on pourrait l'aligner sur
      le `rounding = 10` d'Hyprland (voir `popos/README.md`)
