# zsh dotfiles

Personal zsh setup: [oh-my-zsh](https://ohmyz.sh/) + [powerlevel10k](https://github.com/romkatv/powerlevel10k)
theme + [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) plugin, with a
prompt color scheme ("Ruby Noir") matched to a dark red/ruby terminal color scheme.

## What's in this repo

Only two files are actually "yours" — everything else is third-party and gets
downloaded fresh by the install script.

| File          | Goes to          | What it is |
|---------------|-------------------|------------|
| `zshrc`       | `~/.zshrc`        | Main zsh config: enables oh-my-zsh, sets the theme to powerlevel10k, enables the `git` and `zsh-syntax-highlighting` plugins. |
| `p10k.zsh`    | `~/.p10k.zsh`     | Powerlevel10k prompt config (lean style: transparent background, no color blocks). Colors are remapped to ANSI slots 0–15 (black/red/green/yellow/blue/magenta/cyan/white + bright variants) so the prompt matches whatever terminal color scheme defines those 16 colors — currently a dark ruby/red palette. |
| `install.sh`  | —                 | Idempotent setup script. Installs zsh, oh-my-zsh, the plugin and theme, then symlinks the two files above into place. |

Not included: oh-my-zsh itself, the powerlevel10k theme files, and the
zsh-syntax-highlighting plugin. Those are upstream projects re-cloned by
`install.sh` rather than committed here.

## How it works

- `~/.zshrc` sets `ZSH_THEME="powerlevel10k/powerlevel10k"` and
  `plugins=(git zsh-syntax-highlighting)`, then at the bottom sources
  `~/.p10k.zsh` if it exists.
- `~/.p10k.zsh` defines what each prompt segment looks like (current directory,
  git status, exit code, command duration, etc.) using color numbers 0–15.
  Because those numbers are just the standard ANSI palette, changing your
  terminal's color scheme (e.g. in `kitty.conf`) automatically re-colors the
  prompt to match — no p10k edits needed.
- Prompt symbols (branch icon, arrows, etc.) require a **Nerd Font** in your
  terminal. Without one you'll see boxes/question marks instead of icons.

## Quick start (recommended)

```bash
./install.sh
```

This will (safely, and can be re-run anytime):
1. Install `zsh` via your system package manager (pacman/apt/dnf).
2. Install oh-my-zsh (non-interactively, won't touch your shell yet).
3. Clone `zsh-syntax-highlighting` into `~/.oh-my-zsh/custom/plugins/`.
4. Clone `powerlevel10k` into `~/.oh-my-zsh/custom/themes/`.
5. Back up any existing `~/.zshrc` / `~/.p10k.zsh` (to `*.bak.<timestamp>`)
   and symlink this repo's `zshrc` / `p10k.zsh` in their place.
6. Set zsh as your default login shell (`chsh`).

Open a new terminal (or run `exec zsh`) afterward to see it.

## Manual install (if you don't want to run the script)

```bash
# 1. Install zsh
sudo pacman -S zsh          # Arch
# sudo apt install zsh      # Debian/Ubuntu
# sudo dnf install zsh      # Fedora

# 2. Install oh-my-zsh (choose "no" if it asks to change your default shell / overwrite .zshrc)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 3. Install the zsh-syntax-highlighting plugin
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git \
  "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"

# 4. Install the powerlevel10k theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"

# 5. Drop in the config files from this repo
ln -sf "$(pwd)/zshrc" "$HOME/.zshrc"
ln -sf "$(pwd)/p10k.zsh" "$HOME/.p10k.zsh"

# 6. Make zsh your default shell
chsh -s "$(command -v zsh)"
```

Then open a new terminal.

## Customizing further

- Re-run `p10k configure` to regenerate `~/.p10k.zsh` from scratch with the
  interactive wizard (this will overwrite the color choices made here).
- To re-theme the prompt to a different color scheme, edit the
  `POWERLEVEL9K_*_FOREGROUND` values in `p10k.zsh` — they're plain ANSI color
  numbers (0–15) or 256-color codes.
- A Nerd Font (e.g. JetBrainsMono Nerd Font, FiraCode Nerd Font) is required
  in your terminal for icons to render correctly.
