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
sudo pacman --noconfirm -Syu --noconfirm --needed git
clear
echo "System update done" && sleep 2
clear

# --------------------------------------------------------------------------------------

echo "This script requires an AUR helper to install the dependencies. Checking for paru..." && sleep 2

# Check if paru is installed
if ! command -v paru &>/dev/null; then
  echo "Paru is not installed. Installing Paru, an AUR helper..."
  
  # Navigate to Downloads and install paru
  cd ~/Downloads || { echo "Failed to navigate to ~/Downloads"; exit 1; }
  git clone https://aur.archlinux.org/paru-bin.git
  cd paru-bin || { echo "Failed to navigate to paru-bin"; exit 1; }
  makepkg -si --noconfirm
  
  # Clean up
  echo "Cleaning up installation files..."
  cd .. && rm -rf paru-bin
  echo "Paru installed successfully." && sleep 1
else
  echo "Paru is already installed."
fi

# Navigate back to dotfiles directory
cd ~/dotfiles || { echo "Failed to navigate to ~/dotfiles"; exit 1; }

# Clear the terminal for the next steps
clear

# --------------------------------------------------------------------------------------

# Install base-devel and required packages
echo "Installing dependencies.." && sleep 2

# Define package files
PACMAN_PACKAGES_FILE="packages.txt"
PARU_PACKAGES_FILE="paru-packages.txt"

# Function to install packages using a package manager
install_packages() {
  local package_manager=$1
  local package_file=$2

  echo "Installing packages using $package_manager from $package_file..."

  while IFS= read -r package; do
    if ! pacman -Q "$package" &>/dev/null; then
      echo "Installing $package..."
      $package_manager -S --noconfirm --needed "$package"
    else
      echo "$package is already installed."
    fi
  done <"$package_file"
}

# Install packages from pacman and paru lists
install_packages "sudo pacman" "$PACMAN_PACKAGES_FILE" 
clear
echo "All Pacman packages are installed and up-to-date!"
sleep 1
install_packages "paru" "$PARU_PACKAGES_FILE"
clear
echo "All Paru packages are installed and up-to-date!"
sleep 1

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

echo "Setting up Git configuration..." && sleep 1

# Ask user whether to proceed with Git setup
read -rp "Do you want to proceed with setting up Git configuration? (y/n) [default: y]: " response
response=${response:-y} # Default to 'y' if the user presses Enter
if [[ ! "$response" =~ ^[Yy]$ ]]; then
  echo "Git setup skipped. Proceeding with the next module." && sleep 1
  clear
  exit 0
fi

# Prompt for Git username
while true; do
  read -rp "Enter your Git username: " git_username
  if [ -n "$git_username" ]; then
    break
  else
    echo "Git username cannot be empty. Please try again."
  fi
done

# Prompt for Git email
while true; do
  read -rp "Enter your Git email: " git_email
  if [[ "$git_email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    break
  else
    echo "Invalid email address. Please try again."
  fi
done

# Allow the user to select an editor
echo "Select your preferred editor for Git:"
echo "1) Vim"
echo "2) Nano"
echo "3) VSCode"
echo "4) Neovim"
echo "5) None (skip editor configuration)"
read -rp "Enter the number corresponding to your choice [default: 1]: " editor_choice
editor_choice=${editor_choice:-1} # Default to Vim if the user presses Enter

case $editor_choice in
  1) editor="vim" ;;
  2) editor="nano" ;;
  3) editor="code" ;;
  4) editor="nvim" ;;
  5) editor="" ;;
  *) 
    echo "Invalid choice. Defaulting to Vim."
    editor="vim"
    ;;
esac

# Confirm Git configuration
echo -e "\nPlease confirm the Git configuration:"
echo "Username: $git_username"
echo "Email: $git_email"
[[ -n $editor ]] && echo "Editor: $editor" || echo "Editor: None (skipped)"
read -rp "Do you want to proceed with this configuration? (y/n) [default: y]: " confirm
confirm=${confirm:-y} # Default to 'y' if the user presses Enter
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "Git configuration canceled. No changes were made." 
  clear
  exit 0
fi

# Apply Git configuration
echo "Applying Git configuration..."
git config --global user.name "$git_username"
git config --global user.email "$git_email"
if [[ -n $editor ]]; then
  git config --global core.editor "$editor"
  echo "Editor set to $editor."
else
  echo "Editor configuration skipped."
fi

# Additional Git tweaks for better usability
echo "Applying additional Git tweaks..."
git config --global core.autocrlf input
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global credential.helper "cache --timeout=3600"
git config --global color.ui auto
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.unstage 'reset HEAD --'
git config --global log.decorate true
git config --global push.default simple
git config --global push.autoSetupRemote true

echo "Git has been successfully configured with the following settings:"
git config --list | grep -E "user.name|user.email|core.editor|init.defaultBranch|alias|push.default"

sleep 4
clear

# -------------------------------------------------------------------------------------

echo "Setting up Zsh..."

# Default to 'y' if no input is provided
read -rp "Would you like to install Zsh and set it as your default shell? (y/n) [default: y]: " install_zsh
install_zsh=${install_zsh:-y} # Default to 'y' if no input is provided

