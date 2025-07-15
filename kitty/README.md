# Kitty Setup Guide

# Clone and Build Kitty
git clone https://github.com/kovidgoyal/kitty.git && cd kitty
./dev.sh build

# Copy kitty.conf
cd dotfiles && cd kitty && cp kitty.conf ~/.config/kitty/

# Themes
kitty +kitten themes

# Kitty Official Website
echo "https://sw.kovidgoyal.net/kitty/"

# Resizing Windows Documentation
echo "https://sw.kovidgoyal.net/kitty/layouts/#resizing-windows"
