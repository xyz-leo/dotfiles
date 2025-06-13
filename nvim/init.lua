vim.opt.number = true      -- Show numertion in lines
vim.opt.relativenumber = true -- (optional) relative lines numeration

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "html", "css", "javascript", "json", "yaml", "lua" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
  end
})

require("config.lazy")

require'lspconfig'.pyright.setup{
    settings = {
        python = {
            analysis = {
                typeCheckingMode = "basic"
            }
        }
    }
}

require'lspconfig'.html.setup{}

require("dap-python").setup("~/.virtualenvs/debugpy/bin/python")

require'nvim-treesitter.configs'.setup {
  ensure_installed = { "python", "html", "javascript", "typescript", "lua" },
  highlight = {
    enable = true,
  },
  autotag = {
    enable = true,
  },
}


require("catppuccin").setup({
    transparent_background = true,
    integrations = {
	    nvimtree = true,
	    telescope = true,
	    which_key = true,
	}
	--flavour = "mocha" -- Troque para "latte", "frappe", "macchiato", "mocha"
})

vim.cmd.colorscheme "catppuccin-mocha"

local cmp = require'cmp'

cmp.setup({
  completion = {
    autocomplete = { cmp.TriggerEvent.TextChanged },
  },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)  -- Using LuaSnip to expand snippets
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),  -- Autocomplete
    ['<CR>'] = cmp.mapping.confirm({ select = true }),  -- Confirm suggestion
  }),
  sources = {
    { name = 'nvim_lsp' },  -- LSP as source of completions
    { name = 'luasnip' },   -- Snippets as source of completions
  },
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()

require('lspconfig').html.setup {
  capabilities = capabilities,
}