if [[ "$install_zsh" =~ ^[Yy]$ ]]; then
  echo "Zsh installation will begin now."

  # Install Zsh and related tools if not already installed
  sudo pacman -S --noconfirm zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting

  # Change the default shell to Zsh
  chsh -s /bin/zsh

  # Install Oh My Zsh and set up custom configurations
  echo "Installing Oh My Zsh..."
  cd ~/dotfiles || return
  sh install_zsh.sh

  # Remove any existing Zsh configuration file
  rm -f ~/.zshrc

  # Check if the username is "karna" and choose the correct stow folder
  if [ "$(whoami)" == "karna" ]; then
    stow_folder="zsh_karna"
  else
    stow_folder="zsh"
  fi

  # Use stow to set up the Zsh configuration
  stow "$stow_folder"

  # Copy additional theme if present
  cp Extras/Extras/archcraft-dwm.zsh-theme ~/.oh-my-zsh/themes/archcraft-dwm.zsh-theme

  echo "Zsh has been installed and set as your default shell."
  echo "Please restart your terminal to apply the changes." && sleep 2
  clear
else
  clear
  echo "Zsh installation skipped. Proceeding with the setup."
fi

# -------------------------------------------------------------------------------------

setup_gpg_pass() {
    echo "Do you want to set up GPG and Pass for password management? (Y/n)"
    read -r RESPONSE
    RESPONSE=${RESPONSE:-y}  # Default to 'y' if user presses Enter

    if [[ "$RESPONSE" =~ ^[Nn]$ ]]; then
        echo "Skipping GPG and Pass setup." && sleep 1
        return
    fi

    echo "Setting up GPG and Pass..."

    # Check if required packages are already installed
    if ! pacman -Q gnupg pass rofi-pass-wayland-git qrencode pass-import &> /dev/null; then
        echo "Installing GPG and Pass..."
        sudo pacman -S --noconfirm gnupg pass qrencode
        paru -S --noconfirm rofi-pass-wayland-git pass-import
    else
        echo "Required packages are already installed. Skipping installation."
    fi

    # Ask for user details
    echo -n "Enter your name: "
    read -r NAME
    echo -n "Enter your email: "
    read -r EMAIL
    echo -n "Enter a comment (optional): "
    read -r COMMENT

    # Check if a GPG key for the email already exists
    if gpg --list-keys "$EMAIL" > /dev/null 2>&1; then
        echo "GPG key for $EMAIL already exists. Skipping key generation."
    else
        echo "Generating a new GPG key..."

        cat >key-config <<EOF
        %echo Generating a GPG key
        Key-Type: RSA
        Key-Length: 4096
        Name-Real: $NAME
        Name-Comment: ${COMMENT:-None}
        Name-Email: $EMAIL
        Expire-Date: 0
        %commit
        %echo Done
EOF
        gpg --batch --full-generate-key key-config
        rm -f key-config
    fi

    # Check if pass is already initialized
    if pass show test-check > /dev/null 2>&1; then
        echo "Pass is already initialized. Skipping initialization."
    else
        echo "Initializing pass with GPG key linked to $EMAIL..."
        pass init "$EMAIL"
    fi

    # Secure GPG - Disable key caching
    echo "Reducing GPG key caching time for better security..." && sleep 0.5
    echo "default-cache-ttl 60" >> ~/.gnupg/gpg-agent.conf
    echo "max-cache-ttl 60" >> ~/.gnupg/gpg-agent.conf
    gpgconf --kill gpg-agent  # Restart agent to apply changes

    echo "GPG and Pass setup completed successfully!" && sleep 2
}

setup_gpg_pass

# -------------------------------------------------------------------------------------

echo "Setting up Hyprland..." && sleep 1

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
    echo "$display_name ($package_name) is already installed."
  else
    echo "Installing $display_name ($package_name)..."
    $command "$package_name"
  fi
}

# Ask the user if they want to install Hyprland (default is yes)
echo "Would you like to install Hyprland (a dynamic Wayland compositor)? (y/n) [default: y]"
read -r install_hyprland
install_hyprland=${install_hyprland:-y}  # Default to "y" if no input is provided

if [[ "$install_hyprland" == "y" || "$install_hyprland" == "Y" ]]; then
  echo "Hyprland installation will begin now."

  # List of packages to install
  packages=(
    "hyprland-git"
    "hyprlock-git"
    "xdg-desktop-portal-hyprland-git"
    "hyprlang-git"
    "clipse-bin"
    "hyde-cli-git"
    "hyprshot-git"
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
    "foot"
    "brightnessctl"
    "cmake"
    "meson"
    "cpio"
    "grim"
    "slurp"
    "wtype"
    "wf-recorder"
    "wofi"
    "pyprland-git"
  )

  # Install the packages
  for package in "${packages[@]}"; do
    install_package "$package" "$package" "paru -S --noconfirm --needed"
  done

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

  # Install waldl if not already installed
  echo "Installing waldl..."
  cd ~/dotfiles/Extras/Extras/waldl-master/ && sudo make install && cd ~/dotfiles || return

  echo "Setup is complete. Proceeding to next modules..." && sleep 2
  clear
else
  echo "Hyprland installation skipped. Proceeding with the setup." && sleep 1
fi


# -------------------------------------------------------------------------------------

echo "Setting up Miniconda..." && sleep 1

# Ask the user if they want to install Miniconda
read -rp "Would you like to install Miniconda? (y/n) [default: y]: " response
response=${response:-y} # Default to 'y' if the user presses Enter
if [[ ! "$response" =~ ^[Yy]$ ]]; then
  echo "Miniconda installation skipped. Proceeding with the setup." 
  clear
