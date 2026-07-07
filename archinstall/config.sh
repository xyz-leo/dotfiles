#!/usr/bin/env bash
# Configuration for archinstall.sh — edit before running.
# Leave DISK empty to auto-detect (only safe when the machine has a single disk).

# --- Disk / partitioning ---
DISK=""                 # e.g. "/dev/sda" or "/dev/nvme0n1"; empty = auto-detect / prompt
EFI_SIZE_MIB=1024        # fixed EFI partition size, in MiB
ROOT_FS="ext4"

# SWAP_MODE:
#   auto  -> size derived from RAM (see swap_size_mib() in archinstall.sh)
#   fixed -> use SWAP_SIZE_MIB below
SWAP_MODE="auto"
SWAP_SIZE_MIB=10240

# --- System identity ---
HOSTNAME="arch"
USERNAME="admin"
USER_GROUPS="wheel,video,audio,storage"

# --- Locale / keyboard / timezone ---
LOCALE_LANG="en_US.UTF-8"
LOCALE_REGIONAL="en_US.UTF-8"   # used for LC_TIME, LC_MONETARY, LC_PAPER, LC_MEASUREMENT, LC_NAME, LC_ADDRESS, LC_TELEPHONE
TIMEZONE="UTC"
KEYMAP_CONSOLE="us"
KEYMAP_X11_LAYOUT="us"
KEYMAP_X11_MODEL="pc105"

# --- Desktop environment ---
# Supported: "cinnamon", "none"
# Overridden at runtime by the "minimal or desktop environment" prompt unless
# AUTO_CONFIRM is true, in which case this value is used as-is.
DESKTOP_ENV="cinnamon"

# --- Behavior ---
# AUTO_CONFIRM=true skips ALL interactive prompts (install type, keyring
# update, and the destructive-action confirmation) and runs fully on the
# values in this file — DESKTOP_ENV above is used untouched, and the keyring
# is not refreshed. Use with care.
AUTO_CONFIRM=false
