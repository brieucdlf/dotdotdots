#!/usr/bin/env bash
# Installe les dotfiles sur la machine courante. Idempotent : relançable à volonté.
#
#   ./install.sh                 # détecte le profil
#   ./install.sh --profile popos # force un profil
#   ./install.sh --no-packages   # stow + thème seulement, aucune install système
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
PROFILE=""
DO_PACKAGES=1
BACKED_UP=0

while [[ $# -gt 0 ]]; do
  case $1 in
    --profile)
      [[ $# -ge 2 ]] || { echo "--profile attend un nom de profil" >&2; exit 1; }
      PROFILE="$2"; shift 2 ;;
    --no-packages) DO_PACKAGES=0; shift ;;
    *) echo "option inconnue: $1" >&2; exit 1 ;;
  esac
done

say() { printf '\033[1;32m::\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }
have() { command -v "$1" &>/dev/null; }

# ── détection du profil ──────────────────────────────────────────────────────
detect_profile() {
  local id=""
  [[ -r /etc/os-release ]] && id="$(. /etc/os-release && echo "$ID")"
  if [[ -d $HOME/.local/share/omarchy ]]; then echo omarchy
  elif [[ $id == pop || $id == ubuntu || $id == debian ]]; then echo popos
  elif [[ $id == arch ]]; then echo omarchy
  else echo ""
  fi
}

[[ -n $PROFILE ]] || PROFILE="$(detect_profile)"
[[ -n $PROFILE ]] || { echo "profil indétectable, utilise --profile <omarchy|popos>" >&2; exit 1; }
[[ -d "$ROOT/$PROFILE" ]] || {
  echo "profil inconnu: $PROFILE (disponibles: omarchy popos)" >&2; exit 1; }
say "profil: $PROFILE"

# ── paquets système ──────────────────────────────────────────────────────────
bootstrap_popos() {
  say "paquets apt"
  sudo apt-get update -qq
  sudo apt-get install -y --no-install-recommends \
    stow tmux git curl unzip fontconfig ca-certificates jq python3

  # pcscd : l'accès CCID à l'applet PIV de la YubiKey, d'où age tire la clé de
  # déchiffrement des secrets. Sans lui, `dots-secrets` ne voit aucun token.
  sudo apt-get install -y --no-install-recommends pcscd
  enable_pcscd

  # Sans terminal, ssh ne demande PAS la passphrase : il appelle un programme
  # externe, et s'il n'en trouve aucun il abandonne sans rien afficher. Le
  # paquet enregistre /usr/bin/ssh-askpass via update-alternatives, chemin que
  # ssh cherche par défaut. Voir SSH_ASKPASS dans .config/bash/init.bash.
  sudo apt-get install -y --no-install-recommends ssh-askpass-gnome

  # Mises à jour de sécurité automatiques. apt-daily.timer et
  # apt-daily-upgrade.timer tournent DÉJÀ — le paquet apt les arme d'office —
  # mais sans unattended-upgrades ils n'ont rien à exécuter. Le mécanisme était
  # donc en place et ne faisait rien.
  sudo apt-get install -y --no-install-recommends unattended-upgrades
  setup_auto_updates

  # Erlang est compilé depuis les sources par mise (kerl) : sans ces headers,
  # le configure échoue sur "No curses library functions found" et entraîne
  # Elixir avec lui. Omarchy fournit déjà l'équivalent côté Arch.
  sudo apt-get install -y --no-install-recommends \
    build-essential autoconf m4 libncurses-dev libssl-dev

  if ! have mise; then
    say "installation de mise"
    curl -fsSL https://mise.run | sh
    export PATH="$HOME/.local/bin:$PATH"
  fi

  install_gitleaks
  setup_tailscale
  setup_webcam

  install_nerd_font
  install_ghostty_deb
}

bootstrap_omarchy() {
  say "paquets pacman"
  sudo pacman -S --needed --noconfirm stow jq python
  have mise || sudo pacman -S --needed --noconfirm mise
  # Voir bootstrap_popos : même rôle, noms de paquets Arch. ccid est le pilote
  # que pcsclite charge pour la YubiKey ; pcsclite seul ne suffit pas.
  sudo pacman -S --needed --noconfirm pcsclite ccid
  enable_pcscd

  # Voir bootstrap_popos. Arch n'a pas d'update-alternatives : le binaire garde
  # son nom propre, c'est SSH_ASKPASS qui fait le pont.
  sudo pacman -S --needed --noconfirm ksshaskpass

  # libfido2 : tout l'accès FIDO d'OpenSSH — clés sk, `ssh-keygen -K`. Debian
  # en fait une dépendance dure d'openssh-client, Arch une simple optdepend :
  # sans elle ssh-sk-helper ne se charge même pas, et l'échec ne parle ni de
  # FIDO ni de YubiKey ("libfido2.so.1: cannot open shared object file", puis
  # "unexpected internal error"). La YubiKey n'y est pour rien.
  sudo pacman -S --needed --noconfirm libfido2

  # Voir install_gitleaks : ici le dépôt suit l'amont, le paquet suffit.
  sudo pacman -S --needed --noconfirm gitleaks

  # Voir setup_tailscale : même rôle, et ici encore aucun `tailscale up`.
  sudo pacman -S --needed --noconfirm tailscale
  enable_tailscaled

  # Volontairement PAS d'équivalent d'unattended-upgrades ici. Arch n'a pas de
  # dépôt de sécurité séparé : automatiser, ce serait lancer un `pacman -Syu`
  # complet sans surveillance, avec son risque de mise à jour partielle et ses
  # interventions manuelles annoncées sur la page d'accueil. Sur Arch, la mise
  # à jour reste un geste conscient — c'est le contrat de la distribution.
  # ghostty, tmux, la police et le reste sont déjà fournis par Omarchy.
}

# Ce que l'installation du paquet ne fait pas : APT::Periodic reste à zéro tant
# que ce fichier n'existe pas, et unattended-upgrades ne s'exécute jamais.
# 1 = tous les jours. Les origines autorisées restent celles de la distribution
# (50unattended-upgrades), soit les dépôts de SÉCURITÉ uniquement : on ne veut
# pas qu'un poste de travail bascule de version majeure pendant la nuit.
#
# Pas de redémarrage automatique non plus : une machine de bureau qui redémarre
# seule fait perdre du travail. Les correctifs de noyau attendent donc le
# prochain reboot manuel, ce qui est le compromis habituel sur un poste.
setup_auto_updates() {
  local f=/etc/apt/apt.conf.d/20auto-upgrades
  local want='APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";'
  [[ -f $f ]] && [[ "$(cat "$f")" == "$want" ]] && return 0
  printf '%s\n' "$want" | sudo tee "$f" >/dev/null \
    && say "mises à jour de sécurité automatiques activées" \
    || warn "APT::Periodic non configuré — pas de mise à jour automatique"
}

# Le socket plutôt que le service : pcscd est activé à la demande, il ne tourne
# que le temps d'une opération sur le token au lieu de rester résident.
enable_pcscd() {
  systemctl is-enabled pcscd.socket &>/dev/null && return 0
  sudo systemctl enable --now pcscd.socket 2>/dev/null \
    || warn "pcscd non activé — 'dots-secrets' ne verra pas la YubiKey"
}

install_nerd_font() {
  local dir="$HOME/.local/share/fonts"
  if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font"; then
    say "JetBrainsMono Nerd Font déjà présente"; return 0
  fi
  say "installation de JetBrainsMono Nerd Font"
  mkdir -p "$dir"
  local tmp; tmp="$(mktemp -d)"
  if curl -fsSL -o "$tmp/jbm.zip" \
      https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip; then
    unzip -qo "$tmp/jbm.zip" -d "$dir/JetBrainsMono"
    fc-cache -f "$dir" >/dev/null
  else
    warn "téléchargement de la police échoué — à installer à la main"
  fi
  rm -rf "$tmp"
}

# Tailscale : le seul moyen d'ENTRER sur ces machines. Tout le reste du dépôt
# organise des flux sortants ; ici on ouvre une porte, et le choix de sa forme
# compte plus que sa configuration.
#
# Ce que la fonction ne fait PAS, délibérément : `tailscale up`. Rattacher la
# machine à un réseau est une décision, pas une étape d'installation — elle
# demande une authentification interactive et lie le poste à un compte. Le
# script installe la serrure ; c'est toi qui décides à quelle porte elle va.
#
# Aucun openssh-server n'est installé : voir README, « Accès distant ». Le SSH
# de Tailscale authentifie par l'identité du PAIR dans le réseau maillé, pas
# par une clé posée sur le téléphone — ce qui évite d'y déposer la clé
# logicielle qu'on vient de retirer partout ailleurs.
setup_tailscale() {
  have tailscale && { say "tailscale déjà présent"; enable_tailscaled; return 0; }
  say "installation de tailscale"

  local cn keyring list
  cn="$(. /etc/os-release && echo "${UBUNTU_CODENAME:-${VERSION_CODENAME:-noble}}")"
  keyring=/usr/share/keyrings/tailscale-archive-keyring.gpg
  list=/etc/apt/sources.list.d/tailscale.list

  if ! curl -fsSL "https://pkgs.tailscale.com/stable/ubuntu/$cn.noarmor.gpg" \
       | sudo tee "$keyring" >/dev/null; then
    warn "clé du dépôt tailscale non récupérée — rien installé"; return 0
  fi
  if ! curl -fsSL "https://pkgs.tailscale.com/stable/ubuntu/$cn.tailscale-keyring.list" \
       | sudo tee "$list" >/dev/null; then
    warn "liste du dépôt tailscale non récupérée — rien installé"; return 0
  fi

  sudo apt-get update -qq
  sudo apt-get install -y --no-install-recommends tailscale || {
    warn "installation de tailscale échouée"; return 0; }
  enable_tailscaled
}

# Le démon tourne mais n'est rattaché à rien tant que `tailscale up` n'a pas été
# lancé : il écoute, il ne rejoint aucun réseau, il n'expose rien.
enable_tailscaled() {
  systemctl is-enabled --quiet tailscaled 2>/dev/null && return 0
  sudo systemctl enable --now tailscaled \
    && say "tailscaled activé (aucun réseau rejoint — voir README, Accès distant)" \
    || warn "tailscaled non activé"
}

# ── webcam pilotable à distance ──────────────────────────────────────────────
# Voir README, « Caméra », et common/.local/bin/dots-cam. Volontairement côté
# popos seulement : la caméra est sur le poste fixe, et `ustreamer` n'est pas
# dans les dépôts officiels d'Arch.
#
# L'ajout au groupe `video` n'est pas du confort. Sans lui, l'accès à
# /dev/video0 ne tient qu'à l'ACL que logind pose pour la session graphique
# ACTIVE : la caméra marcherait tant qu'on est assis devant, et échouerait
# précisément quand on est loin — le seul moment où elle sert. Une reconnexion
# est nécessaire pour que le groupe prenne effet.
setup_webcam() {
  sudo apt-get install -y --no-install-recommends ustreamer v4l-utils fswebcam

  if id -nG "$USER" | tr ' ' '\n' | grep -qx video; then
    return 0
  fi
  sudo usermod -aG video "$USER" \
    && say "ajouté au groupe video — RECONNEXION nécessaire pour que ça prenne" \
    || warn "ajout au groupe video échoué : la caméra ne marchera que session ouverte"
}

# gitleaks : le dernier filet avant publication. .gitignore et le filtre autoMode
# ne couvrent que les fuites ANTICIPÉES — un chemin qu'on a pensé à interdire.
# gitleaks regarde le contenu, pas le nom du fichier.
#
# Volontairement PAS le paquet apt : Ubuntu livre 8.16 (mi-2023), dont le jeu de
# règles ignore par exemple les clés Anthropic (`sk-ant-`) — vérifié. Pour un
# scanner, la fraîcheur des règles EST la fonction ; une version figée donne
# surtout l'illusion d'être couvert. Arch suit l'amont, voir bootstrap_omarchy.
install_gitleaks() {
  have gitleaks && { say "gitleaks déjà présent ($(gitleaks version 2>/dev/null))"; return 0; }
  say "installation de gitleaks (binaire amont)"

  local tmp arch ver url sums
  case "$(uname -m)" in
    x86_64)  arch=x64 ;;
    aarch64) arch=arm64 ;;
    *) warn "architecture $(uname -m) non gérée pour gitleaks — installe-le à la main"; return 0 ;;
  esac

  ver="$(curl -fsSL https://api.github.com/repos/gitleaks/gitleaks/releases/latest \
        | grep -o '"tag_name": *"v[^"]*"' | head -1 | grep -o 'v[0-9.]*' || true)"
  [[ -n $ver ]] || { warn "version de gitleaks introuvable — passe"; return 0; }

  tmp="$(mktemp -d)"
  url="https://github.com/gitleaks/gitleaks/releases/download/$ver"
  if ! curl -fsSL -o "$tmp/gl.tar.gz" "$url/gitleaks_${ver#v}_linux_${arch}.tar.gz" \
     || ! curl -fsSL -o "$tmp/sums" "$url/gitleaks_${ver#v}_checksums.txt"; then
    warn "téléchargement de gitleaks échoué — passe"; rm -rf "$tmp"; return 0
  fi

  # Un scanner de secrets qu'on installe sans vérifier son empreinte, c'est se
  # fier au transfert pour l'outil censé ne pas se fier au reste.
  mv "$tmp/gl.tar.gz" "$tmp/gitleaks_${ver#v}_linux_${arch}.tar.gz"
  if ! (cd "$tmp" && sha256sum --ignore-missing -c sums >/dev/null 2>&1); then
    warn "empreinte SHA256 de gitleaks invalide — RIEN n'est installé"; rm -rf "$tmp"; return 1
  fi

  tar xzf "$tmp/gitleaks_${ver#v}_linux_${arch}.tar.gz" -C "$tmp" gitleaks \
    && install -Dm755 "$tmp/gitleaks" "$HOME/.local/bin/gitleaks" \
    && say "gitleaks $ver installé dans ~/.local/bin" \
    || warn "installation de gitleaks échouée"
  rm -rf "$tmp"
}

