#!/bin/env bash
# set -e


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
mkdir -p ~/Downloads ~/Documents ~/Music ~/Pictures ~/Videos ~/Templates
#
echo "Created Directories..." && sleep 1
#
clear
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

clear

# System update
echo "Performing a full system update..."
sudo pacman --noconfirm -Syu
clear
echo "System update done" && sleep 2
clear

# Install Git if not present
echo "Installing git..." && sleep 1
sudo pacman -S --noconfirm --needed git
clear

# Clone and install Paru if not installed
echo "This script requires an AUR helper to install the dependencies. Installing paru..." && sleep 2
if ! command -v paru &>/dev/null; then
  echo "Installing Paru, an AUR helper..."
  cd ~/Downloads || return
  git clone https://aur.archlinux.org/paru-bin.git
  cd paru-bin || return
  makepkg -si
  cd ..
  echo "Paru installed" && sleep 1
  rm -rf paru-bin
  cd ~/dotfiles || return
fi
clear

# --------------------------------------------------------------------------------------

# Install base-devel and required packages
echo "Installing dependencies.." && sleep 2

sudo pacman -S --noconfirm --needed base-devel intel-ucode vim zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting bash-completion openssh wget curl btop neofetch bat exa fd ripgrep fzf stow stylua tar tree time acpilight aria2 unrar unzip bluez bluez-utils brightnessctl xfsprogs ntfs-3g clang gcc clipmenu clipnotify inotify-tools psutils dunst e2fsprogs gvfs gvfs-afc gvfs-google gvfs-goa gvfs-gphoto2 gvfs-mtp gvfs-nfs gvfs-onedrive gvfs-smb efibootmgr zoxide gc git-lfs gnome-keyring polkit-kde-agent polkit-gnome pass udiskie gstreamer jq xdotool screenkey xorg-xprop xorg-xinit xf86-video-intel lazygit lolcat sxiv shellcheck net-tools numlockx prettier progress zip rsync trash-cli tlp tlp-rdw neovim xorg-xinput xclip xcompmgr xorg-xrandr xorg-xsetroot xsel xwallpaper pandoc starship python-pywal glow xarchiver xfce4-clipman-plugin libguestfs bc xorg-xman man-db man-pages ncdu python-adblock dnsmasq python-pip nwg-look python-prctl vscode-css-languageserver ffmpegthumbnailer lua-language-server pass pinentry gnupg pass-otp zbar xorg-xlsclients xscreensaver os-prober qt5ct pamixer qt5-wayland qt6-wayland parallel shfmt tesseract html-xml-utils tumbler thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman thunar-vcs-plugin flameshot playerctl ncmpcpp mpd mpv mpc poppler poppler-glib adobe-source-code-pro-fonts noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-hack ttf-jetbrains-mono ttf-ubuntu-font-family ttf-ubuntu-mono-nerd ttf-ubuntu-nerd ttf-opensans gnu-free-fonts libnewt baobab gnome-disk-utility gparted pavucontrol ranger yad timeshift go hugo hunspell hunspell-en_us imagemagick ueberzug luacheck yt-dlp mlocate nodejs npm translate-shell jdk-openjdk openjdk-doc openjdk-src blueman zenity rofi-wayland rofi-emoji newsboat fcitx5 fcitx5-configtool papirus-icon-theme acpi powertop dart-sass speedtest-cli lynx atool lf figlet luarocks kitty network-manager-applet navi glfw pulsemixer alsa-firmware sof-firmware alsa-ucm-conf viewnior qalculate-gtk pyright

paru -S --noconfirm --needed base-devel python-psutil preload git-remote-gcrypt ttf-ms-fonts qt6ct-kde ccrypt didyoumean-git arch-wiki-docs kvantum kvantum-theme-catppuccin-git catppuccin-fcitx5-git apple_cursor cava sysstat pyprland-git --noconfirm

echo "Dependencies installed... executing services & permissions..." && sleep 1

clear

sudo updatedb
sudo mandb
sudo systemctl enable --now tlp
sudo systemctl enable --now bluetooth.service

sudo usermod -aG video "$USER"

# paru -S material-black-colors-theme apple_cursor kvantum-theme-materia kvantum --noconfirm

echo "Done with permissions..." && sleep 2

clear

# --------------------------------------------------------------------------------------

echo "Setting up Git configuration..."

