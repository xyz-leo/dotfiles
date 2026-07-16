# What ends up installed on the system

Summary of what exists on the system **after** `archinstall.sh` + `chroot-setup.sh` run successfully (default values from `config.sh`).

## Packages always installed

```
base linux linux-firmware networkmanager grub sudo vim nano git base-devel
```

## Conditional packages

| Condition | Package(s) added |
|---|---|
| UEFI boot | `efibootmgr` |
| Intel CPU | `intel-ucode` |
| AMD CPU | `amd-ucode` |
| Running in VirtualBox | `virtualbox-guest-utils` |
| Running in KVM/QEMU | `qemu-guest-agent` |
| Install type = Cinnamon | `xorg-server xorg-xinit lightdm lightdm-gtk-greeter cinnamon gnome-terminal gvfs gvfs-smb network-manager-applet xdg-user-dirs` |
| Install type = GNOME (full) | package groups `gnome gnome-extra` (full desktop incl. `gdm`, Nautilus, GNOME Terminal/Console, Boxes, Tweaks, etc.) |
| Install type = KDE Plasma (full) | package groups `plasma kde-applications` + `sddm` (full Plasma shell + full KDE app suite; `sddm` isn't pulled in by either group) |
| Install type = Minimal | no desktop packages |

> Desktop environment supported today: **Cinnamon, GNOME, KDE Plasma, or none**. Chosen at the "Install type" prompt, unless `AUTO_CONFIRM=true` (in which case `DESKTOP_ENV` from `config.sh` is used as-is, default `cinnamon`).
>
> Installing the GNOME/KDE package groups shows pacman's interactive "select packages from group (default=all)" prompt during `pacstrap` — press Enter to accept the default (installs everything in the group).

## Disk / partitions

- Entire disk wiped (`wipefs` + new partition table).
- **UEFI**: GPT with ESP (FAT32, `EFI_SIZE_MIB`=1024 MiB) + swap + root (+ home).
- **BIOS**: MBR, no ESP (GRUB in the MBR gap) + swap + root (+ home).
- Swap: `auto` (sized from RAM) or fixed size (`SWAP_SIZE_MIB`, default 10240 MiB).
- Root filesystem: `ext4` (`ROOT_FS`).
- `/home`: separate partition only if `SEPARATE_HOME=true` (prompted at
  runtime, default No). When enabled, root is sized to `ROOT_SIZE_MIB`
  (default 61440 MiB / 60 GiB) and `/home` takes all remaining space.
  Otherwise `/home` is just a directory on the root filesystem, which takes
  100% of the remaining disk.

## Bootloader

- GRUB installed (`x86_64-efi` on UEFI, with `--removable` fallback if NVRAM is unavailable; `i386-pc` on BIOS).
- `grub-mkconfig` generated into `/boot/grub/grub.cfg`.

## System identity

- Hostname: `arch` (`HOSTNAME`), with `/etc/hosts` configured.
- Timezone: `UTC` (`TIMEZONE`), hardware clock synced.
- Locale: `en_US.UTF-8` for `LANG` and all `LC_*` (`LOCALE_LANG` / `LOCALE_REGIONAL`).
- Console keymap: `us` (`KEYMAP_CONSOLE`); X11 keymap: layout `us`, model `pc105` (only applied if a desktop is installed).

## Users and permissions

- Root user with the password set during install.
- User `admin` (`USERNAME`) created, with its own password, shell `/bin/bash`.
- User's groups: `wheel,video,audio,storage` (`USER_GROUPS`).
- `wheel` granted sudo access via drop-in `/etc/sudoers.d/99-wheel`.

## Network and enabled services

- `NetworkManager` enabled (manages the network connection).
- Display manager enabled based on desktop: Cinnamon → `lightdm`, GNOME →
  `gdm`, KDE → `sddm`. None if minimal install.
- If VirtualBox: `vboxservice` enabled.
- If KVM/QEMU: `qemu-guest-agent` enabled.

## One-line summary

A minimal, functional Arch Linux (kernel, GRUB, NetworkManager, sudo, git, vim/nano, base-devel) — optionally with a full desktop environment (Cinnamon, GNOME, or KDE Plasma, each with its matching display manager) — already partitioned (optionally with a separate `/home`), with an `admin` user in the `wheel` group, locale/timezone/keyboard configured, and microcode/VM guest drivers enabled automatically based on the detected hardware.
