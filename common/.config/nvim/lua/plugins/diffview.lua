return {
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewFocusFiles" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>",                desc = "Diffview open" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>",        desc = "File history" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>",          desc = "Repo history" },
      { "<leader>gx", "<cmd>DiffviewClose<cr>",                desc = "Diffview close" },
    },
    opts = {
      view = {
        merge_tool = {
          layout = "diff3_mixed",
          disable_diagnostics = true,
        },
      },
    },
  },
}
