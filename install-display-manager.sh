#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

echo -e "${CYAN}Display/Login Manager Setup${RESET}"

# Ask if the user wants to install a Display Manager
read -p "Would you like to install a Display/Login Manager? (y/n): " install_dm
install_dm="${install_dm:-y}"  # Default to "y" if no input is provided

if [[ "$install_dm" == "y" || "$install_dm" == "Y" ]]; then
  echo -e "${YELLOW}Choose a Display Manager:${RESET}"
  echo "1) SDDM (Simple Desktop Display Manager - GUI)"
  echo "2) LY (Simple TUI Login Manager - Terminal-based)"
  
  read -p "Enter your choice (1/2): " dm_choice
  
  if [[ "$dm_choice" == "1" ]]; then
    echo -e "${CYAN}Installing SDDM...${RESET}"

    # Install SDDM and related packages
    paru -S --noconfirm --needed sddm

    echo -e "${CYAN}Enabling SDDM to start at boot...${RESET}"
    sudo systemctl enable sddm.service

    # Check if the theme directory exists before copying
    if [[ -d ~/dotfiles/Extras/Extras/usr/share/sddm/themes/simple-sddm/ ]]; then
      sudo cp -r ~/dotfiles/Extras/Extras/usr/share/sddm/themes/simple-sddm/ /usr/share/sddm/themes
      echo -e "${GREEN}SDDM theme files copied successfully.${RESET}"
    else
      echo -e "${RED}SDDM theme files not found. Skipping theme setup.${RESET}"
    fi

    # Check if the SDDM configuration file exists before copying
    if [[ -f ~/dotfiles/Extras/Extras/etc/sddm.conf ]]; then
      sudo cp ~/dotfiles/Extras/Extras/etc/sddm.conf /etc/sddm.conf
      echo -e "${GREEN}SDDM configuration file copied successfully.${RESET}"
    else
      echo -e "${RED}SDDM configuration file not found. Skipping configuration setup.${RESET}"
    fi

    echo -e "${GREEN}SDDM has been installed and enabled to start at boot.${RESET}" && sleep 1

  elif [[ "$dm_choice" == "2" ]]; then
    echo -e "${CYAN}Installing LY...${RESET}"

    # Install LY and related packages
    paru -S --noconfirm --needed ly

    echo -e "${CYAN}Enabling LY to start at boot...${RESET}"
    sudo systemctl enable ly.service

    # Check if the LY configuration file exists before copying
    if [[ -f ~/dotfiles/Extras/Extras/etc/ly/config.ini ]]; then
      sudo cp ~/dotfiles/Extras/Extras/etc/ly/config.ini /etc/ly/config.ini
      echo -e "${GREEN}LY configuration file copied successfully.${RESET}"
    else
      echo -e "${RED}LY configuration file not found. Skipping configuration setup.${RESET}"
    fi

    echo -e "${GREEN}LY has been installed and enabled to start at boot.${RESET}" && sleep 1

  else
    echo -e "${RED}Invalid choice. No display manager installed.${RESET}" && sleep 1
  fi

else
  echo -e "${YELLOW}Display Manager installation skipped. Proceeding with the setup.${RESET}" && sleep 1
fi
