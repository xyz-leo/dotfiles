# Architecture

How this config boots, why it's split the way it is, and what each piece does. Read this if you want to
understand the setup as a whole, not just copy-paste from it.

## 1. The boot chain

Neovim's only fixed entry point is `init.lua` at the root of `~/.config/nvim`. Everything else is a module
that gets `require`d explicitly — nothing loads "by magic" except that one file.

```
init.lua
  └─ require("config.lazy")
       ├─ set leader keys
       ├─ bootstrap lazy.nvim (clone it with git if missing)
       ├─ require("config.options")
       ├─ require("config.keymaps")
       ├─ require("config.autocmds")
       ├─ require("config.colorscheme")  (:colorscheme ruby-noir)
       └─ require("lazy").setup({ spec = { { import = "plugins" } }, ... })
              └─ requires every file under lua/plugins/*.lua
```

Nothing runs in parallel or "automatically" — this is a straight-line list of requires. If you want to know
what happens when nvim starts, this list *is* the answer, in order.

## 2. How `require("config.lazy")` finds a file

Lua's `require("a.b")` looks for `a/b.lua` on the `runtimepath`. Neovim puts `~/.config/nvim/lua/` on that
path automatically, so:

- `require("config.lazy")` → `lua/config/lazy.lua`
- `require("config.options")` → `lua/config/options.lua`
- `{ import = "plugins" }` → every `lua/plugins/*.lua`, each expected to `return` a plugin spec (or list of specs)

This is *the* convention that makes the whole "drop a file in and it loads" workflow possible — there is no
registry to update by hand, because `require`'s file-to-module mapping already **is** the registry.

## 3. Why lazy.nvim is bootstrapped, not installed

`lua/config/lazy.lua` checks if lazy.nvim exists at `stdpath("data")/lazy/lazy.nvim` (usually
`~/.local/share/nvim/lazy/lazy.nvim`). If not, it `git clone`s it there, then does
`vim.opt.rtp:prepend(lazypath)` to put it on the runtimepath so `require("lazy")` resolves.

This means the plugin manager itself is not a submodule or vendored file in this repo — cloning this repo
onto a fresh machine and opening `nvim` is enough. Nothing to install by hand.

Note the two different base directories in play:
- `~/.config/nvim` (this repo) — **configuration**, tracked in git.
- `~/.local/share/nvim` — **installed plugins + lazy-lock.json state**, not this repo, regenerated from config.

## 4. Why leader keys are set before `lazy.setup`

`vim.g.mapleader` / `vim.g.maplocalleader` are set at the very top of `lua/config/lazy.lua`, before any
plugin loads. Plugin specs frequently declare keymaps like `{ "<leader>ff", ... }` at spec-parse time —
if the leader isn't set yet, those keymaps resolve to `\` (Vim's default) instead of `<space>`, and changing
the leader afterwards won't retroactively fix already-registered mappings. Leader must be set first, always.

Current leader: **`<space>`** for both `mapleader` and `maplocalleader`.

## 5. Load order inside `config.lazy`

`options` → `keymaps` → `autocmds` → `colorscheme` → `lazy.setup(...)`. This order matters less than
leader-before-everything, but options (specifically `termguicolors`) are loaded before the colorscheme
applies, since a colorscheme's 24-bit hex colors are meaningless without it. Colorscheme is loaded before
`lazy.setup` so the base editor UI is already themed before any plugin's own startup UI (if any) could render.

## 6. `lua/config/options.lua` — what's set and why

| Group | Options | Why |
|---|---|---|
| UI | `number`, `relativenumber`, `signcolumn=yes`, `cursorline`, `termguicolors` | Relative numbers for `dj`/`5k`-style motions; `signcolumn=yes` reserves the gutter so the window doesn't jump when a sign appears (e.g. future LSP diagnostics/git signs); truecolor for accurate plugin theming |
| Splits | `splitright`, `splitbelow` | New splits open to the right/below instead of Vim's default left/above — matches how most people read a screen |
| Indentation | `expandtab`, `shiftwidth=2`, `tabstop=2`, `softtabstop=2`, `smartindent` | Spaces instead of tabs, 2-width, consistent across insert/normal mode operations |
| Search | `ignorecase`, `smartcase` | Case-insensitive by default, but a search with an uppercase letter becomes case-sensitive |
| Persistence | `undofile` | Undo history survives closing/reopening a file |
| `swapfile = false` | No `.swp` files — traded for `undofile` persistence instead |
| Behavior | `mouse=a`, `clipboard=unnamedplus`, `wrap=false` | Mouse usable in all modes; yank/paste shares the system clipboard by default; no soft line-wrap |