else
  echo "Miniconda installation will begin now." && sleep 1

  # Define Miniconda installer URL
  MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-py310_24.3.0-0-Linux-x86_64.sh"
  INSTALLER_NAME="Miniconda3.sh"

  # Download Miniconda installer
  echo "Downloading Miniconda installer..."
  wget -q --show-progress -O "$INSTALLER_NAME" "$MINICONDA_URL"

  # Run the installer
  echo "Running the Miniconda installer..."
  bash "$INSTALLER_NAME" -b -p "$HOME/miniconda" # Install silently in the $HOME/miniconda directory

  # Remove the installer after installation
  echo "Cleaning up installer files..."
  rm "$INSTALLER_NAME"

  # Check if .bashrc and .zshrc exist and set Conda initialization
  SHELL_CONFIGS=()
  if [[ -f "$HOME/.bashrc" ]]; then
    SHELL_CONFIGS+=("$HOME/.bashrc")
  fi
  if [[ -f "$HOME/.zshrc" ]]; then
    SHELL_CONFIGS+=("$HOME/.zshrc")
  fi

  if [[ ${#SHELL_CONFIGS[@]} -eq 0 ]]; then
    echo "Neither .bashrc nor .zshrc found. Exiting setup."
    exit 1
  fi

  # Conda initialization block
  CONDA_BLOCK='
# >>> conda initialize >>>
# !! Contents within this block are managed by "conda init" !!
__conda_setup="$('$HOME/miniconda/bin/conda' shell.${SHELL##*/} hook 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniconda/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniconda/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniconda/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<'

  # Add Conda initialization to both files if not already present
  for config in "${SHELL_CONFIGS[@]}"; do
    if ! grep -q "conda initialize" "$config"; then
      echo "Adding Conda initialization to $config..."
      echo "$CONDA_BLOCK" >> "$config"
    else
      echo "Conda initialization block already present in $config."
    fi
  done

  # Now execute the Conda initialization code directly to initialize Conda
  if [[ "$SHELL" == *"bash"* ]]; then
    # Bash initialization
    eval "$($HOME/miniconda/bin/conda shell.bash hook)"
    echo "Evaluating $HOME/miniconda/bin/conda shell.bash hook"
  elif [[ "$SHELL" == *"zsh"* ]]; then
    # Zsh initialization
    eval "$($HOME/miniconda/bin/conda shell.zsh hook)"
    echo "Evaluating $HOME/miniconda/bin/conda shell.zsh hook"
  else
    echo "Unsupported shell detected. Unable to initialize Conda."
    exit 1
  fi

  # Verify Conda and Python installation
  echo "Verifying Miniconda installation..."
  conda --version
  python --version

  echo -e "\nMiniconda installation and initialization completed successfully."
  echo "Python Version: $(python --version)"
  echo "Conda Version: $(conda --version)"
  echo -e "Installation path: $HOME/miniconda\n"

  sleep 3
  echo "Miniconda setup is complete. Proceeding with the script..."
fi
#
# # -------------------------------------------------------------------------------------
#
echo "Setting up KVM..." && sleep 1

# Ask the user if they want to install KVM QEMU
read -rp "Would you like to install KVM QEMU Virtual Machine? (y/n) [default: y]: " response
response=${response:-y} # Default to 'y' if the user presses Enter without input

if [[ ! "$response" =~ ^[Yy]$ ]]; then
  echo "KVM installation skipped. Proceeding with the setup."
  clear
else
  echo "KVM installation will begin now." && sleep 1

  # Install necessary packages for KVM and associated tools
  echo "Installing KVM and required packages..."
  sudo pacman -S --noconfirm qemu-full qemu-img libvirt virt-install virt-manager virt-viewer spice-vdagent edk2-ovmf dnsmasq swtpm guestfs-tools libosinfo tuned

  # Ensure system is ready for virtualization (nested virtualization check)
  echo "Checking for hardware virtualization support..."
  if ! grep -qE '(vmx|svm)' /proc/cpuinfo; then
    echo "Error: Your CPU does not support virtualization or it's disabled in BIOS. Please enable virtualization in BIOS settings." && sleep 2
  fi

  # Enable and start the libvirt service
  echo "Starting libvirt service..."
  sudo systemctl enable --now libvirtd.service

  # Add user to the libvirt group to allow access to KVM
  echo "Adding user '$USER' to the libvirt group..."
  sudo usermod -aG libvirt "$USER"

  # Autostart libvirt network (default network for virtual machines)
  echo "Configuring libvirt network to autostart..."
  sudo virsh net-autostart default

  # Enable KVM with nested virtualization (useful for running KVM inside a VM)
  echo "Enabling KVM with nested virtualization..."
  sudo modprobe -r kvm_intel
  sudo modprobe kvm_intel nested=1

  # Verify KVM modules
  echo "Verifying KVM modules are loaded..."
  lsmod | grep kvm

  echo "KVM installation completed." && sleep 2
  clear

  # Provide user with additional info and documentation
  echo "For VM sharing details, visit: https://docs.getutm.app/guest-support/linux/" && sleep 1
  echo "Please restart your machine to apply all changes."
fi

# -------------------------------------------------------------------------------------

echo "Installing Browsers that I personally use the most..." && sleep 1

# Function to check if a package is installed
is_installed() {
  pacman -Qi "$1" &>/dev/null
  return $?
}

# Function to display the browser selection menu
install_browser() {
  echo "Select the browsers you want to install (you can select multiple by entering numbers separated by spaces):"
  echo "1) Zen-Browser(If none - Default)"
  echo "2) Firefox"
  echo "3) Chromium"
  echo "4) Vivaldi"
  echo "5) qutebrowser"
  echo "6) Brave"
  echo "100) None (skip installation)"
  echo ""
  echo "Enter the numbers corresponding to your choices (e.g., 1 3 5), or press Enter to skip:"

  # Read user input (browser choices)
  read -r choices
  choices=${choices:-1}  # Default to installing Zen-Browser if no input is provided 

  # Process the selected options
  for choice in $choices; do
    case $choice in
      1)
        if is_installed "zen-browser-bin"; then
          echo "Zen-Browser is already installed."
        else
          echo "Installing Zen-Browser..."
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
          echo "Firefox is already installed."
        else
          echo "Installing Firefox..."
          sudo pacman -S --noconfirm firefox
          pip install --index-url https://test.pypi.org/simple/ pywalfox==2.8.0rc1
          pywalfox install
          curl -sSLf https://github.com/aclap-dev/vdhcoapp/releases/latest/download/install.sh | bash
        fi
        ;;
      3)
        if is_installed "chromium"; then
          echo "Chromium is already installed."
        else
          echo "Installing Chromium..."
          sudo pacman -S --noconfirm chromium
        fi
        ;;
      4)
        if is_installed "vivaldi"; then
          echo "Vivaldi is already installed."
        else
          echo "Installing Vivaldi..."
          paru -S --noconfirm vivaldi
        fi
        ;;
      5)
        if is_installed "qutebrowser"; then
          echo "qutebrowser is already installed."
        else
          echo "Installing qutebrowser..."
          sudo pacman -S --noconfirm qutebrowser
        fi
        ;;
      6)
        if is_installed "brave-bin"; then
          echo "Brave is already installed."
        else
          echo "Installing Brave..."
          paru -S --noconfirm brave-bin
        fi
        ;;
      100)
        clear
        echo "Skipping all installations." && sleep 2
        return
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

