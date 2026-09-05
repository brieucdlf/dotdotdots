# Barre SANS fond du tout. L'assombrissement qui rend son texte lisible n'est
# plus peint par elle : il est cuit dans le fond d'écran du thème (voir
# theme/kreide/assets/README.md — le haut de l'image descend jusqu'à 93 %
# d'opacité). Peindre en plus un fond à 0.30 par-dessus, comme le faisait
# l'ancien waybar/style.css, assombrirait deux fois.
#
# La layer_rule de flou sur omarchy-bar est retirée pour la même raison : sans
# fond, elle ne floutait plus que le fond d'écran lui-même, en bande.
#
# CONSÉQUENCE POUR TOUT THÈME : ce gabarit vaut pour TOUS, donc le fond d'écran
# de chacun DOIT porter cet assombrissement du haut, sinon son texte de barre
# se pose à nu sur la photo. Mesuré sur nurburgreen avant traitement : 1,67:1
# sur les zones claires. Les deux thèmes du dépôt l'ont ; la recette est dans
# theme/<nom>/assets/README.md.
#
# C'est un fichier de SECTION : Omarchy remplace le bloc [bar] de son
# shell.toml par celui-ci, en entier — d'où les cinq lignes recopiées du
# gabarit stock autour de la seule qui change, background-alpha. Une clé [bar]
# ajoutée en amont ne nous parviendra pas tant qu'elle n'est pas reprise ici.
#
# Rendu depuis colors.toml du thème courant, donc valable pour TOUS les thèmes
# et sans une seule couleur en dur : c'est ce qui permet de le poser dans
# ~/.config/omarchy/themed/ plutôt que dans theme/nurburgreen/, où il faudrait
# écrire les hexadécimaux à la main.

[bar]
background       = "{{ background }}"
background-alpha = 0.0
text             = "{{ foreground }}"
# Modules qui réclament l'attention (enregistrement, dictée, mises à jour).
# bright_red et non red : sur une palette sombre comme nurburgreen, le rouge
# ANSI est une teinte de fond, pas un signal.
active           = "{{ bright_red }}"
scale-with-font  = true
size-horizontal  = 26
size-vertical    = 28
