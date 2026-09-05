-- Le colorscheme suit le thème actif, il n'est plus figé sur un nom.
--
-- `theme/render.sh` expose le fichier du thème courant dans
-- ~/.config/theme/current/neovim.lua (et l'efface quand le thème n'en fournit
-- pas). On le charge s'il est là. Sans ça, basculer le bureau sur kreide
-- repeignait ghostty, tmux, fzf, btop, la barre, le lanceur et herdr — et
-- laissait l'éditeur en nurburgreen, seule surface à ne pas suivre.
local per_theme = vim.fn.expand("~/.config/theme/current/neovim.lua")

if vim.uv and vim.uv.fs_stat(per_theme) then
  local ok, spec = pcall(dofile, per_theme)
  if ok and type(spec) == "table" then return spec end
end

-- Repli : le dépôt hors machine à thème, ou un fichier illisible.
return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "nurburgreen",
    },
  },
}
