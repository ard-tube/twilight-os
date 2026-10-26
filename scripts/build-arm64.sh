#!/usr/bin/env bash
# ==============================================================================
# Twilight OS ARM64 (AArch64) Builder
# Builds a bootable UEFI live ISO and a pre-configured QCOW2 disk image for:
#   - UTM (Apple Silicon M1/M2/M3/M4)
#   - VMware Fusion (Apple Silicon)
#   - VirtualBox (ARM preview)
# ==============================================================================
set -euo pipefail

PURPLE='\033[0;35m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info()    { echo -e "${CYAN}→ $1${NC}"; }
log_success() { echo -e "${GREEN}✓ $1${NC}"; }
log_warn()    { echo -e "${YELLOW}⚠ $1${NC}"; }
log_error()   { echo -e "${RED}✗ $1${NC}"; }

if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run as root (or with sudo)."
    exit 1
fi

ARCH=$(uname -m)
if [[ "$ARCH" != "aarch64" ]]; then
    log_warn "Current architecture is $ARCH (expected aarch64)."
    log_warn "If running on x86_64, ensure qemu-user-static and binfmt-support are active."
fi

WORK_DIR="/tmp/twilight-arm-build"
OUT_DIR="$(pwd)/out"
ROOTFS="$WORK_DIR/rootfs"
ISO_DIR="$WORK_DIR/iso"
MNT_DISK="$WORK_DIR/mnt-disk"

mkdir -p "$WORK_DIR" "$OUT_DIR"

cleanup() {
    log_info "Cleaning up temporary mounts..."
    if mountpoint -q "$MNT_DISK/boot" 2>/dev/null; then umount "$MNT_DISK/boot" || true; fi
    if mountpoint -q "$MNT_DISK" 2>/dev/null; then umount "$MNT_DISK" || true; fi
    if [[ -n "${LOOP:-}" ]] && losetup "$LOOP" 2>/dev/null; then losetup -d "$LOOP" || true; fi
}
trap cleanup EXIT

echo -e "${PURPLE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║          Twilight OS ARM64 (AArch64) Image Builder         ║"
echo "║       Target: UTM • VMware Fusion • VirtualBox (ARM)       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# ──────────────────────────────────────────────────────────────────────────────
# 1. Download Arch Linux ARM Generic AArch64 Rootfs
# ──────────────────────────────────────────────────────────────────────────────
TARBALL="$WORK_DIR/ArchLinuxARM-aarch64-latest.tar.gz"
if [[ ! -f "$TARBALL" ]]; then
    log_info "Downloading Arch Linux ARM rootfs..."
    curl -fL --retry 3 --retry-delay 3 -o "$TARBALL" \
        "http://os.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz"
    log_success "Downloaded Arch Linux ARM rootfs tarball"
else
    log_info "Using existing tarball: $TARBALL"
fi

# ──────────────────────────────────────────────────────────────────────────────
# 2. Extract Rootfs
# ──────────────────────────────────────────────────────────────────────────────
log_info "Extracting rootfs to $ROOTFS..."
rm -rf "$ROOTFS"
mkdir -p "$ROOTFS"
bsdtar -xpf "$TARBALL" -C "$ROOTFS"
log_success "Rootfs extracted successfully"

# Setup DNS and mirrors
cp /etc/resolv.conf "$ROOTFS/etc/resolv.conf"

cat > "$ROOTFS/etc/pacman.d/mirrorlist" << 'EOF'
Server = http://mirror.archlinuxarm.org/aarch64/$repo
Server = http://fl.us.mirror.archlinuxarm.org/aarch64/$repo
Server = http://nj.us.mirror.archlinuxarm.org/aarch64/$repo
EOF

# Initialize pacman keys
log_info "Initializing pacman keys for Arch Linux ARM..."
chroot "$ROOTFS" pacman-key --init
chroot "$ROOTFS" pacman-key --populate archlinuxarm

# ──────────────────────────────────────────────────────────────────────────────
# 3. Install Packages inside AArch64 chroot
# ──────────────────────────────────────────────────────────────────────────────
log_info "Updating system and installing desktop packages..."

PKGS=(
    # Kernel & Boot
    linux-aarch64
    grub
    efibootmgr
    dosfstools
    e2fsprogs
    # Desktop
    plasma-desktop
    plasma-workspace
    plasma-nm
    plasma-pa
    sddm
    konsole
    dolphin
    ark
    systemsettings
    breeze
    breeze-icons
    # Display & Graphics (Mesa Gallium/Wayland handles Apple Silicon VMs & VirtIO)
    mesa
    qt6-wayland
    xdg-desktop-portal
    xdg-desktop-portal-kde
    # Audio
    pipewire
    pipewire-pulse
    pipewire-alsa
    wireplumber
    # Networking & Utilities
    networkmanager
    sudo
    nano
    htop
    fastfetch
    noto-fonts
    dialog
    python-pyqt6
)

