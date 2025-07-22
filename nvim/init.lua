vim.opt.number = true
vim.opt.relativenumber = true

-- languages tab
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "html", "css", "javascript", "json", "yaml", "lua" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
  end
})

-- init lazy.nvim
require("config.lazy")

-- init boilertplate config to html and css
require("config.boilerplate")
