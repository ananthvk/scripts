#!/bin/bash
# Note: Do not run in a real installation.
set -e
HOST_IP="http://192.168.122.1:8000"
DEVICE="/dev/vda"
EFI_PART="/dev/vda1"
ROOT_PART="/dev/vda2"
HOSTNAME="vm-arch"
USERNAME="archlinux"
PASSWORD="archlinux"

if [[ -z "$(ls -A /sys/firmware/efi/efivars 2>/dev/null)" ]]; then
    echo "UEFI not found, this script does not support BIOS (yet)...exiting"
    exit 1
fi

timedatectl set-timezone Asia/Kolkata
echo "Wiping filesystem"
wipefs --force --quiet --all "$DEVICE"
echo "Creating partitions and file systems"
parted -a optimal --script "$DEVICE" \
    mklabel gpt \
    mkpart EFI_PART fat32 "0%" 1000MiB \
    mkpart LINUX_PART ext4 1000MiB "100%" \
    set 1 boot on \
    set 1 esp on
mkfs.fat -F 32 -n EFI "$EFI_PART" > /dev/null
mkfs.ext4 -q -L linux_root "$ROOT_PART" > /dev/null

# Configure pacman mirrors and enable parallel downloads
sed -i.bak 's/#ParallelDownloads.*/ParallelDownloads = 16/' /etc/pacman.conf
echo "Server = $HOST_IP" > /etc/pacman.d/mirrorlist
reflector >> /etc/pacman.d/mirrorlist
# Update archlinux-keyring incase of older isos
pacman -Sy archlinux-keyring --disable-download-timeout --noconfirm > /dev/null

# Mount the partitions
mkdir -vp /mnt
mount $ROOT_PART /mnt
mount --mkdir $EFI_PART /mnt/boot

# Install some packages
pacstrap -K /mnt base linux linux-firmware base-devel neovim nano dhcpcd gcc make wget

# Generate the fstab
genfstab -U /mnt >> /mnt/etc/fstab

tee /mnt/chroot-install.sh > /dev/null << EOF
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
echo en_US.UTF-8 UTF-8 >> /etc/locale.gen
hwclock --systohc
locale-gen
echo LANG=en_US.UTF-8 >> /etc/locale.conf
echo $HOSTNAME > /etc/hostname
useradd -m $USERNAME
echo -e "$PASSWORD\n$PASSWORD" | sudo passwd "$USERNAME" -q > /dev/null
usermod -aG wheel,audio,video,storage $USERNAME
echo "Defaults insults" | sudo tee -a /etc/sudoers
echo "%wheel ALL=(ALL:ALL) ALL" | sudo tee -a /etc/sudoers
sed -i.bak 's/#ParallelDownloads.*/ParallelDownloads = 16/' /etc/pacman.conf
pacman -S --disable-download-timeout efibootmgr grub --noconfirm > /dev/null
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
mv /usr/bin/vi /usr/bin/vi.old
ln -s /usr/bin/nvim /usr/bin/vi
ln -s /usr/bin/nvim /usr/bin/vim
cat >> /etc/hosts <<- EOL
127.0.0.1   localhost
::1         localhost
127.0.0.1   $HOSTNAME
EOL
echo "nameserver 1.1.1.1 1.0.0.1" > /etc/resolv.conf
echo "static domain_name_servers=1.1.1.1 1.0.0.1 8.8.8.8 8.8.4.4" >> /etc/dhcpcd.conf
systemctl enable dhcpcd
EOF
chmod +x /mnt/chroot-install.sh
arch-chroot /mnt /chroot-install.sh
chmod -x /mnt/chroot-install.sh
(umount -R /mnt)
(umount -R /mnt/boot)
echo "Installation completed successfully. Reboot the machine."