echo "Setting up torrent and remote working applications..." && sleep 1

# Function to check if a package is installed
is_installed() {
  pacman -Qi "$1" &>/dev/null
  return $?
}

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
  echo "No applications selected. Continuing without this installation." && sleep 2
  clear
fi

# Process selected applications and install them
for app in $apps; do
  case $app in
  1)
    if is_installed "webtorrent-cli" && is_installed "webtorrent-mpv-hook" && is_installed "peerflix"; then
      echo "torrent-cli is already installed."
    else
      echo "Installing torrent-cli (webtorrent-cli, webtorrent-mpv-hook, peerflix)..."
      paru -S --noconfirm --needed webtorrent-cli webtorrent-mpv-hook peerflix
    fi
    ;;
  2)
    if is_installed "qbittorrent"; then
      echo "qBittorrent is already installed."
    else
      echo "Installing qBittorrent..."
      sudo pacman -S --noconfirm qbittorrent
    fi
    ;;
  3)
    if is_installed "transmission-qt"; then
      echo "Transmission is already installed."
    else
      echo "Installing Transmission..."
      sudo pacman -S --noconfirm transmission-qt
    fi
    ;;
  4)
    if is_installed "remmina"; then
      echo "Remmina (Remote Desktop Client) is already installed."
    else
      echo "Installing Remmina (Remote Desktop Client)..."
      sudo pacman -S --noconfirm remmina
    fi
    ;;
  5)
    if is_installed "tigervnc"; then
      echo "VNC Server is already installed."
    else
      echo "Installing VNC Server..."
      sudo pacman -S --noconfirm tigervnc
    fi
    ;;
  6)
    if is_installed "teamviewer"; then
      echo "TeamViewer is already installed."
    else
      echo "Installing TeamViewer..."
      sudo pacman -S --noconfirm teamviewer
    fi
    ;;
  7)
    if is_installed "anydesk"; then
      echo "AnyDesk is already installed."
    else
      echo "Installing AnyDesk..."
      sudo pacman -S --noconfirm anydesk
    fi
    ;;
  8)
    if is_installed "xrdp"; then
      echo "xrdp (Remote Desktop Protocol) is already installed."
    else
      echo "Installing xrdp (Remote Desktop Protocol)..."
      sudo pacman -S --noconfirm xrdp
    fi
    ;;
  9)
    if is_installed "openvpn"; then
      echo "OpenVPN is already installed."
    else
      echo "Installing OpenVPN..."
      sudo pacman -S --noconfirm openvpn
    fi
    ;;
  10)
    if is_installed "wireguard-tools"; then
      echo "WireGuard is already installed."
    else
      echo "Installing WireGuard..."
      sudo pacman -S --noconfirm wireguard-tools
    fi
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
echo "Setting up development tools, office tools, communication tools, and multimedia tools..." && sleep 1

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
    echo "$display_name ($package_name) is already installed."
  else
    echo "Installing $display_name ($package_name)..."
    $command "$package_name"
  fi
}

# Function to install multiple packages for a single tool
install_multiple_packages() {
  local packages=("$@")
  for package in "${packages[@]}"; do
    install_package "$package" "$package" "paru -S --noconfirm --needed"
  done
}

# Display tool options
echo "Choose tools to install (enter numbers separated by spaces):"
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

echo "Enter your choices (e.g., 1 2 4), or press Enter to skip:"
read -r tools_choices
tools_choices=${tools_choices:-} # Default to empty if no input is provided

