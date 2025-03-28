#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

echo -e "${CYAN}Downloading Wallpapers...${RESET}" && sleep 1

# Ask user if they want to download wallpapers
read -p "Would you like to download wallpapers? (y/n): " download_wallpapers
download_wallpapers="${download_wallpapers:-y}"  # Default to "y" if no input is provided

# Check if the user wants to download wallpapers
if [[ "$download_wallpapers" == "y" || "$download_wallpapers" == "Y" ]]; then
  # Check if pix folder is already in ~/Pictures/
  if [ ! -d "$HOME/Pictures/pix" ]; then
    echo -e "${YELLOW}Pix folder not found in Pictures. Downloading wallpapers...${RESET}"

    cd ~/Downloads/ || return
    curl -L -o wall.zip https://gitlab.com/chaganti-reddy1/wallpapers/-/archive/main/wallpapers-main.zip
    unzip wall.zip
    cd wallpapers-main || return

    # Check if bspwm is installed using pacman
    if pacman -Q bspwm &>/dev/null; then
      echo -e "${CYAN}Moving wallpapers to /usr/share/backgrounds/...${RESET}"
      # Move wallpapers to /usr/share/backgrounds/ from the wall folder
      sudo mkdir -p /usr/share/backgrounds/
      sudo mv wall/* /usr/share/backgrounds/
      echo -e "${GREEN}Wallpapers moved successfully to /usr/share/backgrounds/.${RESET}"
    fi

    # Move the pix folder to ~/Pictures/
    echo -e "${CYAN}Moving pix folder to ~/Pictures/...${RESET}"
    mv pix ~/Pictures/

    # Clean up and reset directories
    cd ~/Downloads/
    rm -rf wallpapers-main
    rm wall.zip
    cd ~/dotfiles/ || return

    echo -e "${GREEN}Wallpapers have been downloaded and installed successfully...${RESET}" && sleep 2
  else
    echo -e "${YELLOW}Pix folder already exists in ~/Pictures/, skipping download.${RESET}" && sleep 1
  fi

else
  echo -e "${YELLOW}Wallpapers download skipped. Proceeding with the setup.${RESET}" && sleep 1
fi
