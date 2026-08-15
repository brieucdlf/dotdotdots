# Profil Pop!_OS

Volontairement quasi vide.

COSMIC gère son propre desktop et n'est **pas** piloté par ces dotfiles : ses
raccourcis et sa barre n'ont pas d'équivalent transposable depuis Hyprland/Waybar.
Ce qui est partagé avec la machine Omarchy vit dans `common/` — terminal, shell,
tmux, neovim, thème, outils.

Si un jour tu passes cette machine sous Hyprland, la bascule consiste à déplacer
`profiles/omarchy/.config/{hypr,waybar}` vers `common/` et à ne laisser dans les
profils que `monitors.conf` et les modules Waybar liés à Omarchy.
