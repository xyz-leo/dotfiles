# Hyprland Dotfiles – Arch Linux Setup

This repository contains my personal Hyprland environment, including:

- **Hyprland** (window manager)
- **Hyprlock** (lockscreen)
- **Hyprpaper** (wallpaper daemon)
- **Waybar** (status bar)
- **Wofi** (application launcher)

All configuration files are expected to live in:

```
~/.config/
├── hypr/
├── waybar/
└── wofi/
```

The following guide shows how to prepare a clean Arch Linux installation and apply these dotfiles.

---

## 1. Required Packages

Install the core environment (if you do not have a hyprland setup yet):

```bash
sudo pacman -S hyprland \
    xdg-desktop-portal-hyprland \
    waybar \
    wofi \
    dunst \
    hyprpaper \
    hyprlock \
    kitty \
    fastfetch \
    pavucontrol \
    networkmanager \
    pipewire pipewire-pulse wireplumber \
    grim slurp satty \
    git
```

## 2. Recommended fonts:

```bash
sudo pacman -S ttf-jetbrains-mono-nerd \
    ttf-fira-code \
    ttf-font-awesome \
    noto-fonts \
    noto-fonts-emoji
```

## 3. Applying Dotfiles

If you have existing dotfiles, do a quick backup:

```bash
mv ~/.config/hypr ~/.config/hypr.bak 2>/dev/null
mv ~/.config/waybar ~/.config/waybar.bak 2>/dev/null
mv ~/.config/wofi ~/.config/wofi.bak 2>/dev/null
```

Clone this repository:
```bash
git clone https://github.com/xyz-leo/dotfiles.git
```

```bash
cp -r dotfiles/hyprland/hypr ~/.config/
cp -r dotfiles/hyprland/waybar ~/.config/
cp -r dotfiles/hyprland/wofi ~/.config/
```

## 4. Reboot
Thank you. - Leo