if [ -z "$tools_choices" ]; then
  echo "No tools selected for installation. Continuing..." && sleep 1
  clear
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
      echo "Installing kubectl..."
      curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
      sudo install -m 0755 kubectl /usr/local/bin/kubectl
      rm kubectl
    else
      echo "kubectl is already installed."
    fi
    ;;
  6)
    install_multiple_packages "texlive-bin" "texlive-meta" "texlive-latex" "perl-yaml-tiny" \
                               "perl-file-homedir" "perl-unicode-linebreak"
    ;;
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
  *) echo "Invalid choice: $app" ;;
  esac
  echo "Processing completed for the selected tool(s)." && sleep 2
done

# -------------------------------------------------------------------------------------

echo "Setting up additional tools and packages..." && sleep 1

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
    echo "$display_name ($package_name) is already installed."
  else
    echo "Installing $display_name ($package_name)..."
    $command "$package_name"
  fi
}

# Display the list of extra tools
echo "Choose the tools you want to install by entering the corresponding numbers, separated by spaces:"
cat << EOF
1) Ani-Cli                    2) Ani-Cli-PY
3) ytfzf                      4) Zathura
5) Evince                     6) Okular
7) Foxit-Reader               8) Master-PDF-Editor
9) MuPDF
EOF

echo "Enter your choices (e.g., 1 2 4), or press Enter to skip:"
read -r extra_tools_choices
extra_tools_choices=${extra_tools_choices:-} # Default to empty if no input is provided

if [ -z "$extra_tools_choices" ]; then
  echo "No packages selected. Continuing without installation..." && sleep 1
fi

# Process the selected tools
for app in $extra_tools_choices; do
  case $app in
  1)
    install_package "ani-cli-git" "Ani-Cli" "paru -S --noconfirm --needed"
    ;;
  2)
    install_package "ani-cli-git" "Ani-Cli Python" "paru -S --noconfirm --needed"
    pip install anipy-cli
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
    echo "Invalid choice: $app"
    ;;
  esac
  echo "Processing for the selected extra tool(s) completed." && sleep 2
done
# -------------------------------------------------------------------------------------

echo "Setting up MariaDB..."

# Ask the user if they want to install and configure MariaDB
echo "Would you like to install and configure MariaDB (a relational database management system)? (y/n)"
read -r mariadb_installation

# Check if the user wants to proceed with MariaDB setup
if [[ "$mariadb_installation" == "Y" || "$mariadb_installation" == "y" || -z "$mariadb_installation" ]]; then
  # Check if MariaDB is installed
  if ! command -v mariadb &> /dev/null; then
    echo "MariaDB is not installed. Installing now..."
    
    # Install MariaDB
    sudo pacman -S mariadb --noconfirm

    # Initialize the database
    sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

    # Enable and start MariaDB service
    sudo systemctl enable --now mariadb

    echo "MariaDB has been installed and initialized."
  else
    echo "MariaDB is already installed."

    # Check if MariaDB is running or configured
    if systemctl is-active --quiet mariadb; then
      echo "MariaDB is already configured and running."
    else
      echo "MariaDB is installed but not configured. Do you want to configure it now? (y/n)"
      read -r mariadb_configure

      if [[ "$mariadb_configure" == "Y" || "$mariadb_configure" == "y" || -z "$mariadb_configure" ]]; then
        # Run the MariaDB secure installation
        sudo mariadb-secure-installation

        # Enable and start MariaDB service if not already running
        sudo systemctl enable --now mariadb

        echo "MariaDB has been configured and started."
      else
        echo "Skipping MariaDB configuration."
      fi
    fi
  fi
else
  echo "MariaDB installation and configuration skipped. Proceeding with the setup."
fi
sleep 2
clear

# -------------------------------------------------------------------------------------

echo "Setting up Fonts..." && sleep 1

# Check if the fonts directory exists
if [ -d "$HOME/.local/share/fonts/my-fonts-main" ]; then
  echo "Fonts directory already exists. Skipping installation..." && sleep 1
else
  # Create fonts directory if it doesn't exist
  echo "Creating fonts directory..."
  mkdir -p ~/.local/share/fonts

  # Download the zip file
  echo "Downloading fonts..."
  curl -L -o ~/.local/share/fonts/my-fonts.zip https://github.com/Chaganti-Reddy/my-fonts/archive/main.zip

  # Extract the fonts
  echo "Extracting fonts..."
  unzip -q ~/.local/share/fonts/my-fonts.zip -d ~/.local/share/fonts

  # Clean up the downloaded zip file
  echo "Cleaning up..."
  rm ~/.local/share/fonts/my-fonts.zip
  echo "Fonts have been installed successfully." && sleep 2
  clear
fi

# -------------------------------------------------------------------------------------

echo "Setting up dwm..."

# Ask the user if they want to install dwm with default to "yes"
read -p "Would you like to install dwm (Dynamic Window Manager)? (y/n): " install_dwm
install_dwm="${install_dwm:-y}"  # Default to "y" if no input is provided

