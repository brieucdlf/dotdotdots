-- Overrides personnels uniquement. Ce qui n'est pas ici garde sa valeur
-- Omarchy — voir /usr/share/omarchy/default/hypr/input.lua, chargé avant.
--
-- Ne rien recopier d'Omarchy « pour la lisibilité » : une valeur redite ici
-- fige le défaut du jour et ne bouge plus jamais avec les mises à jour. C'est
-- ce qui a rendu cette migration longue — l'ancien input.conf était une copie
-- du fichier stock de la v3, à quatre valeurs près.
hl.config({
  input = {
    -- us EN TÊTE, et c'est structurel : Hyprland résout les raccourcis sur la
    -- première disposition, pas sur celle qui est active. fr en second, la
    -- bascule se fait par le widget omarchy.keyboard-layout de la barre.
    kb_layout = "us,fr",

    -- 250 ms (défaut Omarchy) déclenche la répétition avant la fin d'un appui
    -- normal, et double des caractères en frappe rapide.
    repeat_delay = 600,

    touchpad = {
      natural_scroll = true,
      scroll_factor = 0.5,
    },
  },
})

-- Les scroll_touchpad par terminal (Alacritty, kitty, foot, ghostty) sont
-- passés dans le défaut Omarchy, aux mêmes valeurs. Rien à redire ici.
