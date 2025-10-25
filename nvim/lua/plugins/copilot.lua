return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  config = function()
    -- Garante que Copilot não mapeia Tab ou Esc
    vim.g.copilot_no_tab_map = true
    vim.g.copilot_assume_mapped = true

    require("copilot").setup({
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<C-l>",   -- aceita a sugestão
          next = "<C-,>",     -- próxima sugestão
          prev = "<C-.>",     -- sugestão anterior
          dismiss = "<C-c>",  -- descarta sugestão
        },
      },
      panel = { enabled = false },
    })
  end,
}