install_ghostty_deb() {
  have ghostty && { say "ghostty déjà présent"; return 0; }
  # Ghostty n'est ni dans les dépôts Ubuntu ni dans brew Linux.
  # Paquets non officiels mais maintenus : mkasberg/ghostty-ubuntu.
  say "installation de ghostty (.deb mkasberg/ghostty-ubuntu)"
  local relver tmp url
  # les .deb sont nommés ghostty_<ver>_amd64_<version ubuntu>.deb (ex: _24.04)
  relver="$(. /etc/os-release && echo "${VERSION_ID:-24.04}")"
  tmp="$(mktemp -d)"
  url="$(curl -fsSL https://api.github.com/repos/mkasberg/ghostty-ubuntu/releases/latest \
        | grep -o "https://[^\"]*_amd64_${relver}\.deb" | head -1 || true)"
  if [[ -z $url ]]; then
    warn "aucun .deb ghostty trouvé pour Ubuntu $relver — installe-le à la main:"
    warn "  https://github.com/mkasberg/ghostty-ubuntu/releases"
  elif curl -fsSL -o "$tmp/ghostty.deb" "$url"; then
    sudo apt-get install -y "$tmp/ghostty.deb"
  else
    warn "téléchargement de ghostty échoué: $url"
  fi
  rm -rf "$tmp"
}

