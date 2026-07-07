#!/usr/bin/env bash
# Stage 1 — run this from the Arch ISO live environment (as root).
# Partitions the disk, formats it, pacstraps the base system, and
# hands off to chroot-setup.sh for in-chroot configuration.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

log()  { echo -e "\n==> $*"; }
err()  { echo "ERROR: $*" >&2; }

check_root() {
  [[ $EUID -eq 0 ]] || { err "Must run as root."; exit 1; }
}

check_internet() {
  ping -c1 -W2 archlinux.org &>/dev/null || { err "No internet connection."; exit 1; }
}

part_suffix() {
  local disk="$1" num="$2"
  if [[ "$disk" =~ [0-9]$ ]]; then
    echo "${disk}p${num}"
  else
    echo "${disk}${num}"
  fi
}

detect_disk() {
  [[ -n "$DISK" ]] && return

  mapfile -t disks < <(lsblk -dnpo NAME,TYPE | awk '$2=="disk"{print $1}')
  if [[ ${#disks[@]} -eq 0 ]]; then
    err "No disks found."
    exit 1
  elif [[ ${#disks[@]} -eq 1 ]]; then
    DISK="${disks[0]}"
  else
    echo "Multiple disks found:"
    lsblk -dpo NAME,SIZE,MODEL
    local i=1
    for d in "${disks[@]}"; do
      echo "  $i) $d"
      ((i++))
    done
    read -rp "Select disk number: " choice
    DISK="${disks[$((choice - 1))]}"
  fi
}

swap_size_mib() {
  local ram_mib
  ram_mib=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)
  if (( ram_mib <= 2048 )); then
    echo $(( ram_mib * 2 ))
  elif (( ram_mib <= 8192 )); then
    echo "$ram_mib"
  else
    echo 8192
  fi
}

detect_microcode() {
  local vendor
  vendor=$(awk -F: '/vendor_id/{print $2; exit}' /proc/cpuinfo | tr -d ' ')
  case "$vendor" in
    GenuineIntel) echo "intel-ucode" ;;
    AuthenticAMD) echo "amd-ucode" ;;
    *) echo "" ;;
  esac
}

detect_virt() {
  # systemd-detect-virt prints "none" on bare metal too, but still exits
  # non-zero in that case (its exit code is a separate is-virtualized
  # boolean) -- naively `|| echo "none"` on that double-prints ("none\nnone").
  local out
  out=$(systemd-detect-virt 2>/dev/null) || true
  echo "${out:-none}"
}

# Boot mode is an explicit user choice, not auto-detected -- virtualization
# detection (systemd-detect-virt) turned out to be an unreliable signal for
# this (e.g. reports "none" oddly on some bare-metal boards), so it's no
# longer used to pick BIOS vs UEFI. DETECTED_VIRT is still used separately
# for guest-utils package/service selection.
prompt_boot_mode() {
  if [[ "$AUTO_CONFIRM" == true ]]; then
    BOOT_MODE="uefi"
    return
  fi

  echo
  echo "Boot mode:"
  echo "  0) BIOS (legacy, MBR, no ESP)"
  echo "  1) UEFI (GPT + ESP)"
  read -rp "Choice [0/1] (default: 1): " choice
  choice="${choice:-1}"

  case "$choice" in
    0) BOOT_MODE="bios" ;;
    1) BOOT_MODE="uefi" ;;
    *) err "Invalid choice '$choice'."; exit 1 ;;
  esac

  if [[ "$BOOT_MODE" == "uefi" && ! -d /sys/firmware/efi/efivars ]]; then
    log "Warning: this session doesn't look like it's booted in UEFI mode (/sys/firmware/efi/efivars missing) -- grub-install may fail later."
  fi
}

virt_packages_for() {
  case "$1" in
    oracle)    echo "virtualbox-guest-utils" ;;
    kvm|qemu)  echo "qemu-guest-agent" ;;
    *)         echo "" ;;
  esac
}

de_packages_for() {
  case "$DESKTOP_ENV" in
    cinnamon)
      echo "xorg-server xorg-xinit lightdm lightdm-gtk-greeter cinnamon gnome-terminal gvfs gvfs-smb network-manager-applet xdg-user-dirs"
      ;;
    none) echo "" ;;
    *) err "Unknown DESKTOP_ENV: $DESKTOP_ENV"; exit 1 ;;
  esac
}

