# Écran de verrouillage. L'ancien hyprlock.conf n'a pas d'équivalent en
# Omarchy 4 : le verrouillage est passé dans le shell Quickshell, qui dessine
# un champ de saisie sur le fond d'écran et se thème par ces clés — la carte de
# verre dépoli, la photo de profil et l'horloge géante ne sont plus exprimables.
# Ce qui l'est, et qui comptait, c'est la couleur de l'échec.
#
# Section entière remplacée, comme shell.bar.toml.tpl : tout ce qui n'est pas
# repris ici disparaîtrait du bloc [lock].

[lock]
background       = "{{ background }}"
background-alpha = 0.8
text             = "{{ foreground }}"
placeholder      = "{{ mix foreground background 34% }}"
# bright_red, pas red : ce qui signale un mot de passe refusé doit se voir. Sur
# une palette sombre le rouge ANSI est une teinte de fond — l'ancien hyprlock
# écrivait d'ailleurs son fail_color en dur, rgba(160, 96, 48), qui est
# exactement le bright_red de nurburgreen.
text-error       = "{{ bright_red }}"
border           = "hyprland.active-border"
border-active    = "hyprland.active-border"
border-error     = "{{ bright_red }}"
border-alpha     = 1.0
selection        = "{{ accent }}"
selection-alpha  = 0.45
