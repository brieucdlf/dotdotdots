-- Overrides personnels uniquement. Les raccourcis Omarchy par défaut :
--   omarchy menu keybindings --print
--
-- L'ancien bindings.conf de la v3 était le fichier stock d'Omarchy recopié,
-- avec une seule ligne à soi. Les défauts vivent maintenant dans
-- default/hypr/bindings/, chargés avant ce fichier : il ne reste que la ligne.

-- btop. Omarchy 4 le pose sur SUPER + CTRL + T ; il reste ici sur
-- SUPER + SHIFT + T, dans la même famille que les autres applications
-- (SHIFT + D docker, SHIFT + M musique). Le défaut n'est pas retiré : deux
-- touches pour la même chose ne gêne personne, et le retirer serait décider à
-- la place d'Omarchy sur un raccourci qu'on n'a jamais eu.
o.bind("SUPER + SHIFT + T", "Activity", { tui = "btop" })