# Ask user whether to proceed with Git setup
echo "Do you want to proceed with setting up Git configuration? (y/n) [default: y]"
read -r response
response=${response:-y} # Default to 'y' if the user presses Enter without input
if [[ ! "$response" =~ ^[Yy]$ ]]; then
  # User pressed "No", skip Git setup
  echo "Git setup skipped. Proceeding with the next module."
  clear
else
  # Proceed with Git configuration if user clicked "Yes"

  # Prompt for Git username
  echo "Enter your Git username:"
  read -r git_username
  if [ -z "$git_username" ]; then
    echo "Git username setup canceled or empty. Skipping Git configuration." && sleep 1
  else
    # Prompt for Git email
    echo "Enter your Git email:"
    read -r git_email
    if [ -z "$git_email" ]; then
      echo "Git email setup canceled or empty. Skipping Git configuration." && sleep 1
    else
      # Confirm Git configuration
      echo "Please confirm the Git configuration:"
      echo "Username: $git_username"
      echo "Email: $git_email"
      echo "Do you want to proceed with this configuration? (y/n) [default: y]"
      read -r confirm
      confirm=${confirm:-y} # Default to 'y' if the user presses Enter without input
      if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Git configuration canceled. No changes were made." && sleep 1
      else
        # Set Git configuration if confirmed
        git config --global user.name "$git_username"
        git config --global user.email "$git_email"
        echo "Git has been successfully configured." && sleep 2
      fi
    fi
  fi
fi

clear

# -------------------------------------------------------------------------------------
#
echo "Setting up Miniconda..." && sleep 1

# Ask the user if they want to install Miniconda
echo "Would you like to install Miniconda? (y/n) [default: y]"
read -r response
response=${response:-y} # Default to 'y' if the user presses Enter without input
if [[ ! "$response" =~ ^[Yy]$ ]]; then
  echo "Miniconda installation skipped. Proceeding with the setup."
  clear
else
  echo "Miniconda installation will begin now."

  # Download Miniconda installer
  wget https://repo.anaconda.com/miniconda/Miniconda3-py310_24.3.0-0-Linux-x86_64.sh

  # Run the installer
  bash Miniconda3-py310_24.3.0-0-Linux-x86_64.sh
  conda init
  # Remove the installer after installation
  rm Miniconda3-py310_24.3.0-0-Linux-x86_64.sh

  clear

  echo "Miniconda installation completed." && sleep 2
fi

#
# # -------------------------------------------------------------------------------------
#
echo "Setting up KVM..." && sleep 1

# Ask the user if they want to install KVM QEMU
echo "Would you like to install KVM QEMU Virtual Machine? (y/n) [default: y]"
read -r response
response=${response:-y} # Default to 'y' if the user presses Enter without input

if [[ ! "$response" =~ ^[Yy]$ ]]; then
  echo "KVM installation skipped. Proceeding with the setup."
  clear
else
  echo "KVM installation will begin now."

  # Install necessary packages for KVM
  sudo pacman -S qemu-full qemu-img libvirt virt-install virt-manager virt-viewer spice-vdagent edk2-ovmf dnsmasq swtpm guestfs-tools libosinfo tuned

  # Enable and start the libvirt service
  sudo systemctl enable --now libvirtd.service

  # Add user to libvirt group
  sudo usermod -aG libvirt "$USER"

  # Autostart libvirt network
  sudo virsh net-autostart default

  # Enable KVM with nested virtualization
  sudo modprobe -r kvm_intel
  sudo modprobe kvm_intel nested=1

  echo "KVM installation completed." && sleep 2
  clear
  echo "For VM sharing details visit: https://docs.getutm.app/guest-support/linux/" && sleep 1
fi

# -------------------------------------------------------------------------------------

echo "Installing Browsers that I personally use the most..." && sleep 1

