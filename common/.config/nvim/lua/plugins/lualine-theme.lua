-- La barre lualine suit le colorscheme chargé, au lieu de figer une palette.
--
-- Ce fichier recopiait les hexadécimaux de nurburgreen. Depuis qu'il y a deux
-- thèmes, ça voulait dire une barre British Racing Green sous kreide. Les deux
-- colorschemes du dépôt définissent déjà les groupes `MiniStatusline*` aux
-- rôles exacts dont lualine a besoin (a = mode, b = contexte, c = fond), donc
-- on les LIT plutôt que de les redire.
--
-- Un colorscheme qui ne les définit pas (aether, un thème d'Omarchy) laisse
-- `opts.options.theme` intact : lualine retombe sur sa détection automatique.

local function hex(v)
  return v and string.format("#%06x", v) or nil
end

-- link = false : on veut la couleur résolue, pas le nom du groupe pointé.
local function hl(name)
  local ok, h = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  if not ok or type(h) ~= "table" or (h.fg == nil and h.bg == nil) then return nil end
  return { fg = hex(h.fg), bg = hex(h.bg), gui = h.bold and "bold" or nil }
end

local function build()
  local b        = hl("MiniStatuslineFilename")
  local c        = hl("MiniStatuslineFileinfo")
  local inactive = hl("MiniStatuslineInactive")
  local modes = {
    normal  = "MiniStatuslineModeNormal",
    insert  = "MiniStatuslineModeInsert",
    visual  = "MiniStatuslineModeVisual",
    replace = "MiniStatuslineModeReplace",
    command = "MiniStatuslineModeCommand",
  }
  if not (b and c and inactive) then return nil end

  local theme = {}
  for mode, group in pairs(modes) do
    local a = hl(group)
    if not a then return nil end
    theme[mode] = { a = a, b = b, c = c }
  end
  theme.inactive = { a = inactive, b = inactive, c = inactive }
  return theme
end

return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    opts.options = opts.options or {}
    local theme = build()
    if theme then opts.options.theme = theme end
    return opts
  end,
}
