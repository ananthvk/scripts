#!/bin/bash
# Run this script after the basic arch install (02_basic.sh)
# This script has to be run after rebooting, it will not work under arch-chroot

# $(if [[ "$localtime_in_rtc" = true ]]; then echo "timedatectl set-rtc-localtime"; fi)
# $(if [[ "$localtime_in_rtc" = true ]]; then echo "timedatectl set-local-rtc 1"; fi)
# timedatectl set-ntp 1
#
# echo "There might be issues with time if you are dual booting with windows"
# echo "One way to fix this is to make linux store the localtime in RTC instead of utc"
# localtime_in_rtc=false
# case $(read -t 10 -p "Do you want to apply this fix? (default:N, timeout:10s)? " var; echo $var) in
#     [Yy]* ) localtime_in_rtc=true ;;
# esac


yes | sudo pacman -Syyu plasma kde-applications networkmanager sddm xorg 