# Function to display the browser selection menu using echo
install_browser() {
  echo "Select the browsers you want to install (you can select multiple by entering numbers separated by spaces):"
  echo "1) Zen-Browser"
  echo "2) Firefox"
  echo "3) Chromium"
  echo "4) Vivaldi"
  echo "5) qutebrowser"
  echo "6) Brave"
  echo ""
  echo "Enter the numbers corresponding to your choices (e.g., 1 3 5), or press Enter to skip:"

  # Read user input (browser choices)
  read -r choices
  choices=${choices:-} # Default to empty if no input is provided

  if [ -z "$choices" ]; then
    echo "No Browsers are installing today...going on..."
    clear
  fi

  # Process the selected options
  for choice in $choices; do
    case $choice in
    1)
      echo "Installing Zen-Browser..."
      paru -S --noconfirm --needed zen-browser-bin
      sudo npm install -g nativefier
      # Video Download Helper
      curl -sSLf https://github.com/aclap-dev/vdhcoapp/releases/latest/download/install.sh | bash
      ;;
    2)
      echo "Installing Firefox..."
      sudo pacman -S --noconfirm firefox
      curl -sSLf https://github.com/aclap-dev/vdhcoapp/releases/latest/download/install.sh | bash
      ;;
    3)
      echo "Installing Chromium..."
      sudo pacman -S --noconfirm chromium
      ;;
    4)
      echo "Installing Vivaldi..."
      paru -S --noconfirm vivaldi
      ;;
    5)
      echo "Installing qutebrowser..."
      sudo pacman -S --noconfirm qutebrowser
      ;;
    6)
      echo "Installing Brave..."
      paru -S --noconfirm brave-bin
      ;;
    *)
      echo "Invalid choice: $choice"
      ;;
    esac
    echo "Selected browsers have been installed." && sleep 2
    clear
  done
}

# Call the browser installation function
install_browser

# -------------------------------------------------------------------------------------

echo "Setting up torrent and remote working applications..."

# Display the list of available applications and ask for input
echo "Choose the applications you want to install by entering the corresponding numbers, separated by spaces:"
echo "1) torrent-cli (webtorrent-cli, webtorrent-mpv-hook, peerflix)"
echo "2) qBittorrent (Recommended)"
echo "3) Transmission"
echo "4) Remmina (Remote Desktop Client)"
echo "5) VNC Server"
echo "6) TeamViewer (Recommended)"
echo "7) AnyDesk (Remote Desktop)"
echo "8) xrdp (Remote Desktop Protocol)"
echo "9) OpenVPN (VPN)"
echo "10) WireGuard (VPN)"
echo ""
echo "Enter your choices (e.g., 1 2 4), or press Enter to skip:"

# Read user input
read -r apps
apps=${apps:-} # Default to empty if no input is provided

if [ -z "$apps" ]; then
  echo "No applications selected. Continuing without this installation"
  clear
fi

# Process selected applications and install them
for app in $apps; do
  case $app in
  1)
    echo "Installing torrent-cli (webtorrent-cli, webtorrent-mpv-hook, peerflix)..."
    paru -S --noconfirm --needed webtorrent-cli webtorrent-mpv-hook peerflix
    ;;
  2)
    echo "Installing qBittorrent..."
    sudo pacman -S --noconfirm qbittorrent
    ;;
  3)
    echo "Installing Transmission..."
    sudo pacman -S --noconfirm transmission-qt
    ;;
  4)
    echo "Installing Remmina (Remote Desktop Client)..."
    sudo pacman -S --noconfirm remmina
    ;;
  5)
    echo "Installing VNC Server..."
    sudo pacman -S --noconfirm tigervnc
    ;;
  6)
    echo "Installing TeamViewer..."
    sudo pacman -S --noconfirm teamviewer
    ;;
  7)
    echo "Installing AnyDesk..."
    sudo pacman -S --noconfirm anydesk
    ;;
  8)
    echo "Installing xrdp (Remote Desktop Protocol)..."
    sudo pacman -S --noconfirm xrdp
    ;;
  9)
    echo "Installing OpenVPN..."
    sudo pacman -S --noconfirm openvpn
    ;;
  10)
    echo "Installing WireGuard..."
    sudo pacman -S --noconfirm wireguard-tools
    ;;
  *)
    echo "Invalid choice: $app"
    ;;
  esac
  echo "Selected applications have been installed." && sleep 2
  clear
done

# -------------------------------------------------------------------------------------
#
echo "Setting up development tools, office tools, communication tools, and multimedia tools..."

# Display the list of available tools in two columns
echo "Choose the tools you want to install by entering the corresponding numbers, separated by spaces:"
echo ""
echo "1) Visual-Studio-Code        2) GitHub-Desktop"
echo "3) Docker                    4) Docker-Desktop"
echo "5) Kubernetes                6) Latex"
echo "7) Discord                   8) Obsidian"
echo "9) Telegram                  10) LibreOffice"
echo "11) OnlyOffice               12) Skype"
echo "13) Slack                    14) Zoom"
echo "15) Blender                  16) Octave"
echo "17) OBS-Studio               18) Inkscape"
echo "19) GIMP                     20) VLC"
echo "21) Audacity                 22) Krita"
echo "23) Shotcut                  24) Steam"
echo "25) Minecraft                26) YouTUI"
echo "27) YTerMusic                28) Todoist"
echo "29) Geary                    30) KeepassXC"
echo ""
echo "Enter your choices (e.g., 1 2 4), or press Enter to skip:"

