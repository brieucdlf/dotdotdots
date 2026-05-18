-- TypeScript / Angular / Next.js / Tailwind / Node.js stack

return {
  -- Auto-close and rename HTML/JSX/Angular template tags
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    opts = {},
  },

  -- Angular language server
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        angularls = {},
        cssls = {},
        html = {},
        jsonls = {
          settings = {
            json = {
              -- Validate package.json, tsconfig.json, etc.
              schemas = require("schemastore").json.schemas(),
              validate = { enable = true },
            },
          },
        },
      },
    },
  },

  -- JSON schemas (package.json, tsconfig.json, .eslintrc...)
  {
    "b0o/schemastore.nvim",
    lazy = true,
  },

  -- Ensure Mason installs all needed tools
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "angular-language-server",
        "typescript-language-server",
        "tailwindcss-language-server",
        "eslint-lsp",
        "prettier",
        "css-lsp",
        "html-lsp",
        "json-lsp",
      },
    },
  },

  -- Treesitter: ensure parsers for the full stack
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "typescript",
        "javascript",
        "tsx",
        "html",
        "css",
        "scss",
        "json",
        "json5",
        "yaml",
        "graphql",
      },
    },
  },
}
