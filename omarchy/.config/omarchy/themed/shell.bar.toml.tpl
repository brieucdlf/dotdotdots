# Barre translucide, comme l'ancien waybar/style.css :
#   window#waybar { background-color: rgba(14, 16, 14, 0.30); }
# Le flou derrière vient de hypr/looknfeel.lua (layer_rule sur omarchy-bar).
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
background-alpha = 0.30
text             = "{{ foreground }}"
# Modules qui réclament l'attention (enregistrement, dictée, mises à jour).
# bright_red et non red : sur une palette sombre comme nurburgreen, le rouge
# ANSI est une teinte de fond, pas un signal.
active           = "{{ bright_red }}"
scale-with-font  = true
size-horizontal  = 26
size-vertical    = 28