if [[ "$install_dwm" == "y" || "$install_dwm" == "Y" ]]; then
  echo "Starting dwm installation..."

  # Check if dwm and required directories already exist
  if command -v dwm &>/dev/null && [ -d ~/.config/dwm ] && [ -d ~/.config/slstatus ] && [ -d ~/.config/st ] && [ -d ~/.config/dmenu ]; then
    echo "dwm and its configurations are already installed. Skipping installation."
  else
    # Install dwm and related packages if missing
    echo "Installing dwm and related packages..."
    cd ~/dotfiles || return
    stow suckless/
    stow DWMScripts

    # Install dwm, slstatus, st, and dmenu
    if [ ! -d ~/.config/dwm ]; then
      cd ~/.config/dwm && sudo make clean install
    fi
    if [ ! -d ~/.config/slstatus ]; then
      cd ~/.config/slstatus && sudo make clean install
    fi
    if [ ! -d ~/.config/st ]; then
      cd ~/.config/st && sudo make install
    fi
    if [ ! -d ~/.config/dmenu ]; then
      cd ~/.config/dmenu && sudo make install
    fi

    # Install extra tools from the dotfiles repository
    cd ~/dotfiles/Extras/Extras/waldl-master/ && sudo make install && cd ~/dotfiles || return

    # Set up dwm session if not already set up
    if [ ! -f /usr/share/xsessions/dwm.desktop ]; then
      sudo mkdir -p /usr/share/xsessions/
      sudo cp ~/dotfiles/Extras/Extras/usr/share/xsessions/dwm.desktop /usr/share/xsessions
    fi

    echo "dwm has been successfully installed and configured."
  fi
  sleep 2
  clear
else
  echo "dwm installation skipped. Proceeding with the setup." && sleep 1 
fi

# --------------------------------------------------------------------------------------

echo "Setting up BSPWM..."

# Ask the user if they want to install bspwm with default to "yes"
read -p "Would you like to install bspwm? (y/n): " install_bspwm
install_bspwm="${install_bspwm:-y}"  # Default to "y" if no input is provided

if [[ "$install_bspwm" == "y" || "$install_bspwm" == "Y" ]]; then
  echo "Starting bspwm installation..."

  # List of packages to install
  bspwm_packages=(
    "bspwm" "sxhkd" "pastel" "alacritty" "polybar" "xfce4-power-manager"
    "xsettingsd" "xorg-xsetroot" "wmname" "xcolor" "yad" "pulsemixer"
    "maim" "feh" "ksuperkey" "betterlockscreen" "light" "networkmanager-dmenu-git"
  )

  # Loop through each package and install if not already installed
  for pkg in "${bspwm_packages[@]}"; do
    if ! pacman -Q "$pkg" &>/dev/null; then
      echo "$pkg is not installed. Installing..."
      paru -S --noconfirm --needed "$pkg"
    else
      echo "$pkg is already installed."
    fi
  done

  # Set up configuration files
  echo "Setting up bspwm configurations..."
  cd ~/dotfiles || return
  stow feh
  stow bspwm/
  stow network-dmenu/

  # Install additional extras if needed
  cd ~/dotfiles/Extras/Extras/waldl-master/ && sudo make install && cd ~/dotfiles || return

  echo "bspwm has been successfully installed and configured."
  sleep 2
  clear
else
  echo "bspwm installation skipped. Proceeding with the setup." && sleep 1
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
    models=("llama3" "mistral" "gemma:7b")
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
  echo "Ollama installation skipped. Proceeding with the setup." && sleep 1
fi
#
# --------------------------------------------------------------------------------------

echo "Setting up PIP Packages..."

# Ask the user if they want to install PIP packages, defaulting to "yes"
read -p "Would you like to install my PIP packages? (y/n): " install_pip_packages
install_pip_packages="${install_pip_packages:-y}"  # Default to "y" if no input is provided

eval "$($HOME/miniconda/bin/conda shell.zsh hook)"

# Check if conda is available, if not, skip the installation
if command -v conda &>/dev/null; then
  if [[ "$install_pip_packages" == "y" || "$install_pip_packages" == "Y" ]]; then
    echo "Conda detected, installing PIP packages..."

    # List of packages to install
    pip_packages=("pynvim" "numpy" "pandas" "matplotlib" "seaborn" "scikit-learn" "jupyterlab" "ipykernel" "ipywidgets" "tensorflow" "python-prctl" "inotify-simple" "psutil" "opencv-python" "keras" "mov-cli-youtube" "mov-cli" "mov-cli-test" "otaku-watcher" "film-central" "daemon" "jupyterlab_wakatime" "pygobject" "spotdl" "beautifulsoup4" "requests" "flask" "streamlit" "pywal16" "zxcvbn" "pyaml" "my_cookies")
    
    # Install each package if it's not already installed
    for package in "${pip_packages[@]}"; do
      if ! pip show "$package" &>/dev/null; then
        echo "Installing $package..."
        pip install "$package"
      else
        echo "$package is already installed."
      fi
    done

    # Install PyTorch (CPU version)
    if ! pip show "torch" &>/dev/null; then
      echo "Installing PyTorch (CPU version)..."
      pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
    else
      echo "PyTorch is already installed."
    fi

    echo "PIP packages installation completed."
    sleep 2
    clear
  else
    echo "PIP packages installation skipped. Proceeding with the setup." && sleep 1
    clear
  fi
else
  echo "Conda not found, skipping PIP packages installation." && sleep 1
fi
# --------------------------------------------------------------------------------------

echo "Setting up GRUB theme..."

# Ask the user if they want to set up a GRUB theme, defaulting to "yes"
read -p "Would you like to install a GRUB theme? (y/n): " install_grub_theme
install_grub_theme="${install_grub_theme:-y}"  # Default to "y" if no input is provided

