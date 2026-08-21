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
- [x] signature des commits par SSH : `gpg.format = ssh`, `commit.gpgsign`,
      `allowed_signers` committé, `signingkey` dans identity.gitconfig chiffré
- [x] les deux `sk` déclarées chez GitHub en type **signing** (1125645 USB-C,
      1125646 USB-A) en plus d'`authentication` — GitHub sépare les deux usages.
      Vérifié : `.commit.verification` renvoie `{"reason":"valid"}`
- [x] `libfido2` installé côté Arch — dépendance dure sur Debian, simple
      `optdepend` sur Arch : sans elle `ssh-keygen -K` échoue **après** le PIN,
      sur un message qui ne nomme ni FIDO ni la YubiKey
- [x] askpass installé (`ssh-askpass-gnome` / `ksshaskpass`) et `SSH_ASKPASS`
      posé dans `init.bash` — sans lui, ssh sans tty abandonne sans rien dire
- [x] amorçage décirculé : le clone se fait en **HTTPS**, le remote bascule en
      SSH une fois les clés régénérées. Cloner en SSH exigeait la clé sk, donc
      `ssh-keygen -K`, donc `libfido2`, donc `install.sh` — dans le dépôt visé
- [x] contrôle d'épinglage corrigé : ce n'est pas le NOMBRE de lignes
      `identityfile` qui compte (il y en a deux, une par token) mais leur
      nature — aucune clé logicielle ne doit y figurer

## Mises à jour automatiques (point 4)

- [x] `unattended-upgrades` installé et `APT::Periodic` posé par `install.sh` —
      les timers `apt-daily` tournaient déjà à vide, les deux moitiés manquaient
- [x] appliqué et vérifié sur la machine Pop : service `enabled`, premier
      passage effectif
- [x] rien d'équivalent sur Arch, délibérément (pas de dépôt de sécurité séparé)
- [ ] redémarrage automatique laissé désactivé : les correctifs de **noyau**
      attendent donc un reboot manuel. À faire de temps en temps, sciemment

## Sécurité

- [x] `gitleaks` (point 5) : installé par `install.sh` (binaire amont vérifié
      par empreinte sur Pop, paquet sur Arch), `.gitleaks.toml` avec allowlist
      structurelle, scan de l'index au `pre-commit` qui refuse le commit — et
      refuse aussi de tourner si gitleaks manque
- [ ] dérouler la procédure d'installation **complète** sur une machine vierge.
      Les deux trous trouvés le 21/08 (libfido2, clone SSH circulaire)
      n'existaient que sur le chemin jamais parcouru : Arch, machine neuve. Les
      relire ne les trouve pas, seul un vrai passage les trouve

Les faiblesses connues et **non corrigées** ne sont pas listées ici : une liste
de trous ouverts est une carte, pas une note de travail. Elles vivent dans
`secrets/todo-secu.age`, chiffré pour les deux YubiKeys :

```bash
dots-secrets unseal todo-secu   # lire
dots-secrets edit   todo-secu   # modifier, rescelle au passage
```

Le reste du dépôt peut rester public sans dommage : publier qu'on utilise
Tailscale et une YubiKey n'affaiblit rien, la sécurité ne tenant pas au secret
du dispositif. Ce qui ne doit pas l'être, ce sont les défauts encore ouverts.

## Divers

- [x] ~~pousser la branche et merger dans `master`~~ — fait, la machine Pop est validée
- [ ] uniformiser l'emplacement du repo entre les deux machines (`~/.dots` vs `~/.dotfiles`)
- [ ] `common/.config/nvim/colors/nurburgreen.lua` a encore la palette en dur —
      seul endroit qui ne dérive pas de `colors.toml`
- [ ] `bin/oh-my-posh` (19 Mo) reste dans l'historique git ; un `filter-repo`
      allégerait les clones, mais réécrit les hashes
- [ ] COSMIC : `corner_radii` laissé au barème stock, on pourrait l'aligner sur
      le `rounding = 10` d'Hyprland (voir `popos/README.md`)
