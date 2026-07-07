# Arch Linux Automated Install

Two-stage bash automation of the manual Arch Linux install documented in the README file — parametrized so the same scripts work
on both a VirtualBox VM and real hardware.

## What's here

| File | Runs where | Role |
|---|---|---|
| `config.sh` | sourced by both scripts | Every tunable: disk, partition sizes, hostname, user, locale, keymap, timezone, desktop environment |
| `archinstall.sh` | live ISO, as root | **Stage 1** — partitions, formats, mounts, pacstraps the base system, then hands off to stage 2 |
| `chroot-setup.sh` | inside `arch-chroot`, launched automatically by stage 1 | **Stage 2** — locale, hostname, users, sudo, bootloader, desktop environment, VM guest services |

You never run `chroot-setup.sh` by hand. `archinstall.sh` copies it (plus
`config.sh` and a throwaway passwords file) into the freshly-installed system
and executes it via `arch-chroot`, then deletes those temporary files once
it's done.

## Flow

```
Live ISO (root)
 └─ archinstall.sh
      ├─ sanity checks: root / internet
      ├─ prompt: minimal or desktop-environment install
      ├─ prompt: BIOS or UEFI boot mode
      ├─ detect disk, CPU vendor, virtualization
      ├─ prompt passwords + prompt: update keyrings? + print plan + confirm
      ├─ partition (parted) → format → mount
      ├─ (optional) refresh archlinux-keyring
      ├─ pacstrap: base + microcode + desktop + virt packages
      ├─ genfstab
      └─ arch-chroot /mnt → chroot-setup.sh
              ├─ timezone, locale, keymap, hostname
              ├─ enable NetworkManager
              ├─ set passwords, create user, configure sudo
              ├─ grub-install + grub-mkconfig
              ├─ enable LightDM/Cinnamon (if configured)
              └─ enable VM guest services (if detected)
 └─ unmount → done, reboot
```

## Requirements

- Booted from the Arch ISO
- Working internet connection in the live session
- Boot mode (BIOS/UEFI) is asked at runtime, not auto-detected — pick `1`
  (UEFI) only if this session is actually booted in UEFI mode
  (`/sys/firmware/efi/efivars` must exist), otherwise pick `0` (BIOS). The
  script warns but does not stop you if you pick UEFI without `efivars`
  present. Virtualization is still detected separately (`systemd-detect-virt`)
  purely to decide which guest-utils package/service to install (e.g.
  VirtualBox's `virtualbox-guest-utils`) — it no longer influences boot mode.

## Usage

1. Get the three files into the live environment. Most simple way is to git clone this repo (`git clone https://github.com/xyz-leo/dotfiles`).
   Or run a quick HTTP server on your host, then `curl` the files from the VM.

   If you will be running on the host, in this directory:
   ```bash
   python3 -m http.server 8000
   ```

   In the live VM:
   ```bash
   mkdir -p /root/archinstall && cd /root/archinstall
   for f in config.sh archinstall.sh chroot-setup.sh; do
     curl -O http://your_ip:8000/$f
   done
   chmod +x archinstall.sh chroot-setup.sh
   ```
   Replace `your_ip` with the host's address as seen from the VM:
   - **NAT** (VirtualBox default): `10.0.2.2`
   - **Bridged**: the host's real LAN IP (`ip addr` on the host)

1. Review/edit `config.sh` for this install.
2. `chmod +x archinstall.sh chroot-setup.sh`
3. `./archinstall.sh`
4. Answer the prompts as they come:
   - **Install type**: `0` for minimal (no desktop environment), `1` for
     desktop environment (Cinnamon). Defaults to whatever `DESKTOP_ENV` is
     set to in `config.sh`.
   - **Boot mode**: `0` for BIOS, `1` for UEFI (default). Pick based on how
     this session actually booted — UEFI only if `/sys/firmware/efi/efivars`
     exists.
   - Root and user passwords.
   - **Update keyrings?**: defaults to No. Only answer `y` if a previous run
     failed with a package-signature error — usually means the ISO is old
     and its `archlinux-keyring` is stale.
5. Read the printed plan carefully, type `yes` to confirm — **this erases the
   target disk**.
6. When it prints "All done", `reboot`.

All of the above prompts are skipped entirely if `AUTO_CONFIRM=true` in
`config.sh` — the install then runs unattended using `config.sh`'s values
as-is (`DESKTOP_ENV` untouched, keyring not refreshed, boot mode defaults to
UEFI).

## Key `config.sh` options

| Variable | Meaning |
|---|---|
| `DISK` | Empty = auto-detect if there's a single disk, otherwise you're prompted to pick one |
| `EFI_SIZE_MIB` | Fixed EFI System Partition size |
| `SWAP_MODE` | `auto` (sized from RAM) or `fixed` (uses `SWAP_SIZE_MIB`) |
| `ROOT_FS` | Root filesystem (currently `ext4` only) |
| `HOSTNAME`, `USERNAME`, `USER_GROUPS` | System identity |
| `LOCALE_LANG` / `LOCALE_REGIONAL` | Base locale vs. regional categories (time/money/paper/etc.) |
| `TIMEZONE` | e.g. `UTC` |
| `KEYMAP_CONSOLE` / `KEYMAP_X11_LAYOUT` / `KEYMAP_X11_MODEL` | TTY keymap vs. graphical (X11) keymap |
| `DESKTOP_ENV` | `cinnamon` or `none` (headless) — default answer for the install-type prompt |
| `AUTO_CONFIRM` | `true` skips *all* prompts (install type, boot mode, keyring update, confirmation) and runs unattended, defaulting to UEFI — use with care |

## Status

Verified end-to-end in a VirtualBox VM, both `DESKTOP_ENV=cinnamon` and
`DESKTOP_ENV=none`, both with and without the keyring-update prompt: boots
cleanly, no repeat of the initrd-hang issue seen during the manual install.

Not yet exercised: the multi-disk selection prompt, `SWAP_MODE=fixed`, and
real bare-metal hardware.
