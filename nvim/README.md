# Neovim Configuration (Lazy, LSP, Treesitter, JavaScript and Python)

This is a modular Neovim setup using [lazy.nvim](https://github.com/folke/lazy.nvim) as the plugin manager. It is optimized for web development (JavaScript/HTML/CSS) and Python, with proper LSP integration and syntax highlighting.

## Features

- LSP support via Mason for Python (`pyright`), JavaScript/TypeScript (`typescript-language-server`), HTML and CSS
- Autocompletion using `nvim-cmp` and `LuaSnip`
- Syntax highlighting with `nvim-treesitter`
- Auto-closing tags and pairs
- Theme: Catppuccin
- Python debugging using `nvim-dap-python`

## Directory Structure

```
~/.config/nvim/
├── init.lua
└── lua/
    ├── config/
    │   └── lazy.lua
    └── plugins/
        ├── cmp.lua
        ├── copilot.lua
        ├── lsp.lua
        ├── theme.lua
        ├── treesitter.lua
        ├── telescope.lua
        └── others.lua
```

## Requirements

- Neovim 0.9 or newer (newer recommended)
- Node.js (for JavaScript LSP)
- Python 3 (for Python LSP and debugging)
- Optional: Python virtual environment with `debugpy` installed at `~/.virtualenvs/debugpy/`

# LSP: NOTE

Install the desired LSP or Linters with :Mason

## Setup

1. Clone this repository to your Neovim config directory:
   ```bash
   git clone https://github.com/xyz-leo/dotfiles && mv dotfiles/nvim ~/.config/nvim
   ```

2. Launch Neovim and sync plugins:
   ```nvim
   :Lazy sync
   ```

3. If you want to use copilot, you need to sign in on github with:
    ```nvim
    :Copilot auth

## Copilot

The mappings are:
C-l -> Autocomplete
C-, -> Previous suggestion
C-. -> Next suggestion

## Leader key
`<Space>` is the Leader key.

## Telescope
Telescope configuration can be changed in the plugins/telescope.lua file, if you want to.

Keybindings that I'm currently using:
`<leader>` + `f (search files), F (search files from user home), g (grep text), h (help)`

Live grep `<leader> + g`: this functionality requires `ripgrep` to be installed on your system. You can tipically install it using your system's package manager (e.g., sudo pacman -S ripgrep).

## Download latest neovim (recommended)
https://github.com/neovim/neovim/releases