## 7. `lua/config/keymaps.lua` — current keymaps

| Mode | Keys | Effect |
|---|---|---|
| n | `<Esc>` | Clear search highlight (`:nohlsearch`) |
| n | `<C-h/j/k/l>` | Move focus between splits (left/down/up/right) |
| n | `<C-Up/Down>` | Grow/shrink split height |
| n | `<C-Left/Right>` | Shrink/grow split width |
| v | `<`, `>` | Indent/outdent and reselect, so you can repeat without reselecting |

Plugin-specific keymaps are **not** here — they live inside each plugin's own spec file in `lua/plugins/`,
next to the plugin they belong to. That keeps this file scoped to "keymaps with no plugin dependency."

## 8. `lua/config/autocmds.lua` — current autocommands

| Event | Effect |
|---|---|
| `TextYankPost` | Briefly highlights the yanked text (`vim.highlight.on_yank`) |
| `BufWritePre` | Strips trailing whitespace from every line before saving |

## 9. The colorscheme (`colors/ruby-noir.lua` + `lua/config/colorscheme.lua`)

This is the one piece of the config that deliberately isn't a plugin, even though a colorscheme
easily could be one. Neovim (and Vim before it) has a built-in convention: any file at
`colors/<name>.lua` (or `.vim`) on the runtimepath is a valid target for `:colorscheme <name>`.
`~/.config/nvim` is already on the runtimepath by default, so `colors/ruby-noir.lua` is
discoverable with zero registration — no `lua/plugins/*.lua` entry, no `require`, nothing to
tell lazy.nvim about. `lua/config/colorscheme.lua` is a one-line file that just calls
`vim.cmd.colorscheme("ruby-noir")` to activate it during boot (§1, §5).

`colors/ruby-noir.lua` itself is a flat list of `vim.api.nvim_set_hl(0, group, {...})` calls
against a palette table (`c`) at the top of the file, hex-for-hex identical to `kitty.conf`'s
color0–color15 in this same repo — the intent is that the terminal and the editor are reskins
of the same palette, not two themes that happen to look similar. Transparency follows one rule
throughout the file: `Normal`/`NormalNC`/`SignColumn`/`StatusLine`/etc. all set `bg = "NONE"`
(so kitty's `background_opacity`/`background_blur` shows through the editor exactly as it
does everywhere else in the terminal), while floating surfaces (`NormalFloat`, `Pmenu`,
`Telescope*`) keep an opaque `bg_panel` color — otherwise completion menus and Telescope's
picker would be unreadable over arbitrary text sitting behind the terminal window.

Plugins are not hard-coded into this file. `Pmenu`/`PmenuSel` cover blink.cmp's popup because
blink.cmp's own highlight groups (`BlinkCmpMenu`, etc.) link to `Pmenu` by default; likewise
most of Telescope's look comes from `NormalFloat`/`FloatBorder` before any `Telescope*`-specific
override is even needed. The explicit `Telescope*` groups here exist only where the default
link isn't distinctive enough (the prompt border, the selected-row highlight).

## 10. The LSP stack (`lua/plugins/lsp.lua`)

Three plugins, each doing one job, wired together by a single native Neovim mechanism
(`vim.lsp.enable`, added in 0.11):

```
mason.nvim            installs LSP server binaries (its own isolated bin dir, not $PATH)
        ↓
mason-lspconfig.nvim   maps Mason's package names to lspconfig's server names, then
                        calls vim.lsp.enable("<server>") for every installed server
        ↓
nvim-lspconfig         ships the actual vim.lsp.config(...) tables (cmd, root markers,
                        filetypes) for hundreds of servers — it's a data source, not a
                        setup function, in current versions
```

None of these three plugins reference each other's config directly — the link between
"Mason installed `lua_ls`" and "Neovim's LSP client is now active for `.lua` files" is
`automatic_enable`, a `mason-lspconfig` option that defaults to `true`. That's why
`lsp.lua` has almost no configuration in it: installing a server *is* the configuration
step. There is nothing to hand-wire per language.