# ATTENTION : toute fonction appelée depuis bootstrap_popos ou bootstrap_omarchy
# doit être définie AU-DESSUS de cette ligne. Bash lit le fichier de haut en bas
# et n'a pas connaissance d'une fonction déclarée plus bas : l'appel échoue sur
# un « command not found » qui ne dit pas que c'est un problème d'ordre.
if [[ $DO_PACKAGES -eq 1 ]]; then
  "bootstrap_$PROFILE"
else
  say "--no-packages : bootstrap système sauté"
fi

have stow || { echo "stow est requis" >&2; exit 1; }

# ── config git du dépôt (filtre de confidentialité + hooks) ──────────────────
# Le dépôt est public et common/.claude/settings.json porte un bloc
# autoMode.environment décrivant l'environnement de travail. Le filtre `clean`
# le retire à l'indexation ; la copie de travail le garde. Voir .gitattributes.
#
# `required = true` n'est pas décoratif : sans lui, un jq absent ou en erreur
# fait SILENCIEUSEMENT retomber git sur le contenu brut — le bloc partirait sur
# GitHub sans un mot. Avec, git refuse d'indexer plutôt que de publier.
setup_git_hygiene() {
  have jq || warn "jq absent : le filtre de confidentialité bloquera les commits (voulu)"
  git -C "$ROOT" config filter.claude-settings.clean ".githooks/claude-settings-filter clean"
  git -C "$ROOT" config filter.claude-settings.smudge ".githooks/claude-settings-filter smudge"
  git -C "$ROOT" config filter.claude-settings.required true
  git -C "$ROOT" config core.hooksPath .githooks
  say "filtre git de confidentialité configuré"
}