# Read user input
read -r tools_choices
tools_choices=${tools_choices:-} # Default to empty if no input is provided

if [ -z "$tools_choices" ]; then
  echo "No tools selected for installation. Continuing..."
  clear
fi

# Process selected tools and install them
for app in $tools_choices; do
  case $app in
  1)
    echo "Installing Visual Studio Code..."
    paru -S --noconfirm --needed visual-studio-code-bin
    ;;
  2)
    echo "Installing GitHub Desktop..."
    paru -S --noconfirm --needed github-desktop-bin
    ;;
  3)
    echo "Installing Docker..."
    sudo pacman -S --noconfirm docker docker-compose
    sudo systemctl enable --now docker.service
    sudo usermod -aG docker "$USER"
    ;;
  4)
    echo "Installing Docker Desktop..."
    paru -S --noconfirm docker-desktop
    ;;
  5)
    echo "Installing Kubernetes..."
    paru -S --noconfirm kind-bin
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    ;;
  6)
    echo "Installing LaTeX (texlive)..."
    sudo pacman -S --noconfirm texlive-bin texlive-meta texlive-latex texlive-basic texlive-binextra perl-yaml-tiny perl-file-homedir perl-unicode-linebreak
    ;;
  7)
    echo "Installing Discord..."
    sudo pacman -S --noconfirm discord
    ;;
  8)
    echo "Installing Obsidian..."
    sudo pacman -S --noconfirm obsidian
    ;;
  9)
    echo "Installing Telegram..."
    paru -S --noconfirm telegram-desktop-bin
    ;;
  10)
    echo "Installing LibreOffice..."
    sudo pacman -S --noconfirm libreoffice-fresh
    ;;
  11)
    echo "Installing OnlyOffice..."
    paru -S --noconfirm onlyoffice-bin
    ;;
  12)
    echo "Installing Skype..."
    paru -S --noconfirm skypeforlinux-bin
    ;;
  13)
    echo "Installing Slack..."
    paru -S --noconfirm slack-desktop
    ;;
  14)
    echo "Installing Zoom..."
    paru -S --noconfirm zoom
    ;;
  15)
    echo "Installing Blender..."
    sudo pacman -S --noconfirm blender
    ;;
  16)
    echo "Installing Octave..."
    sudo pacman -S --noconfirm octave
    ;;
  17)
    echo "Installing OBS Studio..."
    sudo pacman -S --noconfirm obs-studio
    paru -S --needed --noconfirm wlrobs-hg
    ;;
  18)
    echo "Installing Inkscape..."
    sudo pacman -S --noconfirm inkscape
    ;;
  19)
    echo "Installing GIMP..."
    sudo pacman -S --noconfirm gimp
    ;;
  20)
    echo "Installing VLC..."
    sudo pacman -S --noconfirm vlc
    ;;
  21)
    echo "Installing Audacity..."
    sudo pacman -S --noconfirm audacity
    ;;
  22)
    echo "Installing Krita..."
    sudo pacman -S --noconfirm krita
    ;;
  23)
    echo "Installing Shotcut..."
    sudo pacman -S --noconfirm shotcut
    ;;
  24)
    echo "Installing Steam..."
    paru -S --noconfirm steam
    ;;
  25)
    echo "Installing Minecraft..."
    paru -S --noconfirm minecraft-launcher
    ;;
  26)
    echo "Installing YouTUI..."
    cargo install youtui
    ;;
  27)
    echo "Installing YTerMusic..."
    cargo install ytermusic
    ;;
  28)
    echo "Installing Todoist CLI..."
    paru -S todoist-bin peco
    ;;
  29)
    echo "Installing Geary..."
    sudo pacman -S --noconfirm geary
    ;;
  30)
    echo "Installing KeepassXC..."
    sudo pacman -S --noconfirm keepassxc
    ;;
  *)
    echo "Invalid choice: $app"
    ;;
  esac
  echo "Selected tools have been installed." && sleep 2
  clear
done
#
# -------------------------------------------------------------------------------------

echo "Setting up additional tools and packages..."