# Check if the user wants to install the GRUB theme
if [[ "$install_grub_theme" == "y" || "$install_grub_theme" == "Y" ]]; then
  echo "GRUB theme setup will begin now."

  # Check if the theme directory exists before copying
  if [[ -d ~/dotfiles/Extras/Extras/boot/grub/themes/SekiroShadow/ ]]; then
    # Copy the GRUB theme files if they exist
    sudo cp -r ~/dotfiles/Extras/Extras/boot/grub/themes/SekiroShadow/ /boot/grub/themes/
    echo "GRUB theme files copied successfully."
  else
    echo "GRUB theme files not found. Skipping theme setup."
    exit 1  # Exit if the theme files are missing
  fi

  # Enable the GRUB theme in the GRUB configuration
  echo "Setting GRUB theme..."
  if ! grep -q 'GRUB_THEME="/boot/grub/themes/SekiroShadow/theme.txt"' /etc/default/grub; then
    echo 'GRUB_THEME="/boot/grub/themes/SekiroShadow/theme.txt"' | sudo tee -a /etc/default/grub
  fi

  # Enable os-prober in GRUB configuration if not already set
  echo "Enabling os-prober in GRUB configuration..."
  if ! grep -q 'GRUB_DISABLE_OS_PROBER="false"' /etc/default/grub; then
    echo 'GRUB_DISABLE_OS_PROBER="false"' | sudo tee -a /etc/default/grub
  fi

  # Regenerate GRUB configuration
  echo "Regenerating GRUB configuration..."
  sudo grub-mkconfig -o /boot/grub/grub.cfg

  echo "GRUB theme setup is complete, and GRUB config has been updated."
  sleep 2
  clear
else
  echo "GRUB theme setup skipped. Proceeding with the setup." && sleep 1
fi

# --------------------------------------------------------------------------------------

echo "Display/Login Manager Setup"

# Ask if the user wants to install a Display Manager
read -p "Would you like to install a Display/Login Manager? (y/n): " install_dm
install_dm="${install_dm:-y}"  # Default to "y" if no input is provided

if [[ "$install_dm" == "y" || "$install_dm" == "Y" ]]; then
  echo "Choose a Display Manager:"
  echo "1) SDDM (Simple Desktop Display Manager - GUI)"
  echo "2) LY (Simple TUI Login Manager - Terminal-based)"
  
  read -p "Enter your choice (1/2): " dm_choice
  
  if [[ "$dm_choice" == "1" ]]; then
    echo "Installing SDDM..."

    # Install SDDM and related packages
    paru -S --noconfirm --needed sddm qt6-5compat qt6-declarative qt6-svg qt6-virtualkeyboard qt6-multimedia-ffmpeg layer-shell-qt5

    echo "Enabling SDDM to start at boot..."
    sudo systemctl enable sddm.service

    # Check if the theme directory exists before copying
    if [[ -d ~/dotfiles/Extras/Extras/usr/share/sddm/themes/simple-sddm/ ]]; then
      sudo cp -r ~/dotfiles/Extras/Extras/usr/share/sddm/themes/simple-sddm/ /usr/share/sddm/themes
      echo "SDDM theme files copied successfully."
    else
      echo "SDDM theme files not found. Skipping theme setup."
    fi

    # Check if the SDDM configuration file exists before copying
    if [[ -f ~/dotfiles/Extras/Extras/etc/sddm.conf ]]; then
      sudo cp ~/dotfiles/Extras/Extras/etc/sddm.conf /etc/sddm.conf
      echo "SDDM configuration file copied successfully."
    else
      echo "SDDM configuration file not found. Skipping configuration setup."
    fi

    clear
    echo "SDDM has been installed and enabled to start at boot." && sleep 1

  elif [[ "$dm_choice" == "2" ]]; then
    echo "Installing LY..."

    # Install LY and related packages
    paru -S --noconfirm --needed ly

    echo "Enabling LY to start at boot..."
    sudo systemctl enable ly.service

    # Check if the LY configuration file exists before copying
    if [[ -f ~/dotfiles/Extras/Extras/etc/ly/config.ini ]]; then
      sudo cp ~/dotfiles/Extras/Extras/etc/ly/config.ini /etc/ly/config.ini
      echo "LY configuration file copied successfully."
    else
      echo "LY configuration file not found. Skipping configuration setup."
    fi

    clear
    echo "LY has been installed and enabled to start at boot." && sleep 1

  else
    echo "Invalid choice. No display manager installed." && sleep 1
  fi

else
  echo "Display Manager installation skipped. Proceeding with the setup." && sleep 1
fi

# --------------------------------------------------------------------------------------

echo "Downloading Wallpapers..." && sleep 1

# Ask user if they want to download wallpapers
read -p "Would you like to download wallpapers? (y/n): " download_wallpapers
download_wallpapers="${download_wallpapers:-y}"  # Default to "y" if no input is provided