[[ -d "$ROOT/.git" ]] && setup_git_hygiene

# ── le poste fixe reste joignable ────────────────────────────────────────────
# Voir README, « Accès distant ». Une machine endormie n'a pas de tailscaled
# éveillé : elle est injoignable, et sans appareil allumé sur le LAN rien ne
# peut lui envoyer un Wake-on-LAN. Faute de relais, on renonce à la suspension
# automatique plutôt qu'à l'accès distant.
#
# L'écran, lui, continue de s'éteindre : ça économise l'essentiel sans couper
# le réseau. Seule la SUSPENSION est désactivée.
#
# Uniquement sur un châssis de bureau (3/4/6/7 au sens DMI) : sur un portable
# la suspension est un service rendu, pas une gêne, et le profil popos pourrait
# un jour tourner sur autre chose que cette tour.
setup_stay_awake() {
  local chassis f
  chassis="$(cat /sys/class/dmi/id/chassis_type 2>/dev/null || echo 0)"
  case "$chassis" in 3|4|6|7) ;; *) return 0 ;; esac

  f="$HOME/.config/cosmic/com.system76.CosmicIdle/v1/suspend_on_ac_time"
  [[ -d "${f%/*}" ]] || return 0                    # pas de COSMIC ici
  [[ -f $f && "$(cat "$f")" == "None" ]] && return 0

  # Format COSMIC : un Option<u64> sérialisé, sans retour à la ligne.
  if printf 'None' > "$f"; then
    say "suspension automatique désactivée (le poste doit rester joignable)"
  else
    warn "suspension auto NON désactivée — la machine sera injoignable endormie"
  fi
}

