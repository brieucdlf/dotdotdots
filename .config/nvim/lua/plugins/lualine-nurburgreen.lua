return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    opts.options = opts.options or {}
    opts.options.theme = {
      normal = {
        a = { fg = "#001a0f", bg = "#f0c000", gui = "bold" },
        b = { fg = "#d4b88a", bg = "#0d3326" },
        c = { fg = "#8a6835", bg = "#001a0f" },
      },
      insert = {
        a = { fg = "#001a0f", bg = "#0a6b38", gui = "bold" },
        b = { fg = "#d4b88a", bg = "#0d3326" },
        c = { fg = "#8a6835", bg = "#001a0f" },
      },
      visual = {
        a = { fg = "#001a0f", bg = "#f5d020", gui = "bold" },
        b = { fg = "#d4b88a", bg = "#0d3326" },
        c = { fg = "#8a6835", bg = "#001a0f" },
      },
      replace = {
        a = { fg = "#001a0f", bg = "#a06030", gui = "bold" },
        b = { fg = "#d4b88a", bg = "#0d3326" },
        c = { fg = "#8a6835", bg = "#001a0f" },
      },
      command = {
        a = { fg = "#001a0f", bg = "#8a6835", gui = "bold" },
        b = { fg = "#d4b88a", bg = "#0d3326" },
        c = { fg = "#8a6835", bg = "#001a0f" },
      },
      inactive = {
        a = { fg = "#2a5a3a", bg = "#001a0f" },
        b = { fg = "#2a5a3a", bg = "#001a0f" },
        c = { fg = "#2a5a3a", bg = "#001a0f" },
      },
    }
    return opts
  end,
}
