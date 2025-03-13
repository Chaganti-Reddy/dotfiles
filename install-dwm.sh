#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

echo -e "${CYAN}Setting up dwm...${RESET}"

# Ask the user if they want to install dwm with default to "yes"
read -p "Would you like to install dwm (Dynamic Window Manager)? (y/n): " install_dwm
install_dwm="${install_dwm:-y}"  # Default to "y" if no input is provided

if [[ "$install_dwm" == "y" || "$install_dwm" == "Y" ]]; then
  echo -e "${YELLOW}Starting dwm installation...${RESET}"

  # Check if dwm and required directories already exist
  if command -v dwm &>/dev/null && [ -d ~/.config/dwm ] && [ -d ~/.config/slstatus ] && [ -d ~/.config/st ] && [ -d ~/.config/dmenu ]; then
    echo -e "${GREEN}dwm and its configurations are already installed. Skipping installation.${RESET}"
  else
    # Install dwm and related packages if missing
    echo -e "${YELLOW}Installing dwm and related packages...${RESET}"
    cd ~/dotfiles || return
    stow suckless/
    stow DWMScripts

    # Install dwm, slstatus, st, and dmenu
    if [ ! -d ~/.config/dwm ]; then
      echo -e "${YELLOW}Installing dwm...${RESET}"
      cd ~/.config/dwm && sudo make clean install
    fi
    if [ ! -d ~/.config/slstatus ]; then
      echo -e "${YELLOW}Installing slstatus...${RESET}"
      cd ~/.config/slstatus && sudo make clean install
    fi
    if [ ! -d ~/.config/st ]; then
      echo -e "${YELLOW}Installing st...${RESET}"
      cd ~/.config/st && sudo make install
    fi
    if [ ! -d ~/.config/dmenu ]; then
      echo -e "${YELLOW}Installing dmenu...${RESET}"
      cd ~/.config/dmenu && sudo make install
    fi

    # Install extra tools from the dotfiles repository
    echo -e "${YELLOW}Installing extra tools from the dotfiles repository...${RESET}"
    cd ~/dotfiles/Extras/Extras/waldl-master/ && sudo make install && cd ~/dotfiles || return
    sudo pacman -S xcompmgr

    # Set up dwm session if not already set up
    if [ ! -f /usr/share/xsessions/dwm.desktop ]; then
      echo -e "${YELLOW}Setting up dwm session...${RESET}"
      sudo mkdir -p /usr/share/xsessions/
      sudo cp ~/dotfiles/Extras/Extras/usr/share/xsessions/dwm.desktop /usr/share/xsessions
    fi

    echo -e "${GREEN}dwm has been successfully installed and configured.${RESET}"
  fi
  sleep 2
else
  echo -e "${YELLOW}dwm installation skipped. Proceeding with the setup.${RESET}" && sleep 1
fi
