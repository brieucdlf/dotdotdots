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

La rampe neutre (`neutral_0..10`, `gray_1/2`) est surchargée avec les carbones
BRG : c'est elle qui porte tout le chrome de COSMIC. Le reste de la palette —
`accent_*`, `bright_*`, `ext_*` — est la palette sémantique stock du design
system, reprise telle quelle.

## ⚠️ Le piège du schéma

Il existe **deux formats** de thème COSMIC, et le mauvais échoue silencieusement.

Les fichiers livrés dans `/usr/share/cosmic-themes/` (`mocha-dark.ron`,
`nebula-dark.ron`) sont dans un format **ancien** : couleurs en structs de
flottants, `is_frosted: bool`, pas d'`alpha_map`. Les prendre pour gabarit
produit un fichier qui **s'importe et s'applique visuellement, mais ne persiste
pas** — après import, aucun fichier de `~/.config/cosmic` ne contient les
couleurs du thème, et il est perdu à la fermeture de session.

Le schéma réellement attendu est celui des thèmes communautaires
([KodeBarista/cosmic-themes](https://github.com/KodeBarista/cosmic-themes)) :

| | ancien (`/usr/share`) | courant |
|---|---|---|
| couleurs | `Some((red: 0.94, green: …))` | `Some("#F0C000FF")` |
| flou | `is_frosted: false` | `frosted: Medium` + `frosted_windows`/`_panel`/`_applets`/`_system_interface` |
| transparence | absent | bloc `alpha_map` |

`render.sh` génère le format courant. Sa structure est vérifiable par diff
contre n'importe quel thème du repo communautaire : seules les valeurs doivent
différer.

## Si tu passes cette machine sous Hyprland

La bascule consiste à déplacer `profiles/omarchy/.config/{hypr,waybar}` vers
`common/` et à ne laisser dans les profils que `monitors.conf` et les modules
Waybar liés à Omarchy.