`ensure_installed` (also a `mason-lspconfig` option) is what makes this reproducible across
machines: it's a list of lspconfig server names that `mason-lspconfig` installs via Mason on
every startup if they're missing, then feeds through the same `automatic_enable` path. Without
it, Mason would start with zero servers installed on a fresh clone, and you'd have to run
`:Mason` and install each one by hand before anything attached. With it, `git clone` +
`nvim` is the entire setup — the plugin manager installs the plugins, and the plugins
install the language servers, transitively, in one pass.

The one piece that isn't automatic is keymaps: an `LspAttach` autocmd in `lsp.lua` fires
whenever a server attaches to a buffer and sets the buffer-local keymaps (`gd`, `K`,
`<leader>rn`, etc. — see the README for the full table). It's buffer-local and inside
`LspAttach` specifically so these keys only exist in buffers that actually have a
language server attached, not globally.

## 11. Completion (`lua/plugins/completion.lua`) — why LSP alone wasn't enough

A language server attaching to a buffer only means Neovim *can* ask it "what completes
here?" — it says nothing about a popup appearing as you type. `vim.lsp` ships the plumbing
(`textDocument/completion` requests), not the UI. `blink.cmp` is that UI: it decides when to
trigger a request, renders the menu, and applies whatever you select.

For blink.cmp to show LSP-sourced completions (not just buffer words or paths), each server
needs to know blink.cmp exists, because a server only advertises completion behavior
(snippets, auto-import, resolve, etc.) to clients that say they support it, via the
`capabilities` table sent in the initialize request. That's this line in `lsp.lua`:

```lua
vim.lsp.config("*", {
  capabilities = require("blink.cmp").get_lsp_capabilities(),
})
```

`vim.lsp.config("*", ...)` sets *default* config merged into every server (mason-lspconfig's
per-server configs layer on top of it). It has to run before `mason-lspconfig`'s
`automatic_enable` fires — otherwise servers would already be configured with Neovim's bare
default capabilities by the time blink.cmp's are registered. That ordering is why
`nvim-lspconfig`'s spec lists `"saghen/blink.cmp"` as a `dependency`: lazy.nvim loads a
plugin's dependencies, and runs its own `config` function, before the depending plugin's
`config` function — so blink.cmp is guaranteed loadable, and the capabilities line above is
guaranteed to run, before `mason-lspconfig` enables anything.

