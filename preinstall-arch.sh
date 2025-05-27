#!/bin/bash
# ===========================
# Preinstall script for Arch Linux on 'rakett'
# Author: ChatGPT (for Wim)
# ===========================
# This script should be run from the Arch ISO

set -e

# Replace this with your actual device
DISK=/dev/nvme0n1

# Partition the disk
parted -s $DISK \
  mklabel gpt \
  mkpart ESP fat32 1MiB 513MiB \
  set 1 boot on \
  mkpart primary ext4 513MiB 105GB \
  mkpart primary ext4 105GB 505GB \
  mkpart primary ext4 505GB 100%

mkfs.fat -F32 ${DISK}p1
mkfs.ext4 ${DISK}p2
mkfs.ext4 ${DISK}p3
# Leave ${DISK}p4 unformatted for now (used later for NAS buffer)

# Mount partitions
mount ${DISK}p2 /mnt
mkdir /mnt/{boot,home,buffer}
mount ${DISK}p1 /mnt/boot
mount ${DISK}p3 /mnt/home
mount ${DISK}p4 /mnt/buffer

# Install base system
pacstrap -K /mnt base linux linux-firmware zsh vim sudo networkmanager grub efibootmgr git

# Generate fstab
genfstab -U /mnt >>/mnt/etc/fstab

# Download install script
curl -L https://raw.githubusercontent.com/YOURUSERNAME/arch-install-rakett/main/install.sh -o /mnt/install.sh
chmod +x /mnt/install.sh

# Chroot into the new system
echo "Now chroot into /mnt and run ./install.sh manually:"
echo "arch-chroot /mnt"
echo "cd / && ./install.sh"
