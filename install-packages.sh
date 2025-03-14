#!/bin/bash

# Install base-devel and required packages
echo -e "\e[32mInstalling dependencies..\e[0m" && sleep 2

# Define package files
PACMAN_PACKAGES_FILE="packages.txt"
PARU_PACKAGES_FILE="paru-packages.txt"

# Load packages from files into variables, ignoring comments and empty lines
PACMAN_PACKAGES=$(grep -vE '^\s*#' "$PACMAN_PACKAGES_FILE" | grep -vE '^\s*$')
PARU_PACKAGES=$(grep -vE '^\s*#' "$PARU_PACKAGES_FILE" | grep -vE '^\s*$')

# Function to install packages using a package manager
install_packages() {
  local package_manager=$1
  local package_list=$2

  echo -e "\e[36mInstalling packages using $package_manager...\e[0m"

  for package in $package_list; do
    if ! pacman -Q "$package" &>/dev/null; then
      echo -e "\e[33mInstalling $package...\e[0m"
      $package_manager -S --noconfirm --needed "$package"
    else
      echo -e "\e[32m$package is already installed.\e[0m"
    fi
  done
}

# Install packages from pacman and paru lists
install_packages "sudo pacman" "$PACMAN_PACKAGES"
echo -e "\e[32mAll Pacman packages are installed and up-to-date!\e[0m" && sleep 1

# Uncomment this if you want to use paru packages
install_packages "paru" "$PARU_PACKAGES"
echo -e "\e[32mAll Paru packages are installed and up-to-date!\e[0m" && sleep 1

echo -e "\e[32mDependencies installed... executing services & permissions...\e[0m" && sleep 1

# Update database and mandb
echo -e "\e[34mUpdating database...\e[0m"
sudo updatedb
echo -e "\e[34mUpdating man pages...\e[0m"
sudo mandb

# Enable necessary services
echo -e "\e[34mEnabling TLP and Bluetooth services...\e[0m"
sudo systemctl enable --now tlp
sudo systemctl enable --now bluetooth.service

# Add user to video group for permissions
echo -e "\e[34mAdding user to video group...\e[0m"
sudo usermod -aG video "$USER"
sudo usermod -aG input $USER

echo -e "\e[32mDone with permissions...\e[0m" && sleep 2