# Check if the user wants to download wallpapers
if [[ "$download_wallpapers" == "y" || "$download_wallpapers" == "Y" ]]; then
  # Check if pix folder is already in ~/Pictures/
  if [ ! -d "$HOME/Pictures/pix" ]; then
    echo "Pix folder not found in Pictures. Downloading wallpapers..."

    cd ~/Downloads/ || return
    curl -L -o wall.zip https://codeload.github.com/Chaganti-Reddy/wallpapers/zip/refs/heads/main
    unzip wall.zip
    cd wallpapers-main || return

    # Check if bspwm is installed using pacman
    if pacman -Q bspwm &>/dev/null; then
      # Move wallpapers to /usr/share/backgrounds/ from the wall folder
      sudo mkdir -p /usr/share/backgrounds/
      sudo mv wall/* /usr/share/backgrounds/
    fi

    # Move the pix folder to ~/Pictures/
    echo "Moving pix folder to ~/Pictures/"
    mv pix ~/Pictures/

    # Clean up and reset directories
    cd ~/Downloads/
    rm -rf wallpapers-main
    cd ~/dotfiles/ || return

    echo "Wallpapers have been downloaded and installed successfully..." && sleep 2
    clear
  else
    echo "Pix folder already exists in ~/Pictures/, skipping download." && sleep 1
  fi

else
  echo "Wallpapers download skipped. Proceeding with the setup." && sleep 1
fi

# -------------------------------------------------------------------------------------

echo "Setting Extra Packages for System..." && sleep 1

# Install the bash language server globally using npm
if ! command -v bash-language-server &>/dev/null; then
  echo "Installing bash-language-server..."
  sudo npm i -g bash-language-server
else
  echo "bash-language-server is already installed."
fi

# Ask the user if they want to install themes and icons
read -p "Would you like to install themes and icons? (y/n): " install_themes_icons
install_themes_icons="${install_themes_icons:-y}" # Default to "y" if no input is provided

if [[ "$install_themes_icons" == "y" || "$install_themes_icons" == "Y" ]]; then
  echo "Installing Themes and Icons..."
  cd ~/Downloads/ || return
  if [ ! -d "archcraft-themes-main" ]; then
    curl -L -o archcraft-themes.zip https://codeload.github.com/Chaganti-Reddy/archcraft-themes/zip/refs/heads/main
    unzip archcraft-themes.zip
    rm archcraft-themes.zip
  fi

  mkdir -p ~/.icons ~/.themes
  cd archcraft-themes-main || return
  mv themes/* ~/.themes
  mv icons/* ~/.icons
  cd ~/Downloads || return
  rm -rf archcraft-themes-main
  cd ~/dotfiles/ || return

  # Copy Dunst icons
  sudo cp -r ~/dotfiles/Extras/Extras/dunst/ /usr/share/icons/

  echo "Themes and Icons have been installed successfully..." && sleep 2
else
  echo "Themes and Icons installation skipped." && sleep 1
fi

# Ask the user if they want to install extra configurations
read -p "Would you like to install my configs? (y/n): " install_extras
install_extras="${install_extras:-y}" # Default to "y" if no input is provided

if [[ "$install_extras" == "y" || "$install_extras" == "Y" ]]; then
  echo "Extras installation will begin now."

  # Remove existing bashrc and zshrc files
  echo "Removing existing bashrc..."
  rm -rf ~/.bashrc

  # Check if the username is "karna"
  if [ "$(whoami)" != "karna" ]; then
    # Install for non-karna users
    echo "Stowing configurations for non-karna user..."
    stow bashrc BTOP dunst neofetch flameshot gtk-2 gtk-3 Kvantum mpd mpv ncmpcpp newsboat NWG pandoc pavucontrol qt6ct qutebrowser ranger redyt screensaver sxiv Templates themes Thunar xsettingsd zathura

    # Copy essential system files for non-karna users
    sudo cp ~/dotfiles/Extras/Extras/etc/nanorc /etc/nanorc
    sudo cp ~/dotfiles/Extras/Extras/etc/bash.bashrc /etc/bash.bashrc
    sudo cp ~/dotfiles/Extras/Extras/etc/DIR_COLORS /etc/DIR_COLORS
    sudo cp ~/dotfiles/Extras/Extras/etc/environment /etc/environment
    sudo cp ~/dotfiles/Extras/Extras/kunst /usr/bin/kusnt
    sudo cp ~/dotfiles/Extras/Extras/nvim.desktop /usr/share/applications/nvim.desktop

    echo "Extras have been installed" && sleep 1
  else
    # Install for "karna" user
    echo "Stowing configurations for karna..."
    sudo pacman -S zellij
    stow bash_karna BTOP_karna cava dunst face_karna neofetch flameshot gtk-2 gtk-3_karna Kvantum latexmkrc libreoffice mpd_karna mpv_karna myemojis ncmpcpp_karna newsboat_karna nvim NWG octave pandoc pavucontrol qt6ct qutebrowser ranger_karna redyt screenlayout screensaver sxiv Templates Thunar xarchiver xsettingsd zathura zellij

    cargo install taplo-cli --features lsp

    # Copy essential system files for karna user
    sudo cp ~/dotfiles/Extras/Extras/etc/nanorc /etc/nanorc
    sudo cp ~/dotfiles/Extras/Extras/etc/bash.bashrc /etc/bash.bashrc
    sudo cp ~/dotfiles/Extras/Extras/etc/DIR_COLORS /etc/DIR_COLORS
    sudo cp ~/dotfiles/Extras/Extras/etc/environment /etc/environment
    sudo cp ~/dotfiles/Extras/Extras/etc/mpd.conf /etc/mpd.conf
    sudo cp ~/dotfiles/Extras/Extras/nvim.desktop /usr/share/applications/nvim.desktop

    # Install custom tools for karna
    sudo cp ~/dotfiles/Extras/Extras/kunst /usr/bin/kusnt

    echo "Setup kaggle JSON and wakatime files using ccrypt... also read essential_info.md file" && sleep 1
    echo "Extras have been installed for KARNA." && sleep 1
  fi
else
  echo "Extras installation skipped. Proceeding with the setup." && sleep 1
fi

# Final message
clear
echo "All done! Please go through essentials.md before rebooting your system." && sleep 2
