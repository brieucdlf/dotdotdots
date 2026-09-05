# Section [launcher] — lue par le plugin brieuc.launcher (dépôt séparé), un
# rail de catégories avec sa grille d'applications. Omarchy ship déjà cette
# section pour son ancien lanceur ; plus rien dans son shell ne la consomme,
# alors le plugin la reprend telle quelle plutôt que d'inventer un namespace.
#
# Fichier de SECTION : Omarchy remplace le bloc [launcher] de son shell.toml
# par celui-ci EN ENTIER — d'où les douze lignes recopiées du gabarit stock
# autour des trois qui changent.
#
# Ce qui change, et pourquoi :
#
#   background-alpha  0.95 → 0.72. Le stock dit « to preserve the legacy
#   translucency » : à 0.95 il n'y a pas de verre, juste une carte presque
#   opaque, et le flou posé sur la couche omarchy-launcher (hypr/looknfeel.lua)
#   ne sert à rien. 0.72 laisse le fond d'écran remonter.
#
#   rail / rail-alpha  RETIRÉS. C'est la bande opaque de gauche, et elle doit
#   rester plus sombre que le verre — la catégorie ouverte n'est pas un bouton
#   posé sur le rail, c'est un trou découpé dedans, et un trou ne se voit que
#   si ses deux côtés ne se ressemblent pas. Mais ce fichier est rendu pour
#   TOUS les thèmes, y compris les quinze d'Omarchy, et `launcher_rail`
#   n'existe que dans les nôtres. Le moteur ne substitue que les clés qu'il
#   connaît (omarchy-theme-set-templates construit un script sed à partir de
#   colors.toml) et laisse les autres TELLES QUELLES : sous tokyo-night, la
#   ligne garderait le gabarit non substitué, accolades comprises. C'est du TOML
#   valide, donc rien n'échoue — le plugin reçoit juste une couleur qui n'en
#   est pas, et son repli (assombrir `background` lui-même) ne se déclenche
#   pas, puisque la clé est présente mais fausse. Une clé absente, elle, le
#   déclenche. `launcher_rail` reste dans nos colors.toml : c'est le plugin
#   qui doit la lire, pas ce gabarit partagé.

[launcher]
# La police proportionnelle des libellés. Le shell d'Omarchy est tout en mono
# (`Style.fontFamily` vaut "monospace") : la maquette, elle, oppose une
# grotesque pour ce qui se LIT — le titre, les noms d'applications — à la mono
# pour ce qui se COMPTE. Vidée, le plugin reprend la police du shell.
# La maquette utilisait Archivo ; ici Noto Sans, la seule grotesque neutre
# déjà installée. `fc-list : family` pour voir ce que la machine propose.
font                      = "Noto Sans"
background                = "{{ background }}"
background-alpha          = 0.72
text                      = "{{ foreground }}"
border                    = "hyprland.active-border-foreground"
border-alpha              = 1.0
scrim                     = "{{ background }}"
scrim-alpha               = 0.5
selected-background       = "{{ foreground }}"
selected-background-alpha = 0.08
selected-text             = "{{ accent }}"
selected-border           = "hyprland.active-border-foreground"
selected-border-alpha     = 0.25
