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
        └── others.lua
```

## Requirements

- Neovim 0.9 or newer (newer recommended)
- Node.js (for JavaScript LSP)
- Python 3 (for Python LSP and debugging)
- Optional: Python virtual environment with `debugpy` installed at `~/.virtualenvs/debugpy/`

# LSP: NOTE
# Pyright, HTML, typescript-language-server are installed and managed automatically via Mason.
# You do NOT need to install them manually.

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
    ```

## Testing

Open any `.py`, `.js`, or `.html` file and run:

```nvim
:LspInfo
```

You should see the correct language server active.


## Copilot

The mappings are:
C-l -> Autocomplete
C-, -> Previous suggestion
C-. -> Next suggestion


## Download latest neovim (recommended)
https://github.com/neovim/neovim/releases
