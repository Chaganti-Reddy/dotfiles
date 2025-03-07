#!/bin/bash

# Define color codes for easy use
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'  # Reset to default color

echo -e "${CYAN}Setting up torrent and working applications...${RESET}" && sleep 1

# Function to check if a package is installed
is_installed() {
  pacman -Qi "$1" &>/dev/null
  return $?
}

# Display the list of available applications and ask for input
echo -e "${YELLOW}Choose the applications you want to install by entering the corresponding numbers, separated by spaces:${RESET}"
echo -e "1) torrent-cli (webtorrent-cli, webtorrent-mpv-hook, peerflix)"
echo -e "2) qBittorrent (Recommended)"
echo -e "3) Transmission"
echo -e "4) Remmina (Remote Desktop Client)"
echo -e "5) VNC Server"
echo -e "6) TeamViewer (Recommended)"
echo -e "7) AnyDesk (Remote Desktop)"
echo -e "8) xrdp (Remote Desktop Protocol)"
echo -e "9) OpenVPN (VPN)"
echo -e "10) WireGuard (VPN)"
echo -e "11) Varia (Download Manager on ARIA2)"
echo -e "12) Warehouse (Flatpak App Manager)"
echo -e "13) Gromit-MPX (On Screen Drawing Tool)"
echo ""
echo -e "${CYAN}Enter your choices (e.g., 1 2 4), or press Enter to skip:${RESET}"

# Read user input
read -r apps
apps=${apps:-} # Default to empty if no input is provided

if [ -z "$apps" ]; then
  echo -e "${GREEN}No applications selected. Continuing without this installation.${RESET}" && sleep 2
  clear
fi

# Process selected applications and install them
for app in $apps; do
  case $app in
  1)
    if is_installed "webtorrent-cli" && is_installed "webtorrent-mpv-hook" && is_installed "peerflix"; then
      echo -e "${MAGENTA}torrent-cli is already installed.${RESET}"
    else
      echo -e "${CYAN}Installing torrent-cli (webtorrent-cli, webtorrent-mpv-hook, peerflix)...${RESET}"
      paru -S --noconfirm --needed webtorrent-cli webtorrent-mpv-hook peerflix
    fi
    ;;
  2)
    if is_installed "qbittorrent"; then
      echo -e "${MAGENTA}qBittorrent is already installed.${RESET}"
    else
      echo -e "${CYAN}Installing qBittorrent...${RESET}"
      sudo pacman -S --noconfirm qbittorrent
    fi
    ;;
  3)
    if is_installed "transmission-qt"; then
      echo -e "${MAGENTA}Transmission is already installed.${RESET}"
    else
      echo -e "${CYAN}Installing Transmission...${RESET}"
      sudo pacman -S --noconfirm transmission-qt
    fi
    ;;
  4)
    if is_installed "remmina"; then
      echo -e "${MAGENTA}Remmina (Remote Desktop Client) is already installed.${RESET}"
    else
      echo -e "${CYAN}Installing Remmina (Remote Desktop Client)...${RESET}"
      sudo pacman -S --noconfirm remmina
    fi
    ;;
  5)
    if is_installed "tigervnc"; then
      echo -e "${MAGENTA}VNC Server is already installed.${RESET}"
    else
      echo -e "${CYAN}Installing VNC Server...${RESET}"
      sudo pacman -S --noconfirm tigervnc
    fi
    ;;
  6)
    if is_installed "teamviewer"; then
      echo -e "${MAGENTA}TeamViewer is already installed.${RESET}"
    else
      echo -e "${CYAN}Installing TeamViewer...${RESET}"
      sudo pacman -S --noconfirm teamviewer
    fi
    ;;
  7)
    if is_installed "anydesk"; then
      echo -e "${MAGENTA}AnyDesk is already installed.${RESET}"
    else
      echo -e "${CYAN}Installing AnyDesk...${RESET}"
      sudo pacman -S --noconfirm anydesk
    fi
    ;;
  8)
    if is_installed "xrdp"; then
      echo -e "${MAGENTA}xrdp (Remote Desktop Protocol) is already installed.${RESET}"
    else
      echo -e "${CYAN}Installing xrdp (Remote Desktop Protocol)...${RESET}"
      sudo pacman -S --noconfirm xrdp
    fi
    ;;
  9)
    if is_installed "openvpn"; then
      echo -e "${MAGENTA}OpenVPN is already installed.${RESET}"
    else
      echo -e "${CYAN}Installing OpenVPN...${RESET}"
      sudo pacman -S --noconfirm openvpn
    fi
    ;;
  10)
    if is_installed "wireguard-tools"; then
      echo -e "${MAGENTA}WireGuard is already installed.${RESET}"
    else
      echo -e "${CYAN}Installing WireGuard...${RESET}"
      sudo pacman -S --noconfirm wireguard-tools
    fi
    ;;
  11)
    echo -e "${CYAN}Installing varia...${RESET}"
    flatpak install flathub io.github.giantpinkrobots.varia
    ;;
  12)
    echo -e "${CYAN}Installing warehouse...${RESET}"
    flatpak install flathub io.github.flattool.Warehouse
    ;;
  13)
    if is_installed "gromit-mpx"; then
      echo -e "${MAGENTA}Gromit-MPX is already installed.${RESET}"
    else
      echo -e "${CYAN}Installing Gromit-MPX...${RESET}"
      paru -S --noconfirm --needed gromit-mpx
    fi 
    ;;
  *)
    echo -e "${RED}Invalid choice: $app${RESET}"
    ;;
  esac
  echo -e "${GREEN}Selected applications have been installed.${RESET}" && sleep 2
done
