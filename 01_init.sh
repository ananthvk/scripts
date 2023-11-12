#!/bin/bash
# Run with curl -fsSL <IP> | bash
# If there is interactive input, use
# bash <(curl- fsSL <IP>)

# Set to fail in case of any error
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
echo "DONE"
echo "========================================"
echo "Please create partitions manually using fdisk, cfdisk, gdisk, cgdisk, parted or any other tool."
echo "Please provide atleast 1GB for the EFI partition(/efi). Then run 02_basic.sh"
