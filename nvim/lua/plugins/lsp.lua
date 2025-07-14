return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Pyright (Python)
      lspconfig.pyright.setup {
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic"
            }
          }
        }
      }

      -- HTML
      lspconfig.html.setup {
        capabilities = capabilities,
      }

      -- JavaScript / TypeScript using typescript-language-server (installed with npm)
      lspconfig.tsserver.setup {
        capabilities = capabilities,
        cmd = { "typescript-language-server", "--stdio" },
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", ".git"),
      }
    end,
  },

  -- Python debugger
  {
    "mfussenegger/nvim-dap-python",
    config = function()
      require("dap-python").setup("~/.virtualenvs/debugpy/bin/python")
    end,
  },
}
