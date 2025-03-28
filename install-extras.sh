#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

echo -e "${CYAN}Setting Extra Packages for System...${RESET}" && sleep 1

# Install the bash language server globally using npm
if ! command -v bash-language-server &>/dev/null; then
  echo -e "${YELLOW}Installing bash-language-server...${RESET}"
  sudo npm i -g bash-language-server
else
  echo -e "${GREEN}bash-language-server is already installed.${RESET}"
fi

# Ask the user if they want to install themes and icons
read -p "Would you like to install themes and icons? (y/n): " install_themes_icons
install_themes_icons="${install_themes_icons:-y}" # Default to "y" if no input is provided

if [[ "$install_themes_icons" == "y" || "$install_themes_icons" == "Y" ]]; then
  echo -e "${CYAN}Installing Themes and Icons...${RESET}"
  cd ~/Downloads/ || return
  curl -L -o archcraft-themes.zip https://gitlab.com/chaganti-reddy1/archcraft-themes/-/archive/main/archcraft-themes-main.zip
  unzip archcraft-themes.zip
  rm archcraft-themes.zip
  mkdir -p ~/.icons ~/.themes
  cd archcraft-themes-main || return
  mv themes/* ~/.themes
  mv icons/* ~/.icons
  cd ~/Downloads || return
  rm -rf archcraft-themes-main
  cd ~/dotfiles/ || return

  # Copy Dunst icons
  sudo cp -r ~/dotfiles/Extras/Extras/dunst/ /usr/share/icons/

  # Override Flatpak GTK Themes and Icons
  sudo flatpak override --filesystem=$HOME/.themes
  sudo flatpak override --filesystem=$HOME/.icons
  sudo flatpak override --env=GTK_THEME=Kripton
  sudo flatpak override --env=ICON_THEME=Luv-Folders-Dark

  echo -e "${GREEN}Themes and Icons have been installed successfully...${RESET}" && sleep 2
else
  echo -e "${YELLOW}Themes and Icons installation skipped.${RESET}" && sleep 1
fi

# Ask the user if they want to install extra configurations
read -p "Would you like to install my configs? (y/n): " install_extras
install_extras="${install_extras:-y}" # Default to "y" if no input is provided

if [[ "$install_extras" == "y" || "$install_extras" == "Y" ]]; then
  echo -e "${CYAN}Extras installation will begin now...${RESET}"

  # Remove existing bashrc and zshrc files
  echo -e "${YELLOW}Removing existing bashrc...${RESET}"
  rm -rf ~/.bashrc
  cd ~/dotfiles/ || return

  # Check if the username is "karna"
  if [ "$(whoami)" != "karna" ]; then
    # Install for non-karna users
    echo -e "${CYAN}Stowing configurations for ${USER} user...${RESET}"
    stow bashrc BTOP dunst neofetch flameshot gtk-2 gtk-3 Kvantum mpd mpv ncmpcpp newsboat NWG pandoc pavucontrol qt6ct qutebrowser ranger redyt screensaver sxiv Templates themes Thunar xsettingsd zathura

    # Ask user to confirm stowing nvim_gen
    read -p "Would you like to stow nvim_gen? (y/n): " stow_nvim_gen
    stow_nvim_gen="${stow_nvim_gen:-y}" # Default to "y" if no input is provided

    if [[ "$stow_nvim_gen" == "y" || "$stow_nvim_gen" == "Y" ]]; then
      stow nvim_gen
    fi 

    # Copy essential system files for non-karna users
    sudo cp ~/dotfiles/Extras/Extras/etc/nanorc /etc/nanorc
    sudo cp ~/dotfiles/Extras/Extras/etc/bash.bashrc /etc/bash.bashrc
    sudo cp ~/dotfiles/Extras/Extras/etc/DIR_COLORS /etc/DIR_COLORS
    sudo cp ~/dotfiles/Extras/Extras/etc/environment /etc/environment
    sudo cp ~/dotfiles/Extras/Extras/kunst /usr/bin/kusnt
    sudo cp ~/dotfiles/Extras/Extras/nvim.desktop /usr/share/applications/nvim.desktop

    echo -e "${GREEN}Extras have been installed.${RESET}" && sleep 1
  else
    # Install for "karna" user
    echo -e "${CYAN}Stowing configurations for Karna...${RESET}"
    # sudo pacman -S zellij
    stow bash_karna BTOP_karna cava dunst face_karna neofetch flameshot gtk-2 gtk-3_karna Kvantum latexmkrc libreoffice mpd_karna mpv_karna myemojis ncmpcpp_karna newsboat_karna nvim NWG octave pandoc pavucontrol qt6ct qutebrowser ranger_karna redyt screenlayout screensaver sxiv Templates Thunar xarchiver xsettingsd zathura kitty enchant

    # Copy essential system files for karna user
    sudo cp ~/dotfiles/Extras/Extras/etc/nanorc /etc/nanorc
    sudo cp ~/dotfiles/Extras/Extras/etc/bash.bashrc /etc/bash.bashrc
    sudo cp ~/dotfiles/Extras/Extras/etc/DIR_COLORS /etc/DIR_COLORS
    sudo cp ~/dotfiles/Extras/Extras/etc/environment /etc/environment
    sudo cp ~/dotfiles/Extras/Extras/etc/mpd.conf /etc/mpd.conf
    sudo cp ~/dotfiles/Extras/Extras/nvim.desktop /usr/share/applications/nvim.desktop

    # Install custom tools for karna
    sudo rm /usr/bin/kunst && curl -L git.io/raw-kunst > kunst && chmod +x kunst && sudo mv kunst /usr/bin

    cargo install leetcode-cli

    sudo npm install -g @mermaid-js/mermaid-cli
    go install github.com/maaslalani/typer@latest
    cp ~/dotfiles/Extras/Extras/.wakatime.cfg.cpt ~/
    echo "decrypting you wakatime API key ..."
    sleep 1
    ccrypt -d ~/.wakatime.cfg.cpt

    echo -e "${YELLOW}Setup kaggle JSON and wakatime files using ccrypt... also read essential_info.md file.${RESET}" && sleep 1
    echo -e "${GREEN}Extras have been installed for KARNA.${RESET}" && sleep 1
  fi
else
  echo -e "${YELLOW}Extras installation skipped. Proceeding with the setup.${RESET}" && sleep 1
fi
