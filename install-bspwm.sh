#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

echo -e "${CYAN}Setting up BSPWM...${RESET}"

# Ask the user if they want to install bspwm with default to "yes"
read -p "Would you like to install bspwm? (y/n): " install_bspwm
install_bspwm="${install_bspwm:-y}"  # Default to "y" if no input is provided

if [[ "$install_bspwm" == "y" || "$install_bspwm" == "Y" ]]; then
  echo -e "${YELLOW}Starting bspwm installation...${RESET}"

  # List of packages to install
  bspwm_packages=(
    "bspwm" "sxhkd" "pastel" "alacritty" "polybar" "xfce4-power-manager"
    "xsettingsd" "xorg-xsetroot" "wmname" "xcolor" "yad" "pulsemixer"
    "maim" "feh" "ksuperkey" "betterlockscreen" "light" "networkmanager-dmenu-git"
  )

  # Loop through each package and install if not already installed
  for pkg in "${bspwm_packages[@]}"; do
    if ! pacman -Q "$pkg" &>/dev/null; then
      echo -e "${YELLOW}$pkg is not installed. Installing...${RESET}"
      paru -S --noconfirm --needed "$pkg"
    else
      echo -e "${GREEN}$pkg is already installed.${RESET}"
    fi
  done

  # Set up configuration files
  echo -e "${YELLOW}Setting up bspwm configurations...${RESET}"
  cd ~/dotfiles || return
  stow feh
  stow bspwm/
  stow network-dmenu/

  # Install additional extras if needed
  echo -e "${YELLOW}Installing additional extras from the dotfiles repository...${RESET}"
  cd ~/dotfiles/Extras/Extras/waldl-master/ && sudo make install && cd ~/dotfiles || return

  echo -e "${GREEN}bspwm has been successfully installed and configured.${RESET}"
  sleep 2
else
  echo -e "${YELLOW}bspwm installation skipped. Proceeding with the setup.${RESET}" && sleep 1
fi
