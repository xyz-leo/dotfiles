# nvim

Personal Neovim configuration, plugin-managed with [lazy.nvim](https://github.com/folke/lazy.nvim).

## Requirements

- Neovim >= 0.9
- git (lazy.nvim bootstraps and updates plugins through it)
- ripgrep (`rg`) — file finding and grep (Telescope)
- the `tree-sitter` CLI (`sudo pacman -S tree-sitter-cli` on Arch) — required by nvim-treesitter
  to compile parsers. Without it, `:Lazy sync` will report parser install errors and syntax
  highlighting falls back to each filetype's legacy (much cruder) syntax file.

## Install

```sh
git clone <this-repo-url> ~/.config/nvim
nvim
```

On first launch, lazy.nvim clones itself automatically — no manual setup step.

## Structure

```
init.lua                    entry point, loads config.lazy
colors/ruby-noir.lua        the colorscheme itself (native Neovim :colorscheme mechanism)
lua/config/lazy.lua         bootstraps lazy.nvim, then loads options/keymaps/autocmds/colorscheme and plugins
lua/config/options.lua      editor settings (vim.opt)
lua/config/keymaps.lua      general, non-plugin keymaps
lua/config/autocmds.lua     autocommands
lua/config/colorscheme.lua  activates colors/ruby-noir.lua
lua/plugins/*.lua           one file per plugin (or plugin group); auto-loaded by lazy.nvim
lua/plugins/lsp.lua         Mason + mason-lspconfig + nvim-lspconfig (LSP server management)
lua/plugins/completion.lua  blink.cmp (completion popup UI)
lua/plugins/telescope.lua   telescope.nvim (fuzzy finder, ripgrep-backed)
lua/plugins/treesitter.lua  nvim-treesitter (syntax highlighting, per-language parsers)
```

## Adding a plugin

Create a new file under `lua/plugins/` returning a lazy.nvim spec, e.g. `lua/plugins/telescope.lua`:

```lua
return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
}
```

No manual registration needed — every `.lua` file in that directory is picked up.

## Leader key

`<space>`

## LSP

Language servers are installed and managed through Mason, not by hand.

The servers below are declared in `ensure_installed` (`lua/plugins/lsp.lua`) and install
automatically on first launch — a fresh clone of this repo needs no manual `:Mason` step:

| lspconfig name | Language |
|---|---|
| `bashls` | Bash / shell |
| `pyright` | Python |
| `ruby_lsp` | Ruby |
| `clangd` | C / C++ |
| `html` | HTML |
| `cssls` | CSS |
| `ts_ls` | JavaScript / TypeScript |

To add another language: append its lspconfig name to `ensure_installed` in `lua/plugins/lsp.lua`
(find the name via `:Mason` or the [lspconfig server list](https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md)),
then `:Lazy sync` (or just relaunch nvim). `mason-lspconfig` installs it and calls
`vim.lsp.enable()` for you — nothing else to wire up. Installing a one-off server you don't
want to keep long-term is still just `:Mason` → search → `i`.

LSP keymaps (buffer-local, active once a server attaches):

| Keys | Effect |
|---|---|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | Go to references |
| `K` | Hover documentation |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |

### Ruby LSP
In order to `ruby_lsp` to work, you need those environment variables:

```
export GEM_HOME="$HOME/.gem"
export GEM_PATH="$GEM_HOME"
export PATH="$GEM_HOME/bin:$PATH"
```

## Completion

[blink.cmp](https://github.com/saghen/blink.cmp) (`lua/plugins/completion.lua`) provides the
completion popup — LSP servers report *what* can be completed, blink.cmp is what shows it and
lets you accept it. Sources: `lsp`, `path`, `buffer`, `snippets`.

| Keys | Effect |
|---|---|
| `<Tab>` | Accept selected item, or jump to the next snippet placeholder if one's active |
| `<CR>` | Accept selected item (falls through to a normal newline if the menu isn't open) |
| `<C-space>` | Open completion menu manually |
| `<C-y>` | Accept selected item (same as `<Tab>`/`<CR>`, kept for muscle memory) |
| `<C-n>` / `<C-p>` | Next / previous item |

## Finding files

[telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) (`lua/plugins/telescope.lua`),
backed by `rg` (ripgrep) for both listing and searching:

| Keys | Effect |
|---|---|
| `<leader>f` | Find files in the repo / current working directory |
| `<leader>g` | Find files under `$HOME`, filtered to programming-related files only (see below) |
| `<leader>h` | Live grep (search file contents) in the repo / current working directory |

`<leader>g` restricts `$HOME` to an allowlist of extensions (`.py`, `.js`, `.ts`, `.lua`, `.go`,
`.rs`, `.c`/`.cpp`, `.rb`, `.sh`, `.html`, `.css`, `.json`, `.yaml`, `.toml`, `.md`, `.sql`, plus
`Makefile`/`Dockerfile`/`Gemfile`/`Rakefile`) and excludes common junk directories
(`node_modules`, `.git`, `.cache`, `venv`, `dist`, `build`, `target`, `Downloads`, `Pictures`, …).
Both the allowlist and the ignore list are plain Lua tables at the top of `telescope.lua` —
edit them directly to add a language or a directory to skip.

## Syntax highlighting

[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) (`lua/plugins/treesitter.lua`)
parses each buffer with a real grammar instead of the legacy per-filetype regex syntax files, which
is what makes highlighting distinguish e.g. a function name from a keyword instead of coloring both
the same. Parsers installed: bash, python, ruby, c, cpp, html, css, javascript, typescript, tsx,
lua, vim, vimdoc, json, yaml, toml, markdown.

Requires the `tree-sitter` CLI (see Requirements) to compile parsers — `:Lazy sync` will show
`error: ... 'tree-sitter'` per-language if it's missing.

## Line numbers

`relativenumber` + `number` are both on (`lua/config/options.lua`): the current line shows its
absolute number, every other line shows its distance from the cursor. Both stay on in every mode,
including insert — nothing here toggles them off, so numbers don't flip to a different style or
disappear when you start typing.

## Theme

`ruby-noir` (`colors/ruby-noir.lua`) — dark, red-accented, transparent. Not a plugin: it's a
plain Neovim colorscheme file, picked up automatically via `:colorscheme ruby-noir` (already
the default, set in `lua/config/colorscheme.lua`).

The palette is copied hex-for-hex from `kitty.conf`'s "Ruby Noir" theme in this same repo, so
the terminal and the editor match. The main editing area's background is `NONE` (transparent,
relies on kitty's `background_opacity`/`background_blur`); floating windows (Telescope, hover
docs, the completion popup) use a slightly lighter opaque panel color so text stays legible
regardless of what's behind the terminal.

To adjust a color, edit the `c = { ... }` table at the top of `colors/ruby-noir.lua` — every
highlight group references those named fields, nothing is hardcoded twice.

## Useful commands

- `:Lazy` — plugin manager UI (install/update/clean)
- `:Lazy sync` — install missing plugins and update existing ones
- `:Mason` — LSP/DAP/linter/formatter installer UI

See [ARCHITECTURE.md](./ARCHITECTURE.md) for how the pieces fit together.
