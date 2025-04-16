#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'

echo -e "${CYAN}Setting up additional tools and packages...${RESET}" && sleep 1

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

# Display the list of extra tools
echo -e "${BLUE}Choose the tools you want to install by entering the corresponding numbers, separated by spaces:${RESET}"
cat << EOF
1) Ani-Cli                    2) Ani-Cli-PY
3) ytfzf                      4) Zathura
5) Evince                     6) Okular
7) Foxit-Reader               8) Master-PDF-Editor
9) MuPDF
EOF

echo -e "${CYAN}Enter your choices (e.g., 1 2 4), or press Enter to skip:${RESET}"
read -r extra_tools_choices
extra_tools_choices=${extra_tools_choices:-} # Default to empty if no input is provided

if [ -z "$extra_tools_choices" ]; then
  echo -e "${YELLOW}No packages selected. Continuing without installation...${RESET}" && sleep 1
fi

# Process the selected tools
for app in $extra_tools_choices; do
  case $app in
  1)
    install_package "ani-cli-git" "Ani-Cli" "paru -S --noconfirm --needed"
    ;;
  2)
    install_package "ani-cli-git" "Ani-Cli Python" "paru -S --noconfirm --needed"
    pipx install anipy-cli
    cd ~/dotfiles/ || return
    stow anipy-cli
    ;;
  3)
    install_package "ytfzf-git" "YTFZF" "paru -S --noconfirm --needed"
    # Stow configuration based on username
    stow_folder="ytfzf"
    [ "$(whoami)" == "karna" ] && stow_folder="ytfzf_karna"
    cd ~/dotfiles || return
    stow "$stow_folder"
    ;;
  4)
    install_package "zathura" "Zathura" "sudo pacman -S --noconfirm"
    install_package "zathura-pdf-mupdf" "Zathura PDF Backend" "sudo pacman -S --noconfirm"
    install_package "zathura-djvu" "Zathura DJVU Backend" "sudo pacman -S --noconfirm"
    install_package "zathura-ps" "Zathura PS Backend" "sudo pacman -S --noconfirm"
    install_package "zathura-cb" "Zathura Comic Backend" "sudo pacman -S --noconfirm"
    cd ~/dotfiles/Extras/Extras/Zathura-Pywal-master/ || return
    ./install.sh
    cd ~/dotfiles/ || return
    ;;
  5)
    install_package "evince" "Evince" "sudo pacman -S --noconfirm"
    ;;
  6)
    install_package "okular" "Okular" "sudo pacman -S --noconfirm"
    ;;
  7)
    install_package "foxitreader" "Foxit Reader" "paru -S --noconfirm --needed"
    ;;
  8)
    install_package "masterpdfeditor" "Master PDF Editor" "paru -S --noconfirm --needed"
    ;;
  9)
    install_package "mupdf" "MuPDF" "sudo pacman -S --noconfirm"
    ;;
  *)
    echo -e "${RED}Invalid choice: $app${RESET}"
    ;;
  esac
  echo -e "${CYAN}Processing for the selected extra tool(s) completed.${RESET}" && sleep 2
done