prompt_install_type() {
  [[ "$AUTO_CONFIRM" == true ]] && return

  local default=1
  [[ "$DESKTOP_ENV" == "none" ]] && default=0

  echo
  echo "Install type:"
  echo "  0) Minimal (no desktop environment)"
  echo "  1) Desktop environment (cinnamon)"
  read -rp "Choice [0/1] (default: $default): " choice
  choice="${choice:-$default}"

  case "$choice" in
    0) DESKTOP_ENV="none" ;;
    1) DESKTOP_ENV="cinnamon" ;;
    *) err "Invalid choice '$choice'."; exit 1 ;;
  esac
}

prompt_update_keyring() {
  UPDATE_KEYRING=false
  [[ "$AUTO_CONFIRM" == true ]] && return

  read -rp "Update keyrings before installing packages? Only needed if pacstrap fails on an old ISO. [y/N]: " ans
  [[ "$ans" =~ ^[Yy] ]] && UPDATE_KEYRING=true
  return 0
}

update_keyring() {
  log "Updating archlinux-keyring"
  pacman -Sy --noconfirm archlinux-keyring
}

confirm_plan() {
  echo
  echo "About to install Arch Linux with the following plan:"
  echo "  Disk:       $DISK (ALL DATA WILL BE ERASED)"
  echo "  Boot mode:  $BOOT_MODE"
  if [[ "$BOOT_MODE" == "uefi" ]]; then
    echo "  EFI:        ${EFI_SIZE_MIB}MiB"
  fi
  echo "  Swap mode:  $SWAP_MODE"
  echo "  Root fs:    $ROOT_FS"
  echo "  Hostname:   $HOSTNAME"
  echo "  User:       $USERNAME ($USER_GROUPS)"
  echo "  Locale:     $LOCALE_LANG (regional: $LOCALE_REGIONAL)"
  echo "  Timezone:   $TIMEZONE"
  echo "  Keymap:     $KEYMAP_CONSOLE (X11: $KEYMAP_X11_LAYOUT/$KEYMAP_X11_MODEL)"
  echo "  Desktop:    $DESKTOP_ENV"
  echo "  Keyring:    $([[ "$UPDATE_KEYRING" == true ]] && echo "update before install" || echo "skip")"
  echo "  Virt:       $DETECTED_VIRT"
  echo

  [[ "$AUTO_CONFIRM" == true ]] && return

  read -rp "Type 'yes' to continue: " ans
  [[ "$ans" == "yes" ]] || { echo "Aborted."; exit 1; }
}

deactivate_disk() {
  # A previous failed run may have left a mount and/or active swap on this
  # disk (format_partitions runs swapon before mount_partitions runs, so a
  # failure in between leaves swap on) -- both make the disk "busy" and
  # block wipefs/parted below with no useful error message otherwise.
  umount -R /mnt 2>/dev/null || true
  local dev
  while read -r dev; do
    [[ "$dev" == "$DISK"* ]] && swapoff "$dev" 2>/dev/null || true
  done < <(swapon --show=NAME --noheadings 2>/dev/null)
  return 0
}

partition_disk() {
  log "Partitioning $DISK"

  deactivate_disk

  # Wipe any filesystem/partition-table signatures left over from a previous
  # install on this disk (common when re-testing in a VM) -- otherwise stale
  # superblocks at offsets that land inside the new partitions can confuse
  # blkid/mount later, especially when switching between GPT and MBR.
  wipefs -a "$DISK"

  local swap_mib
  if [[ "$SWAP_MODE" == "auto" ]]; then
    swap_mib=$(swap_size_mib)
  else
    swap_mib="$SWAP_SIZE_MIB"
  fi

  if [[ "$BOOT_MODE" == "uefi" ]]; then
    local efi_end=$(( 1 + EFI_SIZE_MIB ))
    local swap_end=$(( efi_end + swap_mib ))

    parted --script "$DISK" \
      mklabel gpt \
      mkpart ESP fat32 1MiB "${efi_end}MiB" \
      set 1 esp on \
      mkpart primary linux-swap "${efi_end}MiB" "${swap_end}MiB" \
      mkpart primary ext4 "${swap_end}MiB" 100%

    partprobe "$DISK"
    udevadm settle

    EFI_PART=$(part_suffix "$DISK" 1)
    SWAP_PART=$(part_suffix "$DISK" 2)
    ROOT_PART=$(part_suffix "$DISK" 3)
  else
    # No ESP needed for legacy BIOS: GRUB embeds itself in the MBR gap and
    # /boot just lives inside the root filesystem.
    local swap_end=$(( 1 + swap_mib ))

    parted --script "$DISK" \
      mklabel msdos \
      mkpart primary linux-swap 1MiB "${swap_end}MiB" \
      mkpart primary ext4 "${swap_end}MiB" 100% \
      set 2 boot on

    partprobe "$DISK"
    udevadm settle

    SWAP_PART=$(part_suffix "$DISK" 1)
    ROOT_PART=$(part_suffix "$DISK" 2)
  fi
}

