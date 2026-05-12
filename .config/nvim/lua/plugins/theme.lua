return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = false,
      color_overrides = {
        mocha = {
          -- backgrounds
          base    = "#001a0f",
          mantle  = "#000f08",
          crust   = "#000a05",
          -- surfaces (carbon)
          surface0 = "#0a0e0a",
          surface1 = "#0d110d",
          surface2 = "#1a1e1a",
          -- overlays (cognac muted)
          overlay0 = "#3a2a0a",
          overlay1 = "#5a3a1a",
          overlay2 = "#8a6835",
          -- text (cognac leather)
          text      = "#d4b88a",
          subtext1  = "#c4a87a",
          subtext0  = "#b8a07a",
          -- accents
          green    = "#0a6b38",  -- BRG bright
          teal     = "#1d6648",  -- mousse forêt
          sky      = "#2d8060",  -- mousse claire
          sapphire = "#1a5a3a",  -- forêt profonde
          blue     = "#2a5a3a",  -- forêt
          lavender = "#3a6a4a",  -- forêt claire
          yellow   = "#f0c000",  -- GT Yellow
          peach    = "#a06030",  -- cognac chaud
          red      = "#6b3a1f",  -- cognac sombre
          maroon   = "#8a4a2a",  -- cognac
          mauve    = "#8a6835",  -- cognac tan
          pink     = "#c4a070",  -- cuir clair
          flamingo = "#b8a07a",  -- cognac muted
          rosewater = "#e0cba0", -- reflet cuir
        },
      },
      highlight_overrides = {
        mocha = function(c)
          return {
            -- comments bien lisibles mais discrets
            Comment = { fg = "#3a6a4a", style = { "italic" } },
            -- keywords en BRG vif
            Keyword   = { fg = c.green, style = { "bold" } },
            Repeat    = { fg = c.green, style = { "bold" } },
            Conditional = { fg = c.green, style = { "bold" } },
            -- fonctions en cognac clair
            Function  = { fg = "#e0cba0", style = { "bold" } },
            -- strings en mousse forêt
            String    = { fg = c.teal },
            -- types/classes
            Type      = { fg = c.sky },
            -- nombres en GT Yellow
            Number    = { fg = c.yellow },
            Boolean   = { fg = c.yellow },
            -- opérateurs cognac
            Operator  = { fg = c.mauve },
            -- selection BRG
            Visual    = { bg = "#003520" },
            -- cursor line très subtil
            CursorLine = { bg = "#040f09" },
            -- line numbers
            LineNr     = { fg = "#1a3a22" },
            CursorLineNr = { fg = "#8a6835", style = { "bold" } },
            -- indent
            IblIndent = { fg = "#0a1a0f" },
            -- telescope
            TelescopeBorder = { fg = "#2a5a3a" },
            -- diagnostic
            DiagnosticError = { fg = "#a06030" },
            DiagnosticWarn  = { fg = "#8a6835" },
            DiagnosticInfo  = { fg = "#2a5a3a" },
            DiagnosticHint  = { fg = "#1d6648" },
          }
        end,
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