# Display the list of available extra tools in two columns
echo "Choose the tools you want to install by entering the corresponding numbers, separated by spaces:"
echo ""
echo "1) Ani-Cli                    2) Ani-Cli-PY"
echo "3) ytfzf                      4) Zathura"
echo "5) Evince                     6) Okular"
echo "7) Foxit-Reader               8) Master-PDF-Editor"
echo "9) MuPDF"
echo ""
echo "Enter your choices (e.g., 1 2 4), or press Enter to skip:"

# Read user input
read -r extra_tools_choices
extra_tools_choices=${extra_tools_choices:-} # Default to empty if no input is provided

if [ -z "$extra_tools_choices" ]; then
  echo "No packages selected. Continuing without installation..."
  clear
fi

# Process selected tools and install them
for app in $extra_tools_choices; do
  case $app in
  1)
    echo "Installing ani-cli..."
    paru -S --noconfirm --needed ani-cli-git
    ;;
  2)
    echo "Installing ani-cli python version..."
    pip install anipy-cli
    cd ~/dotfiles/ || return
    stow anipy-cli
    ;;
  3)
    echo "Installing ytfzf..."
    paru -S --noconfirm --needed ytfzf-git
    # Stow configuration based on username
    if [ "$(whoami)" == "karna" ]; then
      stow_folder="ytfzf_karna"
    else
      stow_folder="ytfzf"
    fi
    # Apply the stow configuration
    cd ~/dotfiles || return
    stow "$stow_folder"
    ;;
  4)
    echo "Installing Zathura..."
    sudo pacman -S zathura zathura-pdf-mupdf zathura-djvu zathura-ps zathura-cb --noconfirm
    cd ~/dotfiles/Extras/Extras/Zathura-Pywal-master/ || return
    ./install.sh
    cd ~/dotfiles/ || return
    ;;
  5)
    echo "Installing Evince..."
    sudo pacman -S --noconfirm evince
    ;;
  6)
    echo "Installing Okular..."
    sudo pacman -S --noconfirm okular
    ;;
  7)
    echo "Installing Foxit Reader..."
    paru -S --noconfirm foxitreader
    ;;
  8)
    echo "Installing Master PDF Editor..."
    paru -S --noconfirm masterpdfeditor
    ;;
  9)
    echo "Installing MuPDF..."
    sudo pacman -S --noconfirm mupdf
    ;;
  *)
    echo "Invalid choice: $app"
    ;;
  esac
  echo "Selected extra tools and packages have been installed." && sleep 2
  clear
done

# -------------------------------------------------------------------------------------

echo "Setting up MariaDB..."

# Ask the user if they want to install MariaDB
echo "Would you like to install MariaDB (a relational database management system)? (yes/no)"
read -r mariadb_installation

if [[ "$mariadb_installation" != "yes" && "$mariadb_installation" != "y" ]]; then
  clear
  echo "MariaDB installation skipped. Proceeding with the setup."
  clear
else
  echo "MariaDB installation will begin now."

  sudo pacman -S mariadb --noconfirm
  sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
  sudo systemctl enable --now mariadb
  sudo mariadb-secure-installation

  # Inform the user that MariaDB has been installed and configured
  echo "MariaDB has been installed and secured. You can now use it for your database needs." && sleep 2
  clear
fi

# -------------------------------------------------------------------------------------

echo "Setting up Fonts..." && sleep 1

mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts || return

curl -L -o my-fonts.zip https://github.com/Chaganti-Reddy/my-fonts/archive/main.zip

unzip my-fonts.zip

rm my-fonts.zip

cd ~/dotfiles/ || return

clear

echo "Fonts have been installed successfully..." && sleep 2

# --------------------------------------------------------------------------------------

echo "Setting up Hyprland..." && sleep 1

# Ask the user if they want to install Hyprland
echo "Would you like to install Hyprland (a dynamic Wayland compositor)? (y/n)"
read -r install_hyprland

if [[ "$install_hyprland" == "y" || "$install_hyprland" == "Y" ]]; then
  echo "Hyprland installation will begin now."

  # Install Hyprland and related packages
  sudo pacman -S --noconfirm kitty system-config-printer chafa hypridle waybar wl-clipboard speech-dispatcher foot brightnessctl cmake meson cpio grim slurp wtype wf-recorder wofi

  paru -S hyprland-git hyprlock-git xdg-desktop-portal-hyprland-git clipse-bin hyde-cli-git wlogout-git hyprshot-git hyprland-qtutils-git bluetui hyprpicker-git hyprpaper-git pyprland-git

  # Set up Hyprland configuration
  echo "Configuring Hyprland..."

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
    echo "Hyprland configuration ($stow_folder) has been set up."
  else
    echo "Hyprland configuration file already exists."
  fi
  cd ~/dotfiles/Extras/Extras/waldl-master/ && sudo make install && cd ~/dotfiles || return
  clear
  echo "Setup is complete. Proceeding to next modules..." && sleep 2
