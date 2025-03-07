#!/bin/env bash
set -e

# Check if the script is run with sudo permissions
if [[ $EUID -eq 0 ]]; then
    echo "Do not run this script with sudo or as root!"
    exit 1
fi

echo "Running without sudo permissions. Proceeding..." && sleep 1

echo "Welcome to my Arch Setup!" && sleep 2
echo "Some parts of the script require sudo, so if you're planning on leaving the desktop while the installation script does its thing, better drop it already!." && sleep 4
#
# # Creating all required home directories if not present
mkdir -p ~/Downloads ~/dox ~/Music ~/Pictures ~/vid ~/Templates
#
echo "Created Directories..." && sleep 1
#
#
echo "Setting up pacman.conf..."
# Define the target line to find under which the lines should be appended
target_line="#UseSyslog"
# Define the first line to check (ILoveCandy)
check_line="ILoveCandy"

# Check if the 'ILoveCandy' line is already present under the target line
if sudo grep -q "$target_line" /etc/pacman.conf && sudo grep -q "$check_line" /etc/pacman.conf; then
  echo "'$check_line' is already present under '$target_line'. No changes are needed." && sleep 2
else
  # Provide an explanation of what will happen
  echo "This script will modify the /etc/pacman.conf file."
  echo "It will search for the line '$target_line' and append the following settings under it if 'ILoveCandy' is not found:"
  echo "ILoveCandy"
  echo "ParallelDownloads=10"
  echo "Color"
  echo ""
  echo "Do you want to proceed with this change? (y/n) [default: y]"

  # Read user input
  read -r response
  response=${response:-y} # Default to 'y' if the user presses Enter without input

  if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "Operation canceled. No changes were made."
    exit 0
  else
    # Perform the sed operation if the user confirms
    sudo sed -i "/$target_line/a\
ILoveCandy\nParallelDownloads=10\nColor" /etc/pacman.conf

    echo "The settings have been successfully added under '$target_line'." && sleep 2
  fi
fi

# System update
echo "Performing a full system update..."
sudo pacman --noconfirm -Syu --noconfirm --needed git
clear
echo "System update done" && sleep 2
clear

# --------------------------------------------------------------------------------------

bash ./install-aur-helper.sh
bash ./install-packages.sh
bash ./install-git.sh
bash ./install-shell.sh
bash ./install-gpg.sh
bash ./install-hypr.sh
bash ./install-conda.sh
bash ./install-kvm.sh
bash ./install-browser.sh
bash ./install-torrent.sh
bash ./install-dev-apps.sh
bash ./install-tools.sh
bash ./install-mariadb.sh
bash ./install-fonts.sh
bash ./install-dwm.sh
bash ./install-bspwm.sh
bash ./install-ollama.sh
bash ./install-pip-pack.sh
bash ./install-grub.sh
bash ./install-display-manager.sh
bash ./install-wallpapers.sh
bash ./install-extras.sh

clear
echo "All done! Please go through essentials.md before rebooting your system." && sleep 2