[[ $PROFILE == popos ]] && setup_stay_awake

# ── migration depuis l'ancien layout plat ────────────────────────────────────
# Avant e91b366 le dépôt ÉTAIT le paquet stow : tout vivait dans $ROOT/.config.
# Le refactor a renommé ces fichiers vers common/ et les profils, mais git ne
# déplace que ce qu'il suit : les fichiers ignorés (local.bash, zed/.env,
# tmux/plugins, dépendances nvim) restent échoués dans $ROOT/.config après un
# `git pull`, pendant que les liens de ~ pointent dans le vide.
# Bloc jetable : à supprimer une fois les deux machines passées.

# Déplace le contenu de $1 dans $2 sans jamais écraser — ce qui existe déjà côté
# paquet fait foi, le reste est signalé plutôt que perdu.
migrate_into() {
  local src="$1" dst="$2" e target
  for e in "$src"/* "$src"/.[!.]*; do
    [[ -e $e || -L $e ]] || continue
    target="$dst/${e##*/}"
    if [[ ! -e $target && ! -L $target ]]; then
      mv "$e" "$target"; say "migré: ${e#"$ROOT"/} -> ${target#"$ROOT"/}"
    elif [[ -d $e && ! -L $e && -d $target && ! -L $target ]]; then
      migrate_into "$e" "$target"
    else
      warn "conflit de migration, ancien gardé: ${e#"$ROOT"/}"
    fi
  done
  rmdir "$src" 2>/dev/null || true
}

migrate_flat_layout() {
  [[ -d "$ROOT/.config" ]] || return 0
  say "ancien layout détecté — migration de .config/ vers les paquets"
  local entry name dest pkg
  for entry in "$ROOT"/.config/* "$ROOT"/.config/.[!.]*; do
    [[ -e $entry || -L $entry ]] || continue
    name="${entry##*/}"
    # On ne migre que ce dont le nouveau layout a déjà un dossier : le reste
    # (values.yaml, Code/, alacritty/…) ne fait plus partie du repo et
    # atterrirait dans common/ non ignoré, donc à un doigt d'être committé.
    dest=""
    for pkg in common "$PROFILE"; do
      [[ -d "$ROOT/$pkg/.config/$name" ]] && { dest="$ROOT/$pkg/.config/$name"; break; }
    done
    [[ -n $dest ]] || { warn "orphelin de l'ancien layout, laissé tel quel: .config/$name"; continue; }
    migrate_into "$entry" "$dest"
  done
  rmdir "$ROOT/.config" 2>/dev/null \
    && say "migration terminée" \
    || warn "il reste des fichiers dans $ROOT/.config — à trier à la main"
}

migrate_flat_layout

