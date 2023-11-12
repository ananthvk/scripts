#!/bin/bash
# $ bash <(curl- fsSL <IP>)

set -e
echo "Initializing arch install"
# Check if system is in UEFI mode
if [[ -n "$(ls -A /sys/firmware/efi/efivars 2>/dev/null)" ]]
then
    echo "UEFI system detected, Installing in UEFI mode"
else
    echo "UEFI not found, this script does not support BIOS (yet)...exiting"
    exit 1
fi

# Check network connectivity
echo "Checking network connectivity...."
if ping -q -c 3 -W 1 archlinux.org > /dev/null
then
    echo "Network reachable"
else
    echo "Network unreachable. Could not connect to the internet"
    # TODO: Detect WIFI and offer to configure it
    echo "Check your network connections and try again"
fi

# Set timezone for India
timedatectl set-timezone Asia/Kolkata

# Configuration: Ask info from the user
boot_part_reformat=false
echo "Please specify the partition(/dev/sdaX, /dev/nvme0n1pX, etc) for the following"
read -e -p "EFI [to be mounted at /efi]: " BOOT_PART
if [[ -z "$BOOT_PART" ]]; then echo "Please enter a valid boot partition...exiting"; exit 1; fi
read -e -p "Root [to be mounted at /] :" ROOT_PART
if [[ -z "$ROOT_PART" ]]; then echo "Please enter a valid root partition...exiting"; exit 1; fi
read -e -p "Home [to be monted at /home] (leave blank for no separate home partition): " HOME_PART
read -e -p "Swap [] (leave blank for no swap): " SWAP_PART


# Check if UEFI boot partition is already formatted.
if lsblk -f "$BOOT_PART" | grep -qF "FSTYPE"; then
    echo "Warning: $BOOT_PART is formatted, it may contain data from other OSes"
    echo "Reformatting may lead to data loss"
    read -e -p "Do you want to reformat it? (y/N): " answer
    if [[ "$answer" == "yes" || "$answer" == "y" || "$answer" == "Y" ]]; then boot_part_reformat=true; elif [[ "$answer" == "no" || "$answer" == "n" || "$answer" == "N" ]]; then boot_part_reformat=false; else echo "Invalid choice....exiting"; exit 1; fi
fi

read -p "Enter hostname of the machine (default archlinux): " hostname
if [[ -z $hostname ]]; then
    hostname="archlinux"
fi

read -p "Enter username for a new user (default arch): " username
if [[ -z $username ]]; then
    username="arch"
fi

while true; do
    read -s -p "Password: " password
    echo " "
    read -s -p "Password (confirmation): " password1
    echo " "
    if [ "$password" = "$password1" ]; then
        break
    else
        echo "Passwords do not match, try again"
    fi
done

mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.old || true
# Fork a subshell in which set -e is not present
# TODO: Check if mirror is working
case $(read -t 10 -p "Do you want to use a local pacman mirror (y/N) (default:N, timeout:10s)? " var; echo $var) in
    [Yy]* ) read -p "Enter address of pacman http cache mirror as http://<IP>:<PORT> : " mirror;
        echo "Server = $mirror" > /etc/pacman.d/mirrorlist;
        ;;
esac

# Print a summary of file system changes
echo "========================================"
echo "|           SUMMARY OF INSTALL         |"
echo "Filesystem changes:"
if [ "$boot_part_reformat" = true ]; then echo "Format $BOOT_PART fat32 [/efi]"; fi
echo "Format $ROOT_PART ext4  [/]"
if [[ ! -z "$HOME_PART" ]]; then echo "Format $HOME_PART ext4  [/home]"; fi
if [[ ! -z "$SWAP_PART" ]]; then echo "Format $SWAP_PART swap  [swap]"; fi
echo " "
echo "Other info:"
echo "Hostname: $hostname"
echo "Username: $username"

# Check confirmation
read -e -p "Do you want to continue (yes/no): " answer
if [[ "$answer" == "yes" || "$answer" == "y"  || "$answer" == "N" ]]; then echo " "; echo "Begin installation...."; elif [[ "$answer" == "no" || "$answer" == "n" || "$answer" == "N" ]]; then exit 0; else echo "Invalid choice....exiting"; exit 1; fi

# Format the partitions
if [ "$boot_part_reformat" = true ]; then
    echo "mkfs.fat -F 32 $BOOT_PART -n EFI"
    yes | mkfs.fat -F 32 $BOOT_PART -n EFI > /dev/null
fi
echo "mkfs.ext4 -q $ROOT_PART -L linux_root"; yes | mkfs.ext4 -q $ROOT_PART -L linux_root > /dev/null
if [[ ! -z "$HOME_PART" ]]; then
    echo "mkfs.ext4 $HOME_PART -L linux_home"
    yes | mkfs.ext4 -q $HOME_PART -L linux_home > /dev/null
fi
if [[ ! -z "$SWAP_PART" ]]; then
    echo "mkswap $SWAP_PART -L linux_swap"
    yes | mkswap -q $SWAP_PART -L linux_swap > /dev/null
fi

# VM specific commands
if [[ -n "$(dmesg --notime | grep -i hypervisor)" ]]; then
    # We are running in a VM
    # TODO: Install guest files
    echo "Detected that the OS is running on a VM"
fi

# Get recent mirrors
reflector >> /etc/pacman.d/mirrorlist
# Update archlinux-keyring incase of older isos
yes | pacman -Sy archlinux-keyring

# Mount the directories
echo " "
echo "Mounting filesystems at /mnt"
mkdir -vp /mnt
mount $ROOT_PART /mnt
mount --mkdir $BOOT_PART /mnt/efi
if [[ ! -z "$HOME_PART" ]]; then mount --mkdir $HOME_PART /mnt/home; fi
if [[ ! -z "$SWAP_PART" ]]; then swapon $SWAP_PART; fi

# Install some commonly used packages
pacstrap -K /mnt base linux linux-firmware base-devel neovim nano wpa_supplicant dhcpcd gcc make wget

# Generate the fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Configure some post install settings
# also install grub as bootloader
tee /mnt/chroot-install.sh > /dev/null << EOF
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
echo en_US.UTF-8 UTF-8 >> /etc/locale.gen
hwclock --systohc
locale-gen
echo LANG=en_US.UTF-8 >> /etc/locale.conf
echo $hostname > /etc/hostname
useradd -m $username
echo -e "$password\n$password" | sudo passwd "$username" -q > /dev/null
usermod -aG wheel,audio,video,storage $username
echo "Defaults insults" | sudo tee -a /etc/sudoers
echo "%wheel ALL=(ALL:ALL) ALL" | sudo tee -a /etc/sudoers
yes | pacman -S efibootmgr grub > /dev/null
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
mv /usr/bin/vi /usr/bin/vi.old
ln -s /usr/bin/nvim /usr/bin/vi
ln -s /usr/bin/nvim /usr/bin/vim
cat >> /etc/hosts <<- EOL
    127.0.0.1   localhost
    ::1         localhost
    127.0.0.1   $hostname
EOL
EOF
chmod +x /mnt/chroot-install.sh
arch-chroot /mnt /chroot-install.sh
chmod -x /mnt/chroot-install.sh
umount -R /mnt
echo "Installation completed successfully"
echo "Please run 03_kde.sh to install KDE desktop environment."
echo "After that reboot the machine."
echo "Then run 04_util.sh to enable services and install some common utilities"
echo "Run 05_dotfiles.sh to install dotfiles."