format_partitions() {
  log "Formatting partitions"
  [[ "$BOOT_MODE" == "uefi" ]] && mkfs.fat -F32 "$EFI_PART"
  mkswap "$SWAP_PART"
  swapon "$SWAP_PART"
  "mkfs.${ROOT_FS}" -F "$ROOT_PART"
}

mount_partitions() {
  log "Mounting partitions"
  mount "$ROOT_PART" /mnt
  if [[ "$BOOT_MODE" == "uefi" ]]; then
    mount --mkdir "$EFI_PART" /mnt/boot
  fi
}

pacstrap_system() {
  log "Installing base system (pacstrap)"

  local microcode virt_pkgs de_pkgs
  microcode=$(detect_microcode)
  virt_pkgs=$(virt_packages_for "$DETECTED_VIRT")
  de_pkgs=$(de_packages_for)

  local pkgs=(base linux linux-firmware networkmanager grub sudo vim nano git base-devel)
  [[ "$BOOT_MODE" == "uefi" ]] && pkgs+=(efibootmgr)
  [[ -n "$microcode" ]] && pkgs+=("$microcode")
  [[ -n "$virt_pkgs" ]] && pkgs+=($virt_pkgs)
  [[ -n "$de_pkgs" ]] && pkgs+=($de_pkgs)

  pacstrap -K /mnt "${pkgs[@]}"
}

genfstab_system() {
  log "Generating fstab"
  genfstab -U /mnt >> /mnt/etc/fstab
}

prompt_passwords() {
  local pw1 pw2

  read -rsp "Root password: " pw1; echo
  read -rsp "Confirm root password: " pw2; echo
  [[ "$pw1" == "$pw2" ]] || { err "Passwords do not match."; exit 1; }
  ROOT_PASSWORD="$pw1"

  read -rsp "Password for user $USERNAME: " pw1; echo
  read -rsp "Confirm password for $USERNAME: " pw2; echo
  [[ "$pw1" == "$pw2" ]] || { err "Passwords do not match."; exit 1; }
  USER_PASSWORD="$pw1"
}

prepare_chroot() {
  log "Preparing chroot setup"
  cp "$SCRIPT_DIR/config.sh" /mnt/root/config.sh
  cp "$SCRIPT_DIR/chroot-setup.sh" /mnt/root/chroot-setup.sh
  chmod +x /mnt/root/chroot-setup.sh

  install -m 600 /dev/null /mnt/root/.archinstall_secrets
  cat > /mnt/root/.archinstall_secrets <<EOF
ROOT_PASSWORD='${ROOT_PASSWORD}'
USER_PASSWORD='${USER_PASSWORD}'
DETECTED_VIRT='${DETECTED_VIRT}'
BOOT_MODE='${BOOT_MODE}'
DISK='${DISK}'
DESKTOP_ENV='${DESKTOP_ENV}'
EOF
}

run_chroot() {
  log "Entering chroot for system configuration"
  arch-chroot /mnt /root/chroot-setup.sh
}

cleanup_chroot_files() {
  rm -f /mnt/root/.archinstall_secrets /mnt/root/config.sh /mnt/root/chroot-setup.sh
}

main() {
  check_root
  check_internet

  prompt_install_type
  prompt_boot_mode

  detect_disk
  DETECTED_VIRT=$(detect_virt)

  prompt_passwords
  prompt_update_keyring
  confirm_plan

  partition_disk
  format_partitions
  mount_partitions
  [[ "$UPDATE_KEYRING" == true ]] && update_keyring
  pacstrap_system
  genfstab_system

  prepare_chroot
  trap cleanup_chroot_files EXIT
  run_chroot

  log "Installation finished. Unmounting."
  umount -R /mnt
  swapoff "$SWAP_PART" || true

  echo
  echo "All done. Run 'reboot' when ready."
}

main "$@"
