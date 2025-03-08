#!/bin/bash

# Define color codes for easy use
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'  # Reset to default color

# Ask the user if they want to install Hyprland (default is yes)
echo -e "${CYAN}Would you like to install Hyprland and its dependencies? (y/n) [default: y]${RESET}"
read -r install_hyprland
install_hyprland=${install_hyprland:-y}  # Default to "y" if no input is provided

if [[ "$install_hyprland" =~ ^[Yy]$ ]]; then
  echo -e "${CYAN}Hyprland installation will begin now...${RESET}"

  # Function to check if a package is installed
  is_installed() {
    pacman -Qi "$1" &>/dev/null || paru -Q "$1" &>/dev/null
  }

  # Function to install a package if not already installed
  install_package() {
    local package_name=$1
    local display_name=$2
    local command=$3

    if is_installed "$package_name"; then
      echo -e "${GREEN}$display_name ($package_name) is already installed.${RESET}"
    else
      echo -e "${YELLOW}Installing $display_name ($package_name)...${RESET}"
      $command "$package_name"
    fi
  }

  # List of packages to install
  packages=(
    "hyprland-git"
    "hyprlock-git"
    "xdg-desktop-portal-hyprland-git"
    "hyprlang-git"
    "clipse-bin"
    "hyde-cli-git"
    "hyprland-qtutils-git"
    "bluetui"
    "hyprpicker-git"
    "hyprpaper-git"
    "pyprland-git"
    "kitty"
    "system-config-printer"
    "chafa"
    "hypridle"
    "waybar"
    "wl-clipboard"
    "speech-dispatcher"
    "brightnessctl"
    "cmake"
    "meson"
    "cpio"
    "grim"
    "slurp"
    "wtype"
    "wf-recorder"
    "wofi"
  )

  # Install the packages
  for package in "${packages[@]}"; do
    install_package "$package" "$package" "paru -S --noconfirm --needed"
  done

  # Set up Hyprland configuration
  echo -e "${CYAN}Configuring Hyprland...${RESET}"

  # Check if the username is "karna"
  if [ "$(whoami)" == "karna" ]; then
    stow_folder="hyprland"
  else
    stow_folder="hyprland_gen"
  fi

  # Create the configuration file if it doesn't exist
  if [ ! -f "$HOME/.config/hypr/hyprland.conf" ]; then
    cd ~/dotfiles || return
    stow "$stow_folder"
    stow wofi
    stow rofi
    echo -e "${GREEN}Hyprland configuration ($stow_folder) has been set up.${RESET}"
  else
    echo -e "${YELLOW}Hyprland configuration file already exists.${RESET}"
  fi

  # Install waldl if not already installed
  echo -e "${CYAN}Installing waldl...${RESET}"
  cd ~/dotfiles/Extras/Extras/waldl-master/ && sudo make install && cd ~/dotfiles || return

  echo -e "${GREEN}Setup is complete. Proceeding to next modules...${RESET}" && sleep 2
  clear
else
  echo -e "${YELLOW}Hyprland installation skipped. Proceeding with the setup...${RESET}" && sleep 1
fi
