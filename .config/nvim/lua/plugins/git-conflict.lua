return {
  {
    "akinsho/git-conflict.nvim",
    event = "BufReadPre",
    opts = {
      default_mappings = true,
      default_commands = true,
      disable_diagnostics = true,
      highlights = {
        incoming = "DiffAdd",
        current = "DiffText",
      },
    },
  },
}
