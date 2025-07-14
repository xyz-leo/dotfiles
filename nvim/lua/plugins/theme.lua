return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        transparent_background = true,
        integrations = {
          nvimtree = true,
          telescope = true,
          which_key = true,
        },
      })
      vim.cmd.colorscheme("catppuccin-mocha")
    end,
  },
}

