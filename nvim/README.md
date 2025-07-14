# Neovim Configuration (Lazy, LSP, Treesitter, JavaScript and Python)

This is a modular Neovim setup using [lazy.nvim](https://github.com/folke/lazy.nvim) as the plugin manager. It is optimized for web development (JavaScript/HTML/CSS) and Python, with proper LSP integration and syntax highlighting.

## Features

- LSP support for Python (`pyright`), JavaScript/TypeScript (`typescript-language-server`), and HTML
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
        ├── lsp.lua
        ├── theme.lua
        ├── treesitter.lua
        └── others.lua
```

## Requirements

- Neovim 0.9 or newer
- Node.js (for JavaScript LSP)
  ```bash
  npm install -g typescript typescript-language-server
  ```
- Python with `pyright`
  ```bash
  pip install pyright
  ```
- Python virtual environment with `debugpy` at `~/.virtualenvs/debugpy/`

## Setup

1. Clone this repository to your Neovim config directory:
   ```bash
   git clone <this-repo-url> ~/.config/nvim
   ```

2. Launch Neovim and sync plugins:
   ```vim
   :Lazy sync
   ```

3. Install Treesitter languages:
   ```vim
   :TSInstall javascript
   ```

4. (Optional) Install LSP servers via Mason:
   ```vim
   :MasonInstall pyright
   ```

## Testing

Open any `.py`, `.js`, or `.html` file and run:

```vim
:LspInfo
```

You should see the correct language server active.