else
  echo "Hyprland installation skipped. Proceeding with the setup."
  clear
fi

# -------------------------------------------------------------------------------------

echo "Setting up dwm..."

# Ask the user if they want to install dwm
echo "Would you like to install dwm (Dynamic Window Manager)? (y/n)"
read -r install_dwm

if [[ "$install_dwm" == "y" || "$install_dwm" == "Y" ]]; then
  echo "dwm installation will begin now."

  # Install dwm and related packages
  cd ~/dotfiles || return
  stow suckless/
  stow DWMScripts

  cd ~/.config/dwm && sudo make clean install
  cd ~/.config/slstatus && sudo make clean install
  cd ~/.config/st && sudo make install
  cd ~/.config/dmenu && sudo make install
  cd ~/dotfiles/Extras/Extras/waldl-master/ && sudo make install && cd ~/dotfiles || return

  sudo mkdir -p /usr/share/xsessions/
  sudo cp ~/dotfiles/Extras/Extras/usr/share/xsessions/dwm.desktop /usr/share/xsessions

  echo "dwm has been installed. Please configure your system as needed." && sleep 2

  clear
else
  echo "dwm installation skipped. Proceeding with the setup."
  clear
fi

# --------------------------------------------------------------------------------------

echo "Setting up BSPWM..."

# Ask the user if they want to install bspwm
echo "Would you like to install bspwm? (y/n)"
read -r install_bspwm 

if [[ "$install_bspwm" == "y" || "$install_bspwm" == "Y" ]]; then
  echo "bspwm installation will begin now."

  # Install bspwm and related packages
  sudo pacman -S --noconfirm bspwm sxhkd pastel alacritty polybar xfce4-power-manager xsettingsd xorg-xsetroot wmname xcolor yad pulsemixer maim feh

  paru -S --noconfirm ksuperkey betterlockscreen light networkmanager-dmenu-git

  # Setup configuration files
  cd ~/dotfiles || return
  stow feh
  stow bspwm/
  stow network-dmenu/

  cd ~/dotfiles/Extras/Extras/waldl-master/ && sudo make install && cd ~/dotfiles || return
  echo "bspwm has been installed. Please configure your system as needed." && sleep 2
  clear
else
  echo "bspwm installation skipped. Proceeding with the setup."
  clear
fi

# --------------------------------------------------------------------------------------

echo "Setting up Ollama..."

# Ask the user if they want to install Ollama
echo "Would you like to install Ollama (a tool to run large language models locally)? (y/n)"
read -r install_ollama

if [[ "$install_ollama" == "y" || "$install_ollama" == "Y" ]]; then
  echo "Ollama installation will begin now."

  # Check if Ollama is available through the AUR or if manual installation is needed
  # We will use AUR (Arch User Repository) to install it using an AUR helper like paru.

  # Install Ollama using paru (or an AUR helper of your choice)
  if ! command -v ollama &>/dev/null; then
    echo "Ollama not found, installing Ollama from AUR..."

    # Install Ollama from the AUR using paru (if not already installed)
    # paru -S --noconfirm ollama
    curl -fsSL https://ollama.com/install.sh | sh

    echo "Ollama has been installed. You can now use it to run local large language models." && sleep 2

    clear

    echo "Now you will see a lot of txt but don't panic just put y or n for installing various model and model name is shown at the first line..." && sleep 10

    clear

    # Ask the user if they want to install models
    ollama serve &
    clear
    models=("mistral" "gemma:7b")
    for model in "${models[@]}"; do
      clear
      echo "Would you like to install the model '$model'? (y/n)"
      read -r install_model

      if [[ "$install_model" == "y" || "$install_model" == "Y" ]]; then
        echo "Installing model '$model'..."

        # pull the model
        ollama pull "$model"

        echo "Model '$model' has been installed." && sleep 1
      else
        echo "Model '$model' installation skipped." && sleep 1
      fi
    done
    clear
    echo "Ollama set completed. Proceeding..." && sleep 2
  else
    echo "Ollama is already installed on your system." && sleep 1
  fi
else
  echo "Ollama installation skipped. Proceeding with the setup."
  clear
