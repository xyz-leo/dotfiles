-- Ruby Noir: dark, red-accented, transparent. Palette mirrors kitty.conf
-- exactly so the terminal and the editor are the same theme.
if vim.g.colors_name then
  vim.cmd("highlight clear")
end
vim.o.background = "dark"
vim.g.colors_name = "ruby-noir"

local c = {
  bg = "#120d0e",
  bg_panel = "#1a1314", -- floats, popups, cursorline
  bg_alt = "#4a3638", -- borders, line numbers, comments
  fg = "#e0d4d4",
  fg_dim = "#c9b8b9",
  red = "#b83b4b",
  red_bright = "#d9525f",
  green = "#7a9b6e",
  yellow = "#c9a35f",
  blue = "#7a8bb0",
  magenta = "#a15c72",
  cyan = "#6ea3a3",
}

local hl = function(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- Editor UI. Normal is transparent (NONE bg) to match kitty's
-- background_opacity/blur; floating surfaces use bg_panel so text
-- stays legible over whatever is behind the terminal window.
hl("Normal", { fg = c.fg, bg = "NONE" })
hl("NormalNC", { fg = c.fg, bg = "NONE" })
hl("NormalFloat", { fg = c.fg, bg = c.bg_panel })
hl("FloatBorder", { fg = c.bg_alt, bg = c.bg_panel })
hl("SignColumn", { bg = "NONE" })
hl("EndOfBuffer", { fg = c.bg_alt, bg = "NONE" })
hl("LineNr", { fg = c.bg_alt, bg = "NONE" })
hl("CursorLineNr", { fg = c.red_bright, bg = "NONE", bold = true })
hl("CursorLine", { bg = c.bg_panel })
hl("Cursor", { fg = c.bg, bg = c.red })
hl("VertSplit", { fg = c.bg_alt, bg = "NONE" })
hl("WinSeparator", { fg = c.bg_alt, bg = "NONE" })
hl("StatusLine", { fg = c.fg_dim, bg = "NONE" })
hl("StatusLineNC", { fg = c.bg_alt, bg = "NONE" })
hl("TabLine", { fg = c.bg_alt, bg = "NONE" })
hl("TabLineFill", { bg = "NONE" })
hl("TabLineSel", { fg = c.bg, bg = c.red, bold = true })
hl("Visual", { fg = c.bg, bg = c.red })
hl("Search", { fg = c.bg, bg = c.yellow })
hl("IncSearch", { fg = c.bg, bg = c.red_bright })
hl("CurSearch", { fg = c.bg, bg = c.red_bright })
hl("MatchParen", { fg = c.red_bright, bold = true, underline = true })
hl("Pmenu", { fg = c.fg, bg = c.bg_panel })
hl("PmenuSel", { fg = c.bg, bg = c.red })
hl("PmenuSbar", { bg = c.bg_alt })
hl("PmenuThumb", { bg = c.red })

-- Syntax. Red is reserved for keywords/control-flow (the accent this
-- theme is built around) — everything else that used to fall back to
-- red through legacy syntax-group links (function names, in particular)
-- gets its own color so red doesn't dominate a whole file.
hl("Comment", { fg = c.bg_alt, italic = true })
hl("Constant", { fg = c.magenta })
hl("String", { fg = c.green })
hl("Character", { fg = c.green })
hl("Number", { fg = c.yellow })
hl("Boolean", { fg = c.yellow, bold = true })
hl("Identifier", { fg = c.fg })
hl("Function", { fg = c.cyan, bold = true })
hl("Statement", { fg = c.red })
hl("Keyword", { fg = c.red, bold = true })
hl("Operator", { fg = c.fg_dim })
hl("PreProc", { fg = c.blue })
hl("Type", { fg = c.blue })
hl("Special", { fg = c.yellow })
hl("Underlined", { fg = c.blue, underline = true })
hl("Error", { fg = c.red_bright, bold = true })
hl("Todo", { fg = c.bg, bg = c.yellow, bold = true })

-- Treesitter captures. Neovim falls back from these to the legacy groups
-- above when a capture isn't listed here (e.g. @function.call -> @function
-- -> Function), but common ones are named explicitly for clarity and so
-- the fallback chain is never load-bearing for the important distinctions.
hl("@variable", { fg = c.fg })
hl("@variable.builtin", { fg = c.magenta, italic = true })
hl("@variable.parameter", { fg = c.fg_dim, italic = true })
hl("@variable.member", { fg = c.fg_dim })
hl("@property", { fg = c.fg_dim })
hl("@function", { fg = c.cyan, bold = true })
hl("@function.call", { fg = c.cyan })
hl("@function.builtin", { fg = c.cyan, bold = true })
hl("@function.method", { fg = c.cyan })
hl("@function.method.call", { fg = c.cyan })
hl("@constructor", { fg = c.blue, bold = true })
hl("@keyword", { fg = c.red, bold = true })
hl("@keyword.function", { fg = c.red, bold = true })
hl("@keyword.return", { fg = c.red, bold = true })
hl("@keyword.operator", { fg = c.red })
hl("@keyword.import", { fg = c.red, bold = true })
hl("@conditional", { fg = c.red, bold = true })
hl("@repeat", { fg = c.red, bold = true })
hl("@type.builtin", { fg = c.blue, italic = true })
hl("@string.escape", { fg = c.green, bold = true })
hl("@string.special", { fg = c.yellow })
hl("@punctuation.delimiter", { fg = c.fg_dim })
hl("@punctuation.bracket", { fg = c.fg_dim })
hl("@punctuation.special", { fg = c.yellow })
hl("@tag", { fg = c.red_bright })
hl("@tag.attribute", { fg = c.yellow })
hl("@tag.delimiter", { fg = c.fg_dim })
hl("@markup.heading", { fg = c.red, bold = true })
hl("@markup.strong", { fg = c.fg, bold = true })
hl("@markup.italic", { fg = c.fg, italic = true })
hl("@markup.raw", { fg = c.green })
hl("@markup.link.url", { fg = c.cyan, underline = true })
hl("@comment", { fg = c.bg_alt, italic = true })

-- LSP diagnostics
hl("DiagnosticError", { fg = c.red_bright })
hl("DiagnosticWarn", { fg = c.yellow })
hl("DiagnosticInfo", { fg = c.blue })
hl("DiagnosticHint", { fg = c.cyan })
hl("DiagnosticUnderlineError", { sp = c.red_bright, undercurl = true })
hl("DiagnosticUnderlineWarn", { sp = c.yellow, undercurl = true })
hl("DiagnosticUnderlineInfo", { sp = c.blue, undercurl = true })
hl("DiagnosticUnderlineHint", { sp = c.cyan, undercurl = true })

-- Telescope (Pmenu/NormalFloat/FloatBorder cover most of it by default;
-- these give the prompt and selection a bit more identity)
hl("TelescopeNormal", { fg = c.fg, bg = c.bg_panel })
hl("TelescopeBorder", { fg = c.bg_alt, bg = c.bg_panel })
hl("TelescopePromptNormal", { fg = c.fg, bg = c.bg_panel })
hl("TelescopePromptBorder", { fg = c.red, bg = c.bg_panel })
hl("TelescopeSelection", { fg = c.fg, bg = c.bg_alt, bold = true })
hl("TelescopeMatching", { fg = c.red_bright, bold = true })
