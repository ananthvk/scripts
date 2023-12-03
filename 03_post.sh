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
# pacman -S xclip

cd ~
mkdir -p .zsh
echo >.zshenv << EOF export ZDOTDIR="~/.zsh" 
EOF
# Set some environment variables
export ZDOTDIR=~/.zsh
export ZSH=~/.zsh/.oh-my-zsh
export ZSH_CUSTOM=~/.zsh/.oh-my-zsh/custom
export CHSH="no"
export RUNZSH="no"

# Install oh-my-zsh
(cd "$ZDOTDIR" && curl -O https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)
sh "$ZDOTDIR/install.sh" --unattended

# Install zsh plugins - syntax highlighting
(cd $ZDOTDIR && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git)
echo "source ${ZDOTDIR}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc

# Install zsh autosuggestions
(cd $ZDOTDIR && git clone "https://github.com/zsh-users/zsh-autosuggestions" )
echo "source ${ZDOTDIR}/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc


(cd $ZDOTDIR && git clone https://github.com/zsh-users/zsh-history-substring-search)
echo "source ${ZDOTDIR}/zsh-history-substring-search/zsh-history-substring-search.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc

(cd $ZDOTDIR && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZDOTDIR/powerlevel10k)
echo "source $ZDOTDIR/powerlevel10k/powerlevel10k.zsh-theme" >> "${ZDOTDIR}/.zshrc"

(cd $ZDOTDIR && curl -SLO https://raw.githubusercontent.com/ananthvk/dotfiles/master/.zsh/.p10k.zsh)
(cd $ZDOTDIR && curl -SLO https://raw.githubusercontent.com/ananthvk/dotfiles/master/.zsh/.zshrc)

# Unset the variables
unset ZDOTDIR
unset ZSH
unset CHSH
unset RUNZSH

