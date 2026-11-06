# Consignes communes

Lu par les trois agents : `~/.claude/CLAUDE.md` (Claude Code),
`~/.codex/AGENTS.md` (Codex) et `~/.config/opencode/AGENTS.md` (OpenCode) sont
le même fichier, `common/.claude/CLAUDE.md` dans les dotfiles. Les consignes
d'un projet vont dans son `AGENTS.md`, que les trois lisent aussi.

- Réponds en français.
- Les commits sont signés par une YubiKey qu'il faut toucher : ne committe ni
  ne pousse toi-même. Indexe les changements, puis donne la commande à lancer.
- Aucune ligne d'attribution (Co-Authored-By, « Generated with ») dans les
  commits ni dans les PR.
- `sudo` ne marche pas depuis un agent (pas de TTY) : donne la commande à
  lancer dans un vrai terminal.
- Deux machines, Pop!_OS (perso) et Omarchy (pro), partagent les dotfiles
  (`~/.dotfiles`, stow). Un réglage durable passe par les dotfiles, pas par une
  modification locale qui ne vivrait que sur une machine.
