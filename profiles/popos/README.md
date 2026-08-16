# Profil Pop!_OS

COSMIC gère son propre desktop et n'est **pas** piloté par ces dotfiles : ses
raccourcis, son panel et son dock n'ont pas d'équivalent transposable depuis
Hyprland/Waybar. Ce qui est partagé avec la machine Omarchy vit dans `common/` —
terminal, shell, tmux, neovim, thème, outils.

## Thème COSMIC

Seule exception : le **thème**, pour que le desktop soit dans la même palette
que le terminal. `theme/render.sh` génère un fichier importable depuis
`colors.toml`, et `install.sh` le dépose dans deux endroits :

```
~/.config/theme/current/cosmic-nurburgreen-dark.ron
~/.local/share/cosmic-themes/cosmic-nurburgreen-dark.ron
```

Import : **Réglages > Apparence > Importer un thème**, puis choisir le fichier.

Ce qui est personnalisé par rapport au thème sombre stock :

| Clé | Valeur | Pourquoi |
|---|---|---|
| `bg_color` | `#001a0f` | le fond BRG du terminal |
| `accent` | `#f0c000` | GT Yellow — le seul ton de la palette assez contrasté sur `#001a0f` pour rester lisible en texte de lien |
| `text_tint` | `#d4b88a` | cuir cognac |
| `neutral_tint` | `#6d7a6d` | même clarté que le gris neutre stock, teinte décalée vers le vert, pour retrouver la famille carbone BRG |
| `success` / `warning` / `destructive` | `#0a6b38` / `#f5d020` / `#a06030` | vert BRG, GT Yellow vif, cognac plein soleil |
| `window_hint` | `#d4b88a` | reprend `col.active_border` d'Hyprland |
| `active_hint` | `2` | reprend `border_size = 2` d'Hyprland |
| `is_frosted` | `true` | pour retrouver la translucidité du blur Hyprland / de Ghostty |

Le bloc `palette` est repris **tel quel** du thème système : il est strictement
identique dans tous les thèmes livrés par COSMIC (`mocha-dark` et `nebula-dark`
ne diffèrent que par la queue du fichier), c'est la palette sémantique du
design system, pas une palette de terminal. On ne personnalise donc que ce que
COSMIC prévoit de personnalisable.

`install.sh` n'écrit **pas** directement dans
`com.system76.CosmicTheme.Dark.Builder` : le thème dérivé est reconstruit par
cosmic-settings, écrire les clés à la main ne l'appliquerait pas de façon
fiable et casserait la session en cas d'erreur.

## Si tu passes cette machine sous Hyprland

La bascule consiste à déplacer `profiles/omarchy/.config/{hypr,waybar}` vers
`common/` et à ne laisser dans les profils que `monitors.conf` et les modules
Waybar liés à Omarchy.
