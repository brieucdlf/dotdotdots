-- Voir https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config({
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

-- Flou derrière la barre, pour qu'elle se pose sur le fond d'écran comme le
-- terminal. Le namespace a changé avec Omarchy 4 : waybar a disparu au profit
-- du shell Quickshell, dont la couche s'appelle omarchy-bar.
hl.layer_rule({ match = { namespace = "omarchy-bar" }, blur = true })

-- Les couleurs de bordure ne sont plus ici. Elles viennent du thème, via
-- hyprland_active_border / hyprland_inactive_border dans colors.toml, rendues
-- par default/themed/hyprland.lua.tpl. Ce fichier est chargé APRÈS le thème :
-- y remettre col.active_border écraserait N'IMPORTE quel thème, y compris
-- après en avoir changé — l'ancien looknfeel.conf faisait exactement ça.