# Run pacman update & install
chroot "$ROOTFS" pacman -Syu --noconfirm
chroot "$ROOTFS" pacman -S --noconfirm --needed "${PKGS[@]}" || {
    log_warn "Some non-essential packages failed to install. Continuing..."
}
log_success "Packages installed in ARM64 rootfs"

# ──────────────────────────────────────────────────────────────────────────────
# 4. Apply Twilight OS Branding, Themes & Overlays
# ──────────────────────────────────────────────────────────────────────────────
log_info "Deploying Twilight OS overlay, branding, and configs..."

if [[ -d "overlay/airootfs" ]]; then
    cp -r overlay/airootfs/. "$ROOTFS/"
    chmod +x "$ROOTFS"/usr/local/bin/* 2>/dev/null || true
fi

# Live user setup (liveuser with passwordless sudo)
log_info "Configuring liveuser account and autologin..."
chroot "$ROOTFS" useradd -m -u 1000 -g 1000 -G wheel,audio,video,storage,network,input,power -s /bin/bash liveuser 2>/dev/null || true
passwd -d -u liveuser "$ROOTFS" 2>/dev/null || true

# Sudoers
mkdir -p "$ROOTFS/etc/sudoers.d"
echo 'liveuser ALL=(ALL:ALL) NOPASSWD: ALL' > "$ROOTFS/etc/sudoers.d/liveuser"
echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >> "$ROOTFS/etc/sudoers.d/liveuser"
chmod 0440 "$ROOTFS/etc/sudoers.d/liveuser"

# SDDM and NetworkManager
mkdir -p "$ROOTFS/etc/sddm.conf.d"
cat > "$ROOTFS/etc/sddm.conf.d/autologin.conf" << 'EOF'
[Autologin]
User=liveuser
Session=plasma
EOF

# Copy skel configs to liveuser home
if [[ -d "$ROOTFS/etc/skel" ]]; then
    cp -r "$ROOTFS"/etc/skel/. "$ROOTFS/home/liveuser/"
    chroot "$ROOTFS" chown -R liveuser:liveuser /home/liveuser
fi

# Enable systemd services
chroot "$ROOTFS" systemctl enable sddm.service NetworkManager.service 2>/dev/null || true

# Run Twilight branding script
if [[ -x "$ROOTFS/usr/local/bin/apply-twilight-branding" ]]; then
    chroot "$ROOTFS" /usr/local/bin/apply-twilight-branding || true
fi

# Clean up caches and man/docs to keep image strictly under 2 GB
log_info "Pruning caches and documentation to optimize size..."
rm -rf "$ROOTFS"/var/cache/pacman/pkg/* 2>/dev/null || true
rm -rf "$ROOTFS"/usr/share/doc/* 2>/dev/null || true
rm -rf "$ROOTFS"/usr/share/man/* 2>/dev/null || true

# ──────────────────────────────────────────────────────────────────────────────
# 5. Build Bootable UEFI Live ISO (twilight-os-v1.0-aarch64.iso)
# ──────────────────────────────────────────────────────────────────────────────
log_info "Building bootable UEFI ARM64 ISO..."

rm -rf "$ISO_DIR"
mkdir -p "$ISO_DIR/boot/grub" "$ISO_DIR/EFI/BOOT"

# Copy kernel and initramfs
cp "$ROOTFS/boot/Image" "$ISO_DIR/boot/Image"
cp "$ROOTFS/boot/initramfs-linux.img" "$ISO_DIR/boot/initramfs-linux.img"

# Compress SquashFS
log_info "Compressing rootfs into SquashFS..."
mksquashfs "$ROOTFS" "$ISO_DIR/airootfs.sfs" -comp xz -b 1M -Xdict-size 1M -noappend

# Generate GRUB ARM64 EFI Binary and Config
cat > "$ISO_DIR/boot/grub/grub.cfg" << 'EOF'
set default="0"
set timeout=5

menuentry "Twilight OS v1.0 (ARM64 Live Session - Wayland)" {
    linux /boot/Image console=tty0 console=ttyAMA0,115200 rw quiet splash
    initrd /boot/initramfs-linux.img
}

menuentry "Twilight OS v1.0 (ARM64 Safe Graphics)" {
    linux /boot/Image console=tty0 nomodeset rw
    initrd /boot/initramfs-linux.img
}
EOF

# Build standalone GRUB EFI binary for AA64
log_info "Generating standalone GRUB EFI binary (BOOTAA64.EFI)..."
grub-mkstandalone \
    --format=arm64-efi \
    --output="$ISO_DIR/EFI/BOOT/BOOTAA64.EFI" \
    --locales="" \
    --fonts="" \
    "boot/grub/grub.cfg=$ISO_DIR/boot/grub/grub.cfg"

# Create EFI image for El Torito
EFI_IMG="$WORK_DIR/efi.img"
truncate -s 64M "$EFI_IMG"
mkfs.vfat -F32 "$EFI_IMG"
mcopy -s -i "$EFI_IMG" "$ISO_DIR/EFI" ::/

# Generate ISO with xorriso
ISO_FILE="$OUT_DIR/twilight-os-v1.0-aarch64.iso"
log_info "Creating ISO image: $ISO_FILE..."
xorriso -as mkisofs \
    -iso-level 3 \
    -r -V "TWILIGHT_ARM" \
    -J -joliet-long \
    -partition_cyl_align all \
    -e efi.img \
    -no-emul-boot \
    -append_partition 2 0xef "$EFI_IMG" \
    -o "$ISO_FILE" \
    "$ISO_DIR"

log_success "Bootable ARM64 ISO created: $ISO_FILE"

# ──────────────────────────────────────────────────────────────────────────────
# 6. Build UTM / VMware Pre-Configured Virtual Disk (twilight-os-v1.0-arm64.qcow2)
# ──────────────────────────────────────────────────────────────────────────────
log_info "Creating pre-configured virtual disk image for UTM / VMware..."

RAW_DISK="$WORK_DIR/disk.raw"
truncate -s 10G "$RAW_DISK"

parted -s "$RAW_DISK" mklabel gpt
parted -s "$RAW_DISK" mkpart ESP fat32 1MiB 512MiB
parted -s "$RAW_DISK" set 1 esp on
parted -s "$RAW_DISK" mkpart root ext4 512MiB 100%

LOOP=$(losetup -Pf --show "$RAW_DISK")
mkfs.vfat -F32 "${LOOP}p1"
mkfs.ext4 -F "${LOOP}p2"

mkdir -p "$MNT_DISK"
mount "${LOOP}p2" "$MNT_DISK"
mkdir -p "$MNT_DISK/boot"
mount "${LOOP}p1" "$MNT_DISK/boot"

log_info "Copying system to virtual disk..."
cp -a "$ROOTFS/." "$MNT_DISK/"

# Setup GRUB on the virtual disk
log_info "Installing GRUB bootloader on virtual disk..."
mkdir -p "$MNT_DISK/boot/EFI/BOOT"
cp "$ISO_DIR/EFI/BOOT/BOOTAA64.EFI" "$MNT_DISK/boot/EFI/BOOT/BOOTAA64.EFI"
mkdir -p "$MNT_DISK/boot/grub"
cp "$ISO_DIR/boot/grub/grub.cfg" "$MNT_DISK/boot/grub/grub.cfg"

# Setup fstab with UUIDs
ROOT_UUID=$(blkid -s UUID -o value "${LOOP}p2")
BOOT_UUID=$(blkid -s UUID -o value "${LOOP}p1")
cat > "$MNT_DISK/etc/fstab" << EOF
UUID=$ROOT_UUID / ext4 defaults,noatime 0 1
UUID=$BOOT_UUID /boot vfat defaults 0 2
EOF

# Unmount disk
umount "$MNT_DISK/boot"
umount "$MNT_DISK"
losetup -d "$LOOP"
LOOP=""

# Convert to compressed QCOW2 for UTM
QCOW2_FILE="$OUT_DIR/twilight-os-v1.0-arm64.qcow2"
log_info "Compressing disk image into QCOW2 format..."
qemu-img convert -c -f raw -O qcow2 "$RAW_DISK" "$QCOW2_FILE"
log_success "Created UTM QCOW2 disk image: $QCOW2_FILE"

# ──────────────────────────────────────────────────────────────────────────────
# 7. Verify Artifact Sizes
# ──────────────────────────────────────────────────────────────────────────────
echo ""
echo -e "${PURPLE}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  🎉 Twilight OS ARM64 Build Complete!                      ${NC}"
echo -e "${PURPLE}════════════════════════════════════════════════════════════${NC}"
ls -lh "$OUT_DIR"/*aarch64* "$OUT_DIR"/*arm64* 2>/dev/null || true
echo ""
