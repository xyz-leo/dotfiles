#!/usr/bin/env bash
# Stage 2 — executed inside arch-chroot by archinstall.sh. Not meant to be run standalone.

set -euo pipefail

cd /root
source ./config.sh
source ./.archinstall_secrets

log() { echo -e "\n==> $*"; }
err() { echo "ERROR: $*" >&2; }

# Uncomments the locale in /etc/locale.gen if present and commented;
# appends it if missing entirely (covers locale.gen files that don't
# ship the entry commented out, e.g. minimal/custom base images).
enable_locale() {
  local locale="$1"
  if grep -qE "^${locale} UTF-8" /etc/locale.gen; then
    return
  elif grep -qE "^#${locale} UTF-8" /etc/locale.gen; then
    sed -i "s/^#${locale} UTF-8/${locale} UTF-8/" /etc/locale.gen
  else
    echo "${locale} UTF-8" >> /etc/locale.gen
  fi
}

log "Setting timezone"
ln -sf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
hwclock --systohc

log "Generating locale"
enable_locale "$LOCALE_LANG"
[[ "$LOCALE_REGIONAL" != "$LOCALE_LANG" ]] && enable_locale "$LOCALE_REGIONAL"
locale-gen

cat > /etc/locale.conf <<EOF
LANG=${LOCALE_LANG}
LC_TIME=${LOCALE_REGIONAL}
LC_MONETARY=${LOCALE_REGIONAL}
LC_PAPER=${LOCALE_REGIONAL}
LC_MEASUREMENT=${LOCALE_REGIONAL}
LC_NAME=${LOCALE_REGIONAL}
LC_ADDRESS=${LOCALE_REGIONAL}
LC_TELEPHONE=${LOCALE_REGIONAL}
EOF

log "Setting console keymap"
echo "KEYMAP=${KEYMAP_CONSOLE}" > /etc/vconsole.conf

log "Setting hostname"
echo "$HOSTNAME" > /etc/hostname
cat > /etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${HOSTNAME}.localdomain ${HOSTNAME}
EOF

log "Enabling NetworkManager"
systemctl enable NetworkManager

log "Setting root password"
echo "root:${ROOT_PASSWORD}" | chpasswd

log "Creating user $USERNAME"
useradd -m -G "$USER_GROUPS" -s /bin/bash "$USERNAME"
echo "${USERNAME}:${USER_PASSWORD}" | chpasswd

log "Configuring sudo for wheel group"
# Drop-in file instead of sed'ing /etc/sudoers directly: doesn't depend on
# matching an exact commented-out line, and is validated before being trusted.
if ! grep -qE '^[#@]includedir /etc/sudoers.d' /etc/sudoers; then
  echo "@includedir /etc/sudoers.d" >> /etc/sudoers
fi
echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/99-wheel
chmod 440 /etc/sudoers.d/99-wheel
if ! visudo -cf /etc/sudoers.d/99-wheel; then
  err "Generated sudoers drop-in failed validation; removing it."
  rm -f /etc/sudoers.d/99-wheel
  exit 1
fi

log "Installing GRUB ($BOOT_MODE)"
if [[ "$BOOT_MODE" == "uefi" ]]; then
  if ! grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB; then
    log "Standard GRUB install failed, retrying with --removable (NVRAM likely unavailable, e.g. some VM firmwares)"
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --removable
  fi
else
  grub-install --target=i386-pc "$DISK"
fi
grub-mkconfig -o /boot/grub/grub.cfg

if [[ "$DESKTOP_ENV" != "none" ]]; then
  case "$DESKTOP_ENV" in
    cinnamon) display_manager="lightdm" ;;
    gnome)    display_manager="gdm" ;;
    kde)      display_manager="sddm" ;;
    *) err "Unknown DESKTOP_ENV: $DESKTOP_ENV"; exit 1 ;;
  esac

  log "Enabling $display_manager"
  systemctl enable "$display_manager"

  # Read by both X11 sessions and Wayland compositors (via systemd-localed),
  # so this applies regardless of which DE/session type is in use.
  mkdir -p /etc/X11/xorg.conf.d
  cat > /etc/X11/xorg.conf.d/00-keyboard.conf <<EOF
Section "InputClass"
    Identifier "system-keyboard"
    MatchIsKeyboard "on"
    Option "XkbLayout" "${KEYMAP_X11_LAYOUT}"
    Option "XkbModel" "${KEYMAP_X11_MODEL}"
EndSection
EOF
fi

case "$DETECTED_VIRT" in
  oracle)
    log "Enabling VirtualBox guest services"
    systemctl enable vboxservice
    ;;
  kvm|qemu)
    log "Enabling QEMU guest agent"
    systemctl enable qemu-guest-agent
    ;;
esac

log "Chroot setup finished"
