#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

echo -e "${CYAN}Setting up Fonts...${RESET}" && sleep 1

# Check if the fonts directory exists
if [ -d "$HOME/.local/share/fonts/my-fonts-main" ]; then
  echo -e "${GREEN}Fonts directory already exists. Skipping installation...${RESET}" && sleep 1
else
  # Create fonts directory if it doesn't exist
  echo -e "${YELLOW}Creating fonts directory...${RESET}"
  mkdir -p ~/.local/share/fonts

  # Download the zip file
  echo -e "${YELLOW}Downloading fonts...${RESET}"
  curl -L -o ~/.local/share/fonts/my-fonts.zip https://gitlab.com/chaganti-reddy1/my-fonts/-/archive/main/my-fonts-main.zip

  # Extract the fonts
  echo -e "${YELLOW}Extracting fonts...${RESET}"
  unzip -q ~/.local/share/fonts/my-fonts.zip -d ~/.local/share/fonts

  # Clean up the downloaded zip file
  echo -e "${YELLOW}Cleaning up...${RESET}"
  rm ~/.local/share/fonts/my-fonts.zip

  echo -e "${GREEN}Fonts have been installed successfully.${RESET}" && sleep 2
fi