# ── liens morts pointant dans le repo ────────────────────────────────────────
# Dès qu'un fichier est renommé ou supprimé côté repo, le lien correspondant
# dans ~ pend dans le vide. stow ne le reprend que s'il est relatif ET sous un
# chemin qu'il visite encore : un lien absolu, ou un dossier plié dont la cible
# a disparu (~/.config/bash après le refactor), il le déclare « not owned by
# stow » et avorte TOUT. Un lien mort ne contient rien : le retirer est sûr, et
# ça rend le script auto-réparant après n'importe quel renommage.
prune_dead_repo_links() {
  local l n=0
  while IFS= read -r -d '' l; do
    [[ -e $l ]] && continue                                   # cible vivante
    [[ "$(readlink -m "$l")" == "$ROOT"/* ]] || continue       # pas à nous
    rm -f "$l"; n=$((n + 1))
    warn "lien mort retiré: ${l#"$HOME"/}"
  done < <(
    find "$HOME" -maxdepth 1 -type l -print0 2>/dev/null
    find "$HOME/.config" "$HOME/.local/bin" -maxdepth 4 -type l -print0 2>/dev/null
    find "$HOME/.claude" -maxdepth 3 -type l -print0 2>/dev/null
  )
  [[ $n -gt 0 ]] && say "$n lien(s) mort(s) de l'ancienne config retiré(s)"
  return 0
}

prune_dead_repo_links

# ── mise à l'abri des fichiers qui bloqueraient stow ─────────────────────────
# stow refuse d'écraser un vrai fichier (ex: le ~/.bashrc par défaut de Pop!_OS).
# On déplace ces conflits dans ~/.dotfiles-backup/<horodatage>/ plutôt que de
# les perdre.

# Si un dossier parent de la cible est lui-même un lien vers l'EXTÉRIEUR du
# repo, la cible vit en réalité ailleurs : la déplacer irait modifier
# l'emplacement d'un tiers. On laisse stow signaler le conflit.
# Le lien vers l'intérieur du repo est exempté : c'est le tree-folding normal.
parent_is_foreign_link() {
  local p="${1%/*}"
  while [[ $p == "$HOME"/* ]]; do
    if [[ -L $p ]]; then
      [[ "$(readlink -m "$p" 2>/dev/null || true)" == "$ROOT"/* ]] || return 0
    fi
    p="${p%/*}"
  done
  return 1
}

backup_conflicts() {
  local pkgdir="$1" rel target resolved

  # 1) Les DOSSIERS d'abord. Un vrai dossier ne gêne pas — stow descend dedans.
  # Mais un lien étranger posé là où le paquet a un dossier (~/.config/nvim
  # pointant vers un autre dépôt, par exemple) fait avorter stow exactement
  # comme un fichier en conflit. On l'écarte en premier : les fichiers qu'il
  # contient disparaissent alors du passage suivant.
  while IFS= read -r -d '' src; do
    rel="${src#"$pkgdir"/}"
    target="$HOME/$rel"
    [[ -L $target ]] || continue
    [[ "$(readlink -m "$target" 2>/dev/null || true)" == "$ROOT"/* ]] && continue
    parent_is_foreign_link "$target" && continue
    mkdir -p "$BACKUP/$(dirname "$rel")"
    mv "$target" "$BACKUP/$rel"
    BACKED_UP=1
    warn "sauvegardé (lien de dossier): ~/$rel -> $BACKUP/$rel"
  done < <(find "$pkgdir" -mindepth 1 -type d -print0)

  # 2) puis les fichiers.
  while IFS= read -r -d '' src; do
    rel="${src#"$pkgdir"/}"
    target="$HOME/$rel"
    [[ -e $target || -L $target ]] || continue

    # -m et non -f : -f rend une chaîne VIDE dès qu'un composant intermédiaire
    # manque, ce qui est précisément le cas des liens de l'ancien layout. Avec
    # -f, un lien mort vers le repo tombait dans le filet « vit dans le repo »
    # ci-dessous et n'était jamais nettoyé.
    resolved="$(readlink -m "$target" 2>/dev/null || true)"

    # Déjà posé par un passage précédent. Attention : après tree-folding, le
    # parent est un lien mais $target n'en est pas un — il faut comparer les
    # chemins RÉSOLUS, sinon on déplace le fichier du repo lui-même.
    [[ $resolved == "$(readlink -m "$src")" ]] && continue

    # Lien mort — testé AVANT le filet ci-dessous, sinon les liens morts qui
    # pointent dans le repo y échappent.
    if [[ -L $target && ! -e $target ]]; then rm -f "$target"; continue; fi

    # Filet de sécurité : ne jamais déplacer quoi que ce soit qui vit dans le repo.
    [[ $resolved == "$ROOT"/* ]] && continue

    parent_is_foreign_link "$target" && continue

    # Un lien étranger bloque stow aussi sûrement qu'un vrai fichier, et le
    # laisser passer coûte cher : stow avorte TOUT (« All operations aborted »)
    # alors qu'on a déjà écarté les vrais fichiers — la machine se retrouve
    # sans l'ancienne config ni la nouvelle. C'est ce qu'a produit le lien
    # ~/.config/nvim/lua/plugins/theme.lua posé par Omarchy vers son thème
    # courant. On le sauvegarde comme le reste : `mv` déplace le lien lui-même,
    # pas sa cible, donc rien n'est perdu et le rejouer est trivial.
    mkdir -p "$BACKUP/$(dirname "$rel")"
    mv "$target" "$BACKUP/$rel"
    BACKED_UP=1
    warn "sauvegardé: ~/$rel -> $BACKUP/$rel"
  done < <(find "$pkgdir" -type f -print0)
}

# ── reprise du settings.json de Claude Code ──────────────────────────────────
# Claude Code réécrit ~/.claude/settings.json tout seul (thème, effort, plugins
# activés). S'il le fait en temp + rename — comme cosmic-settings, voir
# post_popos — le lien posé par stow devient un vrai fichier et la synchro
# s'arrête SANS RIEN DIRE : c'est le pire mode de panne, on ne s'en aperçoit
# qu'en constatant que la config ne suit plus.
#
# Le témoin est indispensable : sans lui, on ne distingue pas « le lien a été
# écrasé ici » de « première install sur une machine qui a déjà sa config » — et
# on recopierait la config locale par-dessus celle du dépôt. Le témoin n'existe
# que si stow est déjà passé sur cette machine.
STAMP="$HOME/.claude/.dots-stowed"

reclaim_claude_settings() {
  local live="$HOME/.claude/settings.json" repo="$ROOT/common/.claude/settings.json"
  [[ -f $repo && -f $STAMP ]] || return 0
  [[ -f $live && ! -L $live ]] || return 0       # encore un lien : rien à faire
  cmp -s "$live" "$repo" && return 0
  cp -f "$live" "$repo"
  warn "lien ~/.claude/settings.json remplacé par un fichier — contenu récupéré dans le dépôt"
}

reclaim_claude_settings

backup_conflicts "$ROOT/common"
backup_conflicts "$ROOT/$PROFILE"

# ── stow ─────────────────────────────────────────────────────────────────────
# Les deux paquets sont stowés en UNE invocation, pas deux. Sinon stow traite
# `common` puis `$PROFILE` séparément et refuse de déplier un dossier posé par
# l'autre passage : « existing target is not owned by stow: .config/ghostty ».
# C'est ce qui bloque dès qu'un profil ajoute un fichier dans un dossier que
# common a déjà plié en un seul lien.
# ~/.ssh doit exister AVANT stow, et en vrai dossier. Sinon stow le plie en un
# lien vers common/.ssh — et le premier ssh-keygen écrit ses clés privées dans
# le dépôt, public. Le créer d'abord force stow à ne lier que `config` dedans.
# Même piège que ~/.config/git, qui est bien un lien : là c'est voulu, ici non.
mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
# ssh ne crée pas le dossier de sockets du multiplexage et échoue sans bruit.
mkdir -p "$HOME/.ssh/sockets" && chmod 700 "$HOME/.ssh/sockets"

say "stow common + $PROFILE"
if ! stow --dir="$ROOT" --target="$HOME" --restow common "$PROFILE"; then
  # stow avorte tout ou rien : aucun lien n'a été posé ni retiré. Mais
  # backup_conflicts, lui, a déjà écarté ce qui gênait — sans ce message on
  # laisse une machine sans ancienne config ni nouvelle, et sans explication.
  warn "stow a refusé de continuer (conflit ci-dessus) — aucun lien posé."
  [[ $BACKED_UP -eq 1 ]] && warn "les fichiers déjà écartés sont dans $BACKUP"
  warn "règle le conflit puis relance ./install.sh"
  exit 1
fi

[[ -d "$ROOT/common/.claude" ]] && touch "$STAMP"

# ── thème ────────────────────────────────────────────────────────────────────
say "rendu du thème"
"$ROOT/theme/render.sh" nurburgreen "$HOME/.config/theme/current"

# ── outils ───────────────────────────────────────────────────────────────────
if [[ $DO_PACKAGES -eq 1 ]] && have mise; then
  say "mise install (peut être long au premier passage)"
  mise install -y || warn "certains outils mise ont échoué — relance 'mise install'"
fi

# ── secrets ──────────────────────────────────────────────────────────────────
# Les secrets sont chiffrés dans le repo et ne s'ouvrent qu'avec la YubiKey.
# Non bloquant DÉLIBÉRÉMENT : une machine sans token doit quand même finir son
# install avec un shell fonctionnel — il lui manquera seulement les clés API.
say "secrets"
if [[ -x "$ROOT/common/.local/bin/dots-secrets" ]]; then
  export PATH="$HOME/.local/share/mise/shims:$PATH"
  if "$ROOT/common/.local/bin/dots-secrets" unseal; then
    # Les cibles actuelles vivent sous des dossiers pliés, où un fichier neuf
    # apparaît sans rien faire. Ce restow est là pour le jour où un secret
    # atterrira dans un dossier déplié fichier par fichier (~/.config/zed, par
    # exemple, que Zed remplit de thèmes) : là, stow ne le lie qu'au passage
    # suivant.
    stow --dir="$ROOT" --target="$HOME" --restow common "$PROFILE" || true
  else
    warn "secrets non déchiffrés — branche la YubiKey puis 'dots-secrets unseal'"
  fi
fi

# ── tpm ──────────────────────────────────────────────────────────────────────
TPM="$HOME/.config/tmux/plugins/tpm"
if [[ ! -d $TPM ]]; then
  say "installation de tpm"
  git clone -q https://github.com/tmux-plugins/tpm "$TPM"
  "$TPM/bin/install_plugins" >/dev/null || warn "install des plugins tmux à refaire (prefix + I)"
fi

# ── spécifique au profil ─────────────────────────────────────────────────────
post_omarchy() {
  # Le thème reste piloté par le repo ; Omarchy le voit comme un thème normal.
  local dst="$HOME/.config/omarchy/themes/nurburgreen"
  mkdir -p "$(dirname "$dst")"
  ln -sfn "$ROOT/theme/nurburgreen" "$dst"
  say "thème lié dans le sélecteur Omarchy"
  have omarchy && omarchy restart waybar &>/dev/null || true
}

post_popos() {
  # COSMIC lui-même (raccourcis, panel, dock) n'est pas géré ici — par choix.
  # Seul le thème est fourni, pour que le desktop soit dans la même palette que
  # le terminal.
  local src="$HOME/.config/theme/current/cosmic-nurburgreen-dark.ron"
  if [[ -f $src ]]; then
    mkdir -p "$HOME/.local/share/cosmic-themes"
    cp -f "$src" "$HOME/.local/share/cosmic-themes/"
    say "thème COSMIC disponible : $src"
    say "  à importer via Réglages > Apparence > Importer un thème"
  fi

  # Polices. Elles ne font pas partie du thème : le schéma .ron n'a aucun champ
  # de typo, COSMIC les range dans com.system76.CosmicTk.
  # On copie plutôt qu'on ne symlink : cosmic-settings réécrit ces fichiers de
  # façon atomique (temp + rename), ce qui remplacerait un lien par un fichier.
  local tk_src="$ROOT/theme/cosmic/tk" tk_dst="$HOME/.config/cosmic/com.system76.CosmicTk/v1"
  if [[ -d $tk_src && -d $tk_dst ]]; then
    cp -f "$tk_src"/* "$tk_dst"/
    say "polices COSMIC posées (interface + monospace)"
  fi

  # Override ghostty : copié et non stowé, voir popos/.stow-local-ignore.
  local gs="$ROOT/popos/.config/ghostty/local.conf"
  if [[ -f $gs ]]; then
    cp -f "$gs" "$HOME/.config/ghostty/local.conf"
    say "override ghostty posé (opacité sans blur COSMIC)"
  fi

  # Signal stocke ses clés en CLAIR par défaut (les backends chiffrés ont eu des
  # bugs de corruption) et repose la question à chaque démarrage. gnome-libsecret
  # fonctionne ici parce que gnome-keyring-daemon tourne sous COSMIC et que le
  # manifeste du flatpak accorde déjà org.freedesktop.secrets=talk.
  # --user est indispensable : l'install est en user, un override système
  # n'aurait aucun effet (et demanderait root pour rien).
  if have flatpak && flatpak info org.signal.Signal &>/dev/null; then
    flatpak override --user --env=SIGNAL_PASSWORD_STORE=gnome-libsecret org.signal.Signal
    say "Signal : clés dans le trousseau (gnome-libsecret)"
  fi
}

"post_$PROFILE"

say "terminé. Ouvre un nouveau terminal (ou 'exec bash') pour recharger le shell."
[[ $BACKED_UP -eq 1 ]] && warn "des fichiers ont été sauvegardés dans $BACKUP"
exit 0