fi
#
# --------------------------------------------------------------------------------------
#
echo "Installing PIP Packages..."

# Ask the user if they want to install the PIP packages
echo "Would you like to install my PIP Packages? (y/n)"
read -r install_pip_packages

if [[ "$install_pip_packages" == "y" || "$install_pip_packages" == "Y" ]]; then
  echo "PIP packages installation will begin now."

  # Install the PIP packages
  pip install pynvim numpy pandas matplotlib seaborn scikit-learn jupyterlab ipykernel ipywidgets tensorflow python-prctl inotify-simple psutil opencv-python keras mov-cli-youtube mov-cli mov-cli-test otaku-watcher film-central daemon jupyterlab_wakatime pygobject spotdl

  pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu # pytorch cpu version
  clear
  echo "PIP Packages have been installed. Please configure your system as needed." && sleep 2
else
  echo "PIP packages installation skipped. Proceeding with the setup."
  clear
fi

# --------------------------------------------------------------------------------------

echo "Setting up GRUB theme..."

# Ask if the user wants to set up a GRUB theme
echo "Would you like to install a GRUB theme? (y/n)"
read -r install_grub_theme

if [[ "$install_grub_theme" == "y" || "$install_grub_theme" == "Y" ]]; then
  echo "GRUB theme setup will begin now."

  # Copy the GRUB theme files
  sudo cp -r ~/dotfiles/Extras/Extras/boot/grub/themes/SekiroShadow/ /boot/grub/themes/

  # Enable the GRUB theme
  echo "Setting GRUB theme..."
  echo 'GRUB_THEME="/boot/grub/themes/SekiroShadow/theme.txt"' | sudo tee -a /etc/default/grub

  # Enable os-prober in GRUB configuration
  echo "Enabling os-prober in GRUB configuration..."
  echo 'GRUB_DISABLE_OS_PROBER="false"' | sudo tee -a /etc/default/grub

  # Regenerate GRUB configuration
  echo "Regenerating GRUB configuration..."
  sudo grub-mkconfig -o /boot/grub/grub.cfg
  echo "GRUB theme setup is complete, and GRUB config has been updated." && sleep 2
  clear
else
  echo "GRUB theme setup skipped. Proceeding with the setup."
  clear
fi

# --------------------------------------------------------------------------------------

echo "Setting up SDDM (Simple Desktop Display Manager)..."

# Install SDDM
echo "Installing SDDM..."
sudo pacman -S --noconfirm sddm qt6-5compat qt6-declarative qt6-svg

echo "Enabling SDDM to start at boot..."
sudo systemctl enable sddm.service

# Copy the SDDM theme files
sudo cp -r ~/dotfiles/Extras/Extras/usr/share/sddm/themes/simple-sddm/ /usr/share/sddm/themes

# Copy the SDDM configuration file
sudo cp ~/dotfiles/Extras/Extras/etc/sddm.conf /etc/sddm.conf
clear
echo "SDDM has been installed and enabled to start at boot." && sleep 1

# --------------------------------------------------------------------------------------

echo "Setting up Zsh..."

# Ask the user if they want to install and set up Zsh
echo "Would you like to install Zsh and set it as your default shell? (y/n)"
read -r install_zsh

if [[ "$install_zsh" == "y" || "$install_zsh" == "Y" ]]; then
  echo "Zsh installation will begin now."

  # Install Zsh if not already installed
  sudo pacman -S --noconfirm zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting

  # Change the default shell to Zsh
  chsh -s /bin/zsh

  # Install Oh My Zsh
  #   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sed '/\s*env\s\s*zsh\s*/d')"
  cd ~/dotfiles || return
  sh install_zsh.sh

  rm ~/.zshrc

  # Check if the username is "karna"
  if [ "$(whoami)" == "karna" ]; then
    stow_folder="zsh_karna"
  else

    stow_folder="zsh"
  fi

  # Use stow to set up the Zsh configuration
  cd ~/dotfiles || return
  stow "$stow_folder"

  cp Extras/Extras/archcraft-dwm.zsh-theme ~/.oh-my-zsh/themes/archcraft-dwm.zsh-theme

  echo "Zsh has been installed and set as your default shell. Please restart your terminal to apply the changes." && sleep 2
  cd ~/dotfiles || return
  clear
else
  echo "Zsh installation skipped. Proceeding with the setup."
  clear
fi

# --------------------------------------------------------------------------------------

echo "Downloading Wallpapers..." && sleep 1

