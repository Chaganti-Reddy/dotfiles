#!/bin/bash

# Define color codes for easy use
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'  # Reset to default color

echo -e "${CYAN}Installing Browsers that I personally use the most...${RESET}" && sleep 1

# Function to check if a package is installed
is_installed() {
  pacman -Qi "$1" &>/dev/null
  return $?
}

# Function to display the browser selection menu
install_browser() {
  echo -e "${YELLOW}Select the browsers you want to install (you can select multiple by entering numbers separated by spaces):${RESET}"
  echo -e "1) Zen-Browser"
  echo -e "2) Firefox"
  echo -e "3) Chromium"
  echo -e "4) Vivaldi"
  echo -e "5) qutebrowser"
  echo -e "6) Brave (If none - Default)"
  echo -e "100) None (skip installation)"
  echo ""
  echo -e "${CYAN}Enter the numbers corresponding to your choices (e.g., 1 3 5), or press Enter to skip:${RESET}"

  # Read user input (browser choices)
  read -r choices
  choices=${choices:-6}  # Default to installing Zen-Browser if no input is provided

  # Process the selected options
  for choice in $choices; do
    case $choice in
      1)
	if is_installed "zen-browser-bin"; then
	  echo -e "${MAGENTA}Zen-Browser is already installed.${RESET}"
	else
	  echo -e "${CYAN}Installing Zen-Browser...${RESET}"
	  paru -S --noconfirm --needed zen-browser-bin
	  sudo npm install -g nativefier
	  pip install --index-url https://test.pypi.org/simple/ pywalfox==2.8.0rc1
	  pywalfox install
	  # Video Download Helper
	  curl -sSLf https://github.com/aclap-dev/vdhcoapp/releases/latest/download/install.sh | bash
	fi
	;;
      2)
	if is_installed "firefox"; then
	  echo -e "${MAGENTA}Firefox is already installed.${RESET}"
	else
	  echo -e "${CYAN}Installing Firefox...${RESET}"
	  sudo pacman -S --noconfirm firefox
	  pip install --index-url https://test.pypi.org/simple/ pywalfox==2.8.0rc1
	  pywalfox install
	  curl -sSLf https://github.com/aclap-dev/vdhcoapp/releases/latest/download/install.sh | bash
	fi
	;;
      3)
	if is_installed "chromium"; then
	  echo -e "${MAGENTA}Chromium is already installed.${RESET}"
	else
	  echo -e "${CYAN}Installing Chromium...${RESET}"
	  sudo pacman -S --noconfirm chromium
	fi
	;;
      4)
	if is_installed "vivaldi"; then
	  echo -e "${MAGENTA}Vivaldi is already installed.${RESET}"
	else
	  echo -e "${CYAN}Installing Vivaldi...${RESET}"
	  paru -S --noconfirm vivaldi
	fi
	;;
      5)
	if is_installed "qutebrowser"; then
	  echo -e "${MAGENTA}qutebrowser is already installed.${RESET}"
	else
	  echo -e "${CYAN}Installing qutebrowser...${RESET}"
	  sudo pacman -S --noconfirm qutebrowser
	fi
	;;
      6)
	if is_installed "brave-bin"; then
	  echo -e "${MAGENTA}Brave is already installed.${RESET}"
	else
	  echo -e "${CYAN}Installing Brave...${RESET}"
	  paru -S --noconfirm brave-bin
	  sudo npm install -g nativefier
	fi
	;;
      100)
	clear
	echo -e "${GREEN}Skipping all installations.${RESET}" && sleep 2
	return
	;;
      *)
	echo -e "${RED}Invalid choice: $choice${RESET}"
	;;
    esac
    echo -e "${GREEN}Selected browsers have been installed.${RESET}" && sleep 2
  done
}

# Call the browser installation function
install_browser
