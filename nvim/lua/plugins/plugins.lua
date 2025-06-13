return {
	{"catppuccin/nvim", name = "catppuccin", priority = 1000},
	
	{
   	 "hrsh7th/nvim-cmp",
    	 config = function()
 	 require'cmp'.setup({
        -- Configurações do nvim-cmp
     	})
    	end
  	},
  
  	-- Integração com LSP
  	{
   	 "hrsh7th/cmp-nvim-lsp",
    	after = "nvim-cmp",  -- Garante que o plugin só será carregado depois do nvim-cmp
 	},
  
  	-- Snippets
	{
    	"L3MON4D3/LuaSnip",
   	 config = function()
     	 -- Configurações do LuaSnip (se necessário)
   	 end
 	},

	-- LSP Config (Pyright)
 	{
    	"neovim/nvim-lspconfig",
     	config = function()
      -- Configurações do Pyright LSP
        require'lspconfig'.pyright.setup{}
    	end
  	},	
	
	{
   	 "nvim-treesitter/nvim-treesitter",
    	  build = ":TSUpdate"
	},

	{
    	"mfussenegger/nvim-dap", -- Debugger
    	"mfussenegger/nvim-dap-python" -- Debugger específico para Python
	},
	
	{
	  "windwp/nvim-autopairs",
	  event = "InsertEnter",
	  config = true
	},
	{
	  "windwp/nvim-ts-autotag",
	  opts = {},
	  event = "InsertEnter",
	  dependencies = { "nvim-treesitter/nvim-treesitter" },
	}
}


