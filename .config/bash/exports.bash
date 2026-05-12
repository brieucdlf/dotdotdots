#!/bin/bash
# Pure exports — Omarchy gère déjà : mise, zoxide, fzf, starship, eza, brew

# PATH
export PATH="$HOME/.local/bin:$PATH"
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"
export PATH="$PATH:/usr/bin/mongosh"
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# fzf — nurburgreen palette
export FZF_DEFAULT_OPTS=" \
--color=bg+:#0d3326,bg:#001a0f,spinner:#d4b88a,hl:#f0c000 \
--color=fg:#d4b88a,header:#8a6835,info:#8a6835,pointer:#f0c000 \
--color=marker:#f0c000,fg+:#e0cba0,prompt:#2a5a3a,hl+:#f5d020 \
--border='rounded' --border-label='' --preview-window='border-rounded' --prompt='> ' \
--marker='>' --pointer='◆' --separator='─' --scrollbar='│' \
--layout='reverse' --info='right' --height=80%"

export FZF_DEFAULT_COMMAND="fd --type f"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# eza — couleurs explicites, pas de jaune, contraste clair
export EZA_COLORS="\
di=1;38;2;212;184;138:\
ln=38;2;45;128;96:\
ex=38;2;10;107;56:\
da=38;2;138;104;53:\
sn=38;2;180;160;122:\
sb=38;2;138;104;53:\
uu=1;38;2;224;203;160:\
gu=38;2;138;104;53:\
ur=38;2;42;90;58:\
uw=38;2;160;96;48:\
ux=38;2;10;107;56:\
gr=2;38;2;42;90;58:\
gw=2;38;2;160;96;48:\
gx=2;38;2;10;107;56:\
tr=2;38;2;42;90;58:\
tw=2;38;2;160;96;48:\
tx=2;38;2;10;107;56"
