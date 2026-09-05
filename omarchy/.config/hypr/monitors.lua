-- Voir https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Lister les sorties et leurs modes : hyprctl monitors all

-- Les applications GTK ne suivent pas le scale fractionnaire de Wayland : sans
-- GDK_SCALE elles rendent à l'échelle 1 puis se font agrandir, donc floues.
-- 1.76 et non 1.6 : GTK n'accepte pas toutes les valeurs, celle-ci est la plus
-- proche qui tienne. Relancer Hyprland après changement (Super+Esc, Relaunch).
hl.env("GDK_SCALE", "1.76")

-- Dalle interne 4K 13" : 1.6 est le compromis lisibilité / place utilisable.
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1.6 })

-- Écran externe : déjà à la bonne densité, aucun scaling.
hl.monitor({ output = "DP-3", mode = "preferred", position = "auto", scale = 1 })
