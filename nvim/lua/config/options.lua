-- General editor options.
local opt = vim.opt

-- UI
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.scrolloff = 8
opt.cursorline = true
opt.splitright = true
opt.splitbelow = true

-- Indentation
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true

-- Files & undo
opt.undofile = true
opt.swapfile = false
opt.updatetime = 250

-- Behavior
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.wrap = false
