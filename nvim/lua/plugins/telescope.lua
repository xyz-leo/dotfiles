return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.6", 
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {
        file_ignore_patterns = { "node_modules", ".git/" },
        mappings = {
          i = {
            ["<esc>"] = actions.close,
          },
        },
      },
    })

    -- Keymaps
    local builtin = require("telescope.builtin")

    vim.keymap.set("n", "<leader>f", function()
      builtin.find_files({ hidden = true })
    end, { desc = "Find files (hidden true)" })

    vim.keymap.set("n", "<leader>g", builtin.live_grep, { desc = "Find text (grep)" })
    vim.keymap.set("n", "<leader>b", builtin.buffers, { desc = "Open buffers" })
    vim.keymap.set("n", "<leader>h", builtin.help_tags, { desc = "Help" })
  end,
}

