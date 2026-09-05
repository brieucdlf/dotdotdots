-- Voir https://wiki.hypr.land/Configuring/Basics/Variables/

-- Sans gouttières, mais avec des coins arrondis.
--
-- Ces trois-là venaient du bouton « Toggle window gaps » (SUPER + SHIFT +
-- BACKSPACE), qui copie default/hypr/toggles/window-no-gaps.lua dans
-- ~/.local/state/omarchy/toggles/hypr/. Ce dossier est requis à la TOUTE
-- DERNIÈRE ligne de hyprland.lua, donc il gagne sur ce fichier — et il ne
-- coupait pas que les gouttières : il posait aussi rounding = 0.
--
-- Or `Style.cornerRadius` du shell est lu en direct depuis
-- decoration:rounding par hyprctl. Un seul nombre arrondit donc les fenêtres
-- ET tout le shell : barre, menus, panneaux, verrouillage, lanceur. À zéro,
-- rien n'était arrondi nulle part.
--
-- Le bouton est donc éteint, et ce qu'on voulait vraiment de lui — pas de
-- gouttières, pas de bordure — est écrit ici, où l'arrondi survit.
hl.config({
  general = {
    gaps_in = 0,
    gaps_out = 0,
    border_size = 0,
  },

  decoration = {
    rounding = 10,

    -- Le flou est désactivé par défaut chez Omarchy. Il est ici la contrepartie
    -- de la transparence : le terminal et la barre laissent passer le fond, le
    -- flou empêche que ce fond devienne du bruit derrière le texte.
    blur = {
      enabled = true,
      size = 12,
      passes = 4,
      brightness = 0.82,
      contrast = 0.9,
      noise = 0.015,
      new_optimizations = true,
    },

    shadow = {
      enabled = true,
      range = 12,
      render_power = 3,
      color = "rgba(0c181088)",
    },
  },
})

-- Pas de flou sur la barre. Elle ne peint plus aucun fond (background-alpha à
-- 0 dans themed/shell.bar.toml.tpl) : flouter derrière une surface vide ne
-- donne pas du verre, ça donne une bande de 26 px de fond d'écran flouté et
-- assombri par `brightness`, avec une couture nette sous la barre. Le noir qui
-- rend son texte lisible est cuit dans l'image du thème.
--   À remettre le jour où background-alpha remonte au-dessus de 0 :
--   hl.layer_rule({ match = { namespace = "omarchy-bar" }, blur = true })

-- Les couleurs de bordure ne sont plus ici. Elles viennent du thème, via
-- hyprland_active_border / hyprland_inactive_border dans colors.toml, rendues
-- par default/themed/hyprland.lua.tpl. Ce fichier est chargé APRÈS le thème :
-- y remettre col.active_border écraserait N'IMPORTE quel thème, y compris
-- après en avoir changé — l'ancien looknfeel.conf faisait exactement ça.

-- Le lanceur par catégories (plugin brieuc.launcher). Sa dalle est translucide
-- pour que le rail opaque s'en détache : sans flou derrière, cette translucidité
-- ne donne pas du verre, elle donne du fond d'écran lisible à travers le texte.
hl.layer_rule({ match = { namespace = "omarchy-launcher" }, blur = true })
