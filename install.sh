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

while [[ $# -gt 0 ]]; do
  case $1 in
    --profile) PROFILE="$2"; shift 2 ;;
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
[[ -d "$ROOT/profiles/$PROFILE" ]] || { echo "profil inconnu: $PROFILE" >&2; exit 1; }
say "profil: $PROFILE"

# ── paquets système ──────────────────────────────────────────────────────────
bootstrap_popos() {
  say "paquets apt"
  sudo apt-get update -qq
  sudo apt-get install -y --no-install-recommends \
    stow tmux git curl unzip fontconfig ca-certificates

  if ! have mise; then
    say "installation de mise"
    curl -fsSL https://mise.run | sh
    export PATH="$HOME/.local/bin:$PATH"
  fi

  install_nerd_font
  install_ghostty_deb
}

bootstrap_omarchy() {
  say "paquets pacman"
  sudo pacman -S --needed --noconfirm stow
  have mise || sudo pacman -S --needed --noconfirm mise
  # ghostty, tmux, la police et le reste sont déjà fournis par Omarchy.
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

if [[ $DO_PACKAGES -eq 1 ]]; then
  "bootstrap_$PROFILE"
else
  say "--no-packages : bootstrap système sauté"
fi

have stow || { echo "stow est requis" >&2; exit 1; }

# ── mise à l'abri des fichiers qui bloqueraient stow ─────────────────────────
# stow refuse d'écraser un vrai fichier (ex: le ~/.bashrc par défaut de Pop!_OS).
# On déplace ces conflits dans ~/.dotfiles-backup/<horodatage>/ plutôt que de
# les perdre.
backup_conflicts() {
  local pkgdir="$1" rel target
  while IFS= read -r -d '' src; do
    rel="${src#"$pkgdir"/}"
    target="$HOME/$rel"
    [[ -e $target || -L $target ]] || continue
    [[ -L $target && "$(readlink -f "$target")" == "$(readlink -f "$src")" ]] && continue
    [[ -L $target && ! -e $target ]] && { rm -f "$target"; continue; }  # lien mort
    [[ -L $target ]] && continue        # symlink vers autre chose: stow gérera
    mkdir -p "$BACKUP/$(dirname "$rel")"
    mv "$target" "$BACKUP/$rel"
    warn "sauvegardé: ~/$rel -> $BACKUP/$rel"
  done < <(find "$pkgdir" -type f -print0)
}

backup_conflicts "$ROOT/common"
backup_conflicts "$ROOT/profiles/$PROFILE"

# ── stow ─────────────────────────────────────────────────────────────────────
say "stow common"
stow --dir="$ROOT" --target="$HOME" --restow common
say "stow profiles/$PROFILE"
stow --dir="$ROOT/profiles" --target="$HOME" --restow "$PROFILE"

# ── thème ────────────────────────────────────────────────────────────────────
say "rendu du thème"
"$ROOT/theme/render.sh" nurburgreen "$HOME/.config/theme/current"

# ── outils ───────────────────────────────────────────────────────────────────
if [[ $DO_PACKAGES -eq 1 ]] && have mise; then
  say "mise install (peut être long au premier passage)"
  mise install -y || warn "certains outils mise ont échoué — relance 'mise install'"
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
  say "COSMIC n'est pas géré par ces dotfiles (par choix) — rien à faire"
}

"post_$PROFILE"

say "terminé. Ouvre un nouveau terminal (ou 'exec bash') pour recharger le shell."
[[ -d $BACKUP ]] && warn "des fichiers ont été sauvegardés dans $BACKUP"
exit 0
