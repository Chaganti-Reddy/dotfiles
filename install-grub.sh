#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

echo -e "${CYAN}Setting up GRUB theme...${RESET}"

# Ask the user if they want to set up a GRUB theme, defaulting to "yes"
read -p "Would you like to install a GRUB theme? (y/n): " install_grub_theme
install_grub_theme="${install_grub_theme:-y}"  # Default to "y" if no input is provided

# Check if the user wants to install the GRUB theme
if [[ "$install_grub_theme" == "y" || "$install_grub_theme" == "Y" ]]; then
  echo -e "${YELLOW}GRUB theme setup will begin now.${RESET}"

  # Check if the theme directory exists before copying
  if [[ -d ~/dotfiles/Extras/Extras/boot/grub/themes/SekiroShadow/ ]]; then
    # Copy the GRUB theme files if they exist
    echo -e "${CYAN}Copying GRUB theme files...${RESET}"
    sudo cp -r ~/dotfiles/Extras/Extras/boot/grub/themes/SekiroShadow/ /boot/grub/themes/
    echo -e "${GREEN}GRUB theme files copied successfully.${RESET}"
  else
    echo -e "${RED}GRUB theme files not found. Skipping theme setup.${RESET}"
    exit 1  # Exit if the theme files are missing
  fi

  # Enable the GRUB theme in the GRUB configuration
  echo -e "${CYAN}Setting GRUB theme...${RESET}"
  if ! grep -q 'GRUB_THEME="/boot/grub/themes/SekiroShadow/theme.txt"' /etc/default/grub; then
    echo 'GRUB_THEME="/boot/grub/themes/SekiroShadow/theme.txt"' | sudo tee -a /etc/default/grub
  fi

  # Enable os-prober in GRUB configuration if not already set
  echo -e "${CYAN}Enabling os-prober in GRUB configuration...${RESET}"
  if ! grep -q 'GRUB_DISABLE_OS_PROBER="false"' /etc/default/grub; then
    echo 'GRUB_DISABLE_OS_PROBER="false"' | sudo tee -a /etc/default/grub
  fi

  # Regenerate GRUB configuration
  echo -e "${CYAN}Regenerating GRUB configuration...${RESET}"
  sudo grub-mkconfig -o /boot/grub/grub.cfg

  echo -e "${GREEN}GRUB theme setup is complete, and GRUB config has been updated.${RESET}"
  sleep 2
else
  echo -e "${YELLOW}GRUB theme setup skipped. Proceeding with the setup.${RESET}" && sleep 1
fi
