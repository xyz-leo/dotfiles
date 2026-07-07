#!/usr/bin/env bash
# Installs zsh + oh-my-zsh + powerlevel10k + zsh-syntax-highlighting,
# then copies the zshrc / p10k.zsh from this repo into place.
# Safe to re-run: every step is idempotent.
# Note: copies, not symlinks -- this directory is not expected to still
# exist afterwards (the caller deletes it once the whole setup finishes).

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

backup() {
  # Back up a real file/dir before overwriting it (skip if it's already our symlink).
  if [ -e "$1" ] && [ ! -L "$1" ]; then
    mv "$1" "$1.bak.$(date +%Y%m%d%H%M%S)"
    echo "Backed up existing $1"
  fi
}

# Back these up BEFORE oh-my-zsh's own installer runs, not just before our
# final symlink step -- otherwise a real, pre-existing .zshrc/.p10k.zsh gets
# exposed to the upstream installer's own overwrite/keep logic first, which
# is exactly the gap that was letting our own dotfiles silently not end up
# linked in.
echo "==> Backing up any existing zsh config"
backup "$HOME/.zshrc"
backup "$HOME/.p10k.zsh"

echo "==> Installing zsh"
if ! command -v zsh >/dev/null 2>&1; then
  if command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --noconfirm zsh
  elif command -v apt >/dev/null 2>&1; then
    sudo apt update && sudo apt install -y zsh
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y zsh
  else
    echo "No supported package manager found. Install zsh manually." >&2
    exit 1
  fi
else
  echo "zsh already installed"
fi

echo "==> Installing oh-my-zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "oh-my-zsh already installed"
fi

echo "==> Installing zsh-syntax-highlighting plugin"
PLUGIN_DIR="$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
if [ ! -d "$PLUGIN_DIR" ]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUGIN_DIR"
else
  echo "zsh-syntax-highlighting already installed"
fi

echo "==> Installing powerlevel10k theme"
THEME_DIR="$ZSH_CUSTOM/themes/powerlevel10k"
if [ ! -d "$THEME_DIR" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$THEME_DIR"
else
  echo "powerlevel10k already installed"
fi

echo "==> Copying dotfiles"
# Anything at these paths now is oh-my-zsh's own auto-generated default
# (the user's real files were already backed up above) -- cp overwrites it
# directly, no second backup needed.
cp -f "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
cp -f "$DOTFILES_DIR/p10k.zsh" "$HOME/.p10k.zsh"

for f in .zshrc .p10k.zsh; do
  if [ ! -f "$HOME/$f" ]; then
    echo "ERROR: $HOME/$f was not copied correctly" >&2
    exit 1
  fi
done
echo "Copied ~/.zshrc and ~/.p10k.zsh"

echo "==> Setting zsh as default shell"
if [ "$SHELL" != "$(command -v zsh)" ]; then
  chsh -s "$(command -v zsh)"
fi

echo "Done. Open a new terminal or run 'exec zsh' to see it in action."
