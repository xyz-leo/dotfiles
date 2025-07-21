return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = {
          "python", "html", "javascript", "typescript", "lua", "css"
        },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        autotag = { enable = true },
        indent = { enable = true },
      }
    end,
  },

  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },
}

