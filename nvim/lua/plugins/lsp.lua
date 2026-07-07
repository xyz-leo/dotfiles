-- LSP stack: Mason installs servers, mason-lspconfig bridges them to
-- Neovim's native LSP client, nvim-lspconfig ships the default server configs.
return {
  {
    "mason-org/mason.nvim",
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    -- automatic_enable (default true) calls vim.lsp.enable() for every
    -- server Mason has installed, so nothing else needs wiring by hand.
    opts = {
      -- Installed automatically on `:Lazy sync` / first launch, so a fresh
      -- clone of this repo doesn't need a manual `:Mason` pass.
      ensure_installed = {
        "bashls", -- Bash / shell
        "pyright", -- Python
        "ruby_lsp", -- Ruby
        "clangd", -- C / C++
        "html", -- HTML
        "cssls", -- CSS
        "ts_ls", -- JavaScript / TypeScript
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "saghen/blink.cmp" },
    config = function()
      -- Tell every server blink.cmp exists, so it advertises completion
      -- (snippets, resolve, etc.) correctly instead of falling back to
      -- Neovim's bare-bones default capabilities.
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(mode, keys, action, desc)
            vim.keymap.set(mode, keys, action, { buffer = event.buf, desc = desc })
          end

          map("n", "gd", vim.lsp.buf.definition, "Go to definition")
          map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
          map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
          map("n", "gr", vim.lsp.buf.references, "Go to references")
          map("n", "K", vim.lsp.buf.hover, "Hover documentation")
          map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
        end,
      })
    end,
  },
}
