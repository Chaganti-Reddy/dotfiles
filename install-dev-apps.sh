#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'

echo -e "${CYAN}Setting up development tools, office tools, communication tools, and multimedia tools...${RESET}" && sleep 1

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
    $command "$package_name" || { echo -e "${RED}$display_name installation failed${RESET}"; exit 1; }
  fi
}

# Function to install multiple packages for a single tool
install_multiple_packages() {
  local packages=("$@")
  for package in "${packages[@]}"; do
    install_package "$package" "$package" "paru -S --noconfirm --needed" || { echo -e "${RED}Installation of $package failed${RESET}"; exit 1; }
  done
}

# Display tool options
echo -e "${BLUE}Choose tools to install (enter numbers separated by spaces):${RESET}"
cat << EOF
1) Visual Studio Code        2) GitHub Desktop        3) Docker
4) Docker Desktop            5) Kubernetes            6) LaTeX
7) Discord                   8) Obsidian              9) Telegram
10) LibreOffice              11) OnlyOffice           12) Skype
13) Slack                    14) Zoom                 15) Blender
16) Octave                   17) OBS Studio           18) Inkscape
19) GIMP                     20) VLC                  21) Audacity
22) Krita                    23) Shotcut              24) Steam
25) Minecraft                26) YouTUI               27) YTerMusic
28) Todoist CLI              29) Geary                30) KeepassXC
EOF

echo -e "${CYAN}Enter your choices (e.g., 1 2 4), or press Enter to skip:${RESET}"
read -r tools_choices
tools_choices=${tools_choices:-} # Default to empty if no input is provided

if [ -z "$tools_choices" ]; then
  echo -e "${YELLOW}No tools selected for installation. Continuing...${RESET}" && sleep 1
fi

# Process the selected tools
for app in $tools_choices; do
  case $app in
  1) install_package "visual-studio-code-bin" "Visual Studio Code" "paru -S --noconfirm --needed" ;;
  2) install_package "github-desktop-bin" "GitHub Desktop" "paru -S --noconfirm --needed" ;;
  3)
    install_multiple_packages "docker" "docker-compose"
    sudo systemctl enable --now docker.service
    sudo usermod -aG docker "$USER"
    ;;
  4) install_package "docker-desktop" "Docker Desktop" "paru -S --noconfirm --needed" ;;
  5)
    install_package "kind-bin" "Kubernetes (kind-bin)" "paru -S --noconfirm --needed"
    if ! is_installed "kubectl"; then
      echo -e "${YELLOW}Installing kubectl...${RESET}"
      curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
      sudo install -m 0755 kubectl /usr/local/bin/kubectl
      rm kubectl
    else
      echo -e "${GREEN}kubectl is already installed.${RESET}"
    fi
    ;;
  6) install_multiple_packages "texlive-bin" "texlive-meta" "texlive-latex" "tex-fmt-bin" "perl-yaml-tiny" \
                               "perl-file-homedir" "perl-unicode-linebreak" ;;
  7) install_package "discord" "Discord" "sudo pacman -S --noconfirm" ;;
  8) install_package "obsidian" "Obsidian" "sudo pacman -S --noconfirm" ;;
  9) install_package "telegram-desktop-bin" "Telegram" "paru -S --noconfirm --needed" ;;
  10) install_package "libreoffice-fresh" "LibreOffice" "sudo pacman -S --noconfirm" ;;
  11) install_package "onlyoffice-bin" "OnlyOffice" "paru -S --noconfirm --needed" ;;
  12) install_package "skypeforlinux-bin" "Skype" "paru -S --noconfirm --needed" ;;
  13) install_package "slack-desktop" "Slack" "paru -S --noconfirm --needed" ;;
  14) install_package "zoom" "Zoom" "paru -S --noconfirm --needed" ;;
  15) install_package "blender" "Blender" "sudo pacman -S --noconfirm" ;;
  16) install_package "octave" "Octave" "sudo pacman -S --noconfirm" ;;
  17)
    install_package "obs-studio" "OBS Studio" "sudo pacman -S --noconfirm"
    install_package "wlrobs-hg" "OBS Studio Wayland Support" "paru -S --noconfirm --needed"
    ;;
  18) install_package "inkscape" "Inkscape" "sudo pacman -S --noconfirm" ;;
  19) install_package "gimp" "GIMP" "sudo pacman -S --noconfirm" ;;
  20) install_package "vlc" "VLC" "sudo pacman -S --noconfirm" ;;
  21) install_package "audacity" "Audacity" "sudo pacman -S --noconfirm" ;;
  22) install_package "krita" "Krita" "sudo pacman -S --noconfirm" ;;
  23) install_package "shotcut" "Shotcut" "sudo pacman -S --noconfirm" ;;
  24) install_package "steam" "Steam" "paru -S --noconfirm --needed" ;;
  25) install_package "minecraft-launcher" "Minecraft" "paru -S --noconfirm --needed" ;;
  26) cargo install youtui ;;
  27) cargo install ytermusic ;;
  28) install_multiple_packages "todoist-bin" "peco" ;;
  29) install_package "geary" "Geary" "sudo pacman -S --noconfirm" ;;
  30) install_package "keepassxc" "KeepassXC" "sudo pacman -S --noconfirm" ;;
  *) echo -e "${RED}Invalid choice: $app${RESET}" ;;
  esac
  echo -e "${CYAN}Processing completed for the selected tool(s).${RESET}" && sleep 2
done