# ask user if they want to download wallpapers
echo "Would you like to download wallpapers? (y/n)"
read -r download_wallpapers

if [[ "$download_wallpapers" == "y" || "$download_wallpapers" == "Y" ]]; then

  cd ~/Downloads/ || return
  curl -L -o wall.zip https://codeload.github.com/Chaganti-Reddy/wallpapers/zip/refs/heads/main
  unzip wall.zip
  cd wallpapers-main || return
  # move if install_bspwm == "y" 
    sudo mkdir -p /usr/share/backgrounds/
    sudo mv wall/* /usr/share/backgrounds/
    cd ~/dotfiles/ || return  
  mv pix ~/Pictures/ 
  cd ~/Downloads/
  rm -rf wallpapers-main
  cd ~/dotfiles/ || return

  echo "Wallpapers have been downloaded and installed successfully..." && sleep 2
  clear

else

  echo "Wallpapers download skipped. Proceeding with the setup."
  clear
fi

# -------------------------------------------------------------------------------------

echo "Setting Extra Packages for System..." && sleep 1

# Install the bash language server globally using npm
sudo npm i -g bash-language-server

sudo cp ~/dotfiles/Extras/Extras/nvim.desktop /usr/share/applications/nvim.desktop

# Remove existing bashrc and zshrc
rm -rf ~/.bashrc

echo "Installing Themes and Icons..."
# Install themes and icons
cd ~/Downloads/ || return
curl -L -o archcraft-themes.zip https://codeload.github.com/Chaganti-Reddy/archcraft-themes/zip/refs/heads/main
unzip archcraft-themes.zip
rm archcraft-themes.zip
mkdir -p ~/.icons ~/.themes
cd archcraft-themes-main || return
mv themes/* ~/.themes
mv icons/* ~/.icons
cd ~/Downloads || return
rm -rf archcraft-themes-main
cd ~/dotfiles/ || return
sudo cp -r ~/dotfiles/Extras/Extras/dunst/ /usr/share/icons/
echo "Themes and Icons have been installed successfully..." && sleep 2
# Ask the user if they want to install extras
echo "Would you like to install my configs? (y/n)"
read -r install_extras

if [[ "$install_extras" == "y" || "$install_extras" == "Y" ]]; then
  echo "Extras installation will begin now."

  # Check if the username is "karna"
  if [ "$(whoami)" != "karna" ]; then
    # Install for non-karna users
    echo "Stowing configurations for non-karna user..."
    stow bashrc BTOP dunst neofetch flameshot gtk-2 gtk-3 Kvantum mpd mpv ncmpcpp newsboat NWG pandoc pavucontrol qt6ct qutebrowser ranger redyt screensaver sxiv Templates themes Thunar xsettingsd zathura

    cd ~/dotfiles/Extras/Extras/ || return
    #
    sudo cp etc/nanorc /etc/nanorc
    sudo cp etc/bash.bashrc /etc/bash.bashrc
    sudo cp etc/DIR_COLORS /etc/DIR_COLORS
    sudo cp etc/environment /etc/environment

    echo "Extras have been installed." && sleep 1
  else
    # Install for "karna" user
    echo "Stowing configurations for karna..."
    sudo pacman -S zellij
    stow bash_karna BTOP_karna cava dunst face_karna neofetch flameshot gtk-2 gtk-3_karna Kvantum latexmkrc libreoffice mpd_karna mpv_karna myemojis ncmpcpp_karna newsboat_karna nvim NWG octave pandoc pavucontrol qt6ct qutebrowser ranger_karna redyt screenlayout screensaver sxiv Templates Thunar xarchiver xsettingsd zathura zellij

    cd ~/dotfiles/Extras/Extras/ || return

    sudo cp etc/nanorc /etc/nanorc
    sudo cp etc/bash.bashrc /etc/bash.bashrc
    sudo cp etc/DIR_COLORS /etc/DIR_COLORS
    sudo cp etc/environment /etc/environment
    sudo cp etc/mpd.conf /etc/mpd.conf

    sudo cp ~/dotfiles/Extras/Extras/kunst /usr/bin/kusnt

    echo "Setup kaggle JSON and wakatime files using ccrypt... also read essential_info.md file" && sleep 1

    echo "Extras have been installed for KARNA." && sleep 1
  fi
else
  echo "Extras installation skipped. Proceeding with the setup." && sleep 1
fi

clear

echo "All done! Please go through essentials.md before rebooting your system." && sleep 2