**Accepting a completion.** blink.cmp ships four keymap presets (`default`, `super-tab`,
`enter`, `cmdline`), and it matters which one you pick because they genuinely don't map
the same keys — `default` binds `<Tab>` to snippet-jumping only and leaves `<CR>` completely
unmapped, so pressing either while a menu is open just... does nothing menu-related. This
config uses `preset = "super-tab"` (`<Tab>` accepts the selected item, or jumps a snippet
placeholder if one's active) plus an explicit `["<CR>"] = { "accept", "fallback" }` override,
since `super-tab` alone doesn't bind `<CR>` either. `fallback` in both cases means "if there's
nothing to accept/jump, run whatever `<Tab>`/`<CR>` would normally do" — so typing a plain
newline or a literal tab when no menu is open is unaffected.

## 12. Syntax highlighting (`lua/plugins/treesitter.lua`) — why everything used to look red

Before this plugin existed, Neovim highlighted every buffer with each filetype's *legacy*
syntax file (`$VIMRUNTIME/syntax/python.vim`, etc.) — regex-based rules that lump many distinct
things into one highlight group. Python's syntax file, for instance, links `def`, `import`,
`return`, `class`, `if`, `for`, and several others all to the same `Statement`/`Keyword` groups.
Since `ruby-noir.lua` colors both of those red, and those legacy rules touch a large fraction of
the tokens on a typical line, red visually dominated every file — not because the colorscheme
had "too much red" in the abstract, but because the input it was coloring was too coarse to
tell a function name from a control-flow keyword.

`nvim-treesitter` replaces that with a real parser per language, producing capture names like
`@function.call`, `@variable.parameter`, `@keyword.import` — one for roughly each *kind* of
token, not one per filetype's syntax author's judgment call. The plugin spec:

```lua
require("nvim-treesitter").install({ "python", "lua", ... })  -- parsers, compiled locally

vim.api.nvim_create_autocmd("FileType", {
  callback = function() pcall(vim.treesitter.start) end,
})
```

`install()` compiles each parser from source — which is why it needs the external `tree-sitter`
CLI (installed via `pacman`/`npm`/`cargo`; not bundled, and not the same thing as the `cc`/`gcc`
compiler that was sufficient for this plugin's previous "master" branch). The `FileType`
autocmd calls `vim.treesitter.start()` for *every* filetype and swallows the error via `pcall`
when no parser is installed for it — simpler than hand-maintaining a filetype → language name
map (they don't always match: the `bash` parser attaches to filetype `sh`, `vimdoc` to `help`,
etc.), at the cost of one harmless no-op error per unsupported filetype.

None of this touches `colors/ruby-noir.lua`'s legacy groups (`Function`, `Keyword`, `Statement`)
directly — Neovim's default runtime links every `@capture` down to one of them when a colorscheme
doesn't define the `@capture` explicitly (`@function.call` → `@function` → `Function`). What
changed in the colorscheme file itself was rebalancing *which* legacy groups things fall back to,
plus defining the highest-traffic `@`-prefixed groups explicitly instead of relying on that
fallback: `Function` moved from `red_bright` to `cyan`, so function names/calls — by far the most
frequent token in real code, more so than actual keywords — stopped reading as red. Red now
means "keyword," full stop: `@keyword`, `@keyword.function`, `@keyword.import`,
`@keyword.return`, `@conditional`, `@repeat` are the only groups still mapped to it.

## 13. Fuzzy finding (`lua/plugins/telescope.lua`)

telescope.nvim doesn't implement file listing or text search itself — for both, it shells out
to an external command and streams the output into its picker UI. This repo pins that command
to `rg` (ripgrep) explicitly rather than relying on telescope's auto-detection (`fd` > `rg` >
`find`), because ripgrep is the one guaranteed dependency here (`fd` isn't installed):

- `<leader>f` calls `find_files()` with no overrides. Telescope's own default `find_command`
  already prefers `rg --files` when `fd` is absent, so this "just works," but the repo's
  `vimgrep_arguments` in `opts.defaults` pins `live_grep`'s search command to `rg` explicitly
  for the same reason — don't depend on autodetection silently changing behavior if `fd` is
  installed later.
- `<leader>g` passes a fully custom `find_command` (built by the `home_find_command()` helper
  at the top of the file) and `cwd = vim.env.HOME`. This is the one picker that needs real
  filtering: unlike a git repo, `$HOME` has no `.gitignore` to keep the search sane, so the glob
  list does that job manually — `--glob '!dir/**'` per excluded directory (`node_modules`,
  `.cache`, `venv`, `Downloads`, …), then `--glob '*.ext'` per allowed extension. Passing several
  positive `--glob` patterns is an OR (matches any one), and a `--glob '!x'` unconditionally
  drops anything under `x`, regardless of extension — that combination is what "code files
  only, anywhere under `$HOME`" boils down to.
- `<leader>h` calls `live_grep()` unmodified — content search always runs in the repo/cwd, since
  grepping the filtered subset of `$HOME` wasn't asked for, only *listing* files there was.

All three are declared under `keys` in the plugin spec (not `config`), which is a lazy.nvim
loading trigger: the real keymap exists from startup, but telescope.nvim itself — and its
`plenary.nvim` dependency — aren't `require`d and loaded into memory until the key is pressed
for the first time.

## 14. Adding a plugin, mechanically

1. Create `lua/plugins/<name>.lua`.
2. `return` a table (lazy.nvim spec): at minimum `{ "author/repo" }`.
3. Save. Next `nvim` launch (or `:Lazy sync`), lazy.nvim sees the new spec via the `{ import = "plugins" }`
   scan and installs it — no other file needs to change.

Once plugins exist, `lazy-lock.json` will appear at the repo root. **Commit it** — it pins exact plugin
commits so a fresh clone reproduces the same versions instead of drifting to latest.

## 15. Design principle behind the split

Every file answers exactly one question:

- `options.lua` — how does the editor behave, independent of any keypress?
- `keymaps.lua` — what does a keypress do, independent of any plugin?
- `autocmds.lua` — what happens automatically on an event?
- `plugins/*.lua` — what is one specific plugin and its own config/keymaps?

If you're ever unsure where something goes, ask which of those four questions it answers.
