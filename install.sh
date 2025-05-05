#!/bin/env bash
set -euo pipefail

# -------------------------- Colors and Logging --------------------------
BOLD=$(tput bold)
RESET=$(tput sgr0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)

die() {
  echo -e "${BOLD}${RED}ERROR:${RESET} $*" >&2
  exit 1
}

info() {
  echo -e "${BOLD}${BLUE}INFO:${RESET} $*"
}

success() {
  echo -e "${BOLD}${GREEN}SUCCESS:${RESET} $*"
}

warning() {
  echo -e "${BOLD}${CYAN}WARNING:${RESET} $*"
}

# Prompt user with default value handling
prompt() {
  local message="${1:-}"
  local default="${2:-}"
  local input
  read -rp "$message [default: $default]: " input
  echo "${input:-$default}"
}

# Function to check if a symlink points to the correct directory
is_symlink_correct() {
    local target="$1"
    local symlink="$2"
    [ -L "$symlink" ] && [ "$(readlink -f "$symlink")" == "$target" ]
}

stow_with_check() {
    local target="$1"
    local symlink="$2"
    local name="$3"

    if is_symlink_correct "$target" "$symlink"; then
        echo -e "${GREEN}$name configuration is already correctly symlinked. Skipping stow.${RESET}"
    else
        if [ -e "$symlink" ] || [ -L "$symlink" ]; then
            echo -e "${CYAN}$name symlink is incorrect. Moving to $symlink.bak${RESET}"
            mv "$symlink" "$symlink.bak" || echo -e "${RED}Failed to move existing $name to $symlink.bak${RESET}"
        fi
        if stow "$name"; then
            echo -e "${GREEN}Successfully stowed $name configuration (symlink created).${RESET}"
        else
            echo -e "${RED}Failed to stow $name configuration${RESET}"
        fi
    fi
}

# Function to check if waldl is already installed
is_waldl_installed() {
    command -v waldl &>/dev/null
}

# Function to install waldl if not already installed
install_waldl() {
    if is_waldl_installed; then
        echo -e "${GREEN}waldl is already installed. Skipping installation.${RESET}"
    else
        echo -e "${CYAN}Installing waldl...${RESET}"
        cd "$HOME/dotfiles/Extras/Extras/waldl-master" && sudo make install && cd "$HOME/dotfiles" || die "waldl installation failed."
        echo -e "${GREEN}waldl installation successful.${RESET}"
    fi
}

# Function to check if a package is installed
is_installed() {
  pacman -Qi "$1" &>/dev/null || paru -Q "$1" &>/dev/null
}

# Install a package if not already installed
install_package() {
  local package_name=$1
  local display_name=$2
  local command=$3

  if is_installed "$package_name"; then
    success "$display_name ($package_name) is already installed."
  else
    info "Installing $display_name ($package_name)..."
    $command "$package_name"
  fi
}

# -------------------------- Error Handling --------------------------
trap 'die "An unexpected error occurred."' ERR

# Optional: log everything to a file (uncomment if needed)
# exec > >(tee -a ~/dotfiles-install.log) 2>&1

# -------------------------- Checks --------------------------
check_privileges() {
  if [[ $EUID -eq 0 ]]; then
    die "This script should not be run as root. Please run as regular user."
  fi

  if ! sudo -v; then
    die "User does not have sudo privileges or password is incorrect."
  fi
}

# -------------------------- Setup --------------------------
setup_user_dirs() {
  info "Creating standard user directories..."
  mkdir -p ~/Downloads ~/Documents ~/Music ~/Pictures ~/Video ~/Templates
}

configure_pacman() {
  local target_line="#UseSyslog"
  local check_line="ILoveCandy"

  if grep -q "$check_line" /etc/pacman.conf; then
    info "Pacman already configured with candy theme"
    return
  fi

  info "Configuring pacman..."
  sudo sed -i '/^ParallelDownloads/d' /etc/pacman.conf
  sudo sed -i "/$target_line/a ILoveCandy\nParallelDownloads=10\nColor" /etc/pacman.conf
}

system_update() {
  info "Updating package database..."
  sudo pacman -Sy

  info "Upgrading system packages..."
  sudo pacman -Su --noconfirm

  info "Installing Git (required)..."
  sudo pacman -S --needed --noconfirm git dialog
}

clone_or_download_dotfiles() {
  local repo_url="https://gitlab.com/Chaganti-Reddy/dotfiles.git"
  local zip_url="https://gitlab.com/Chaganti-Reddy/dotfiles/-/archive/main/dotfiles-main.zip"
  local target_dir="${HOME}/dotfiles"

  # Check if dotfiles directory already exists
  if [ -d "$target_dir" ]; then
    success "Dotfiles directory already exists: ${target_dir}. Skipping clone/download."
    return 0
  fi

  # Check if username is karna
  if [[ "$(whoami)" != "karna" ]]; then
    info "User is not 'karna'. Downloading dotfiles as zip..."

    # Download the zip file
    wget --progress=bar:force "$zip_url" -O "${HOME}/dotfiles-main.zip" || die "Failed to download dotfiles zip."

    # Unzip the file into the home directory
    unzip -q "${HOME}/dotfiles-main.zip" -d "${HOME}" || die "Failed to unzip dotfiles."

    # Rename the extracted folder to dotfiles
    mv "${HOME}/dotfiles-main" "${target_dir}" || die "Failed to move extracted folder to ${target_dir}"

    # Clean up the zip file
    rm -f "${HOME}/dotfiles-main.zip" || die "Failed to remove downloaded zip."

    success "Dotfiles downloaded and extracted to ${HOME}/dotfiles."
  else
    info "User is 'karna'. Cloning dotfiles repository into ${HOME}/dotfiles..."

    # Clone the repository directly into the home directory
    git clone "$repo_url" "$target_dir" || die "Failed to clone the repository."

    success "Dotfiles successfully cloned to ${target_dir}."
  fi
}

install_aur_helpers() {
  local param="${1:-}"
  local selected_helper=""

  echo ""
  info "========== Install AUR Helper(s) =========="

  if [[ "$param" == "1" || "$param" == "2" ]]; then
    choices="$param"
  else
    # Ensure dialog is installed
    if ! command -v dialog &>/dev/null; then
      info "Installing dialog (required for selection)..."
      sudo pacman -S --needed --noconfirm dialog || die "Failed to install dialog"
    fi

    # Show dialog for selection
    dialog_cmd=(dialog --separate-output --checklist "Select AUR helpers to install:" 12 60 5)
    options=(
      1 "paru (recommended)" on
      2 "yay" off
    )

    choices=$("${dialog_cmd[@]}" "${options[@]}" 2>&1 >/dev/tty) || {
      clear
      warning "No AUR helper selected. Skipping."
      return
    }

    clear
  fi

  for choice in $choices; do
    case "$choice" in
      1)
        selected_helper="paru"
        if command -v paru &>/dev/null; then
          success "paru is already installed."
        else
          info "Installing paru..."
          local aur_dir="${HOME}/Downloads/paru-bin"
          mkdir -p "$aur_dir"
          (
            cd "$aur_dir" || die "Failed to access $aur_dir"
            git clone https://aur.archlinux.org/paru-bin.git || die "Failed to clone paru-bin"
            cd paru-bin || die "Failed to enter paru-bin directory"
            makepkg -si --noconfirm --needed || die "paru build failed"
          )
          rm -rf "$aur_dir"
          success "paru installation complete!"
        fi
        ;;
      2)
        selected_helper="yay"
        if command -v yay &>/dev/null; then
          success "yay is already installed."
        else
          info "Installing yay..."
          local aur_dir="${HOME}/Downloads/yay"
          mkdir -p "$aur_dir"
          (
            cd "$aur_dir" || die "Failed to access $aur_dir"
            git clone https://aur.archlinux.org/yay.git || die "Failed to clone yay"
            cd yay || die "Failed to enter yay directory"
            makepkg -si --noconfirm --needed || die "yay build failed"
          )
          rm -rf "$aur_dir"
          success "yay installation complete!"
        fi
        ;;
      *)
        warning "Unknown selection: $choice"
        ;;
    esac
  done

  cd ~/dotfiles/ || die "Failed to access dotfiles directory"
  echo "Selected AUR helper: $selected_helper"
}

setup_git_info() {
  local response="${1:-}"
  if [[ ! "$response" =~ ^[Yy]$ ]]; then
    response=$(prompt "Would you like to configure Git?" "y")
  fi

  if [[ ! "$response" =~ ^[Yy]$ ]]; then
    warning "Git configuration skipped. Proceeding with the setup."
    return
  fi

  local git_username git_email editor_choice editor

  while true; do
    git_username=$(prompt "Enter your Git username" "")
    [[ -n "$git_username" ]] && break
    warning "Git username cannot be empty. Please try again."
  done

  while true; do
    git_email=$(prompt "Enter your Git email" "")
    if [[ "$git_email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
      break
    fi
    warning "Invalid or empty Git email. Please try again."
  done

  echo -e "\nSelect your preferred editor for Git:"
  echo "1) Vim"
  echo "2) Nano"
  echo "3) VSCode"
  echo "4) Neovim"
  echo "5) None (skip editor configuration)"

  editor_choice=$(prompt "Enter your choice" "1")

  case "$editor_choice" in
    1) editor="vim" ;;
    2) editor="nano" ;;
    3) editor="code" ;;
    4) editor="nvim" ;;
    5) editor="" ;;
    *) warning "Invalid choice. Defaulting to Vim."; editor="vim" ;;
  esac

  git config --global user.name "$git_username"
  git config --global user.email "$git_email"

  if [[ -n "$editor" ]]; then
    git config --global core.editor "$editor"
  fi

  info "Applying additional Git configuration..."

  git config --global core.autocrlf input
  git config --global init.defaultBranch main
  git config --global pull.rebase true
  git config --global credential.helper "cache --timeout=3601"
  git config --global color.ui auto
  git config --global alias.st status
  git config --global alias.co checkout
  git config --global alias.br branch
  git config --global alias.ci commit
  git config --global alias.unstage 'reset HEAD --'
  git config --global log.decorate true
  git config --global push.default simple
  git config --global push.autoSetupRemote true

  info "Git configuration summary:"
  git config --list | grep -E "user.name|user.email|core.editor|init.defaultBranch|alias|push.default"

  success "Git setup complete!"
}

install_dependencies() {
  # Define the package list path
  local packages_file="$HOME/dotfiles/packages.txt"

  # Function to read packages from a file into an array
  read_packages_from_file() {
    local file="$1"
    local packages=()

    while IFS= read -r line || [[ -n "$line" ]]; do
      # Ignore empty lines and comments
      line=$(echo "$line" | sed 's/[[:space:]]*$//')  # Remove trailing spaces
      [[ -z "$line" || "$line" =~ ^# ]] && continue  # Skip empty lines and lines that start with #
      packages+=("$line")
    done < "$file"

    echo "${packages[@]}"
  }

  # Read the selected AUR helper from earlier step (either 'paru' or 'yay')
  local selected_helper="$1"  # Assuming selected_helper is passed as an argument

  # Read the packages from the file into a variable
  all_packages=($(read_packages_from_file "$packages_file"))

  # Initialize an empty list for missing packages
  missing_packages=()

  # Check which packages are already installed
  for package in "${all_packages[@]}"; do
    if ! $selected_helper -Qi "$package" &>/dev/null; then
      missing_packages+=("$package")
    else
      success "$package is already installed."
    fi
  done

  # If there are missing packages, install them
  if [ ${#missing_packages[@]} -gt 0 ]; then
    info "Installing missing packages using $selected_helper..."
    for package in "${missing_packages[@]}"; do
      echo -e "${BOLD}${CYAN}Installing${RESET} $package..."
      $selected_helper -S --noconfirm --needed "$package" || die "Failed to install $package"
    done
    success "All missing packages have been installed."
  else
    success "All packages are already installed."
  fi

  # Update database and mandb
  info "Updating database..."
  sudo updatedb || die "Failed to update database"
  info "Updating man pages..."
  sudo mandb || die "Failed to update man pages"

  # Enable necessary services
  info "Enabling TLP and Bluetooth services..."
  sudo systemctl enable --now tlp || die "Failed to enable TLP service"
  sudo systemctl enable --now bluetooth.service || die "Failed to enable Bluetooth service"

  # Add user to video group for permissions
  info "Adding user to video group..."
  sudo usermod -aG video "$USER" || die "Failed to add user to video group"
  sudo usermod -aG input $USER || die "Failed to add user to input group"

  success "Done with permissions."
  sleep 2
}

install_zsh() {
  info "Setting up Zsh..."

  local install="${1:-}"
  if [[ ! "$install" =~ ^[Yy]$ ]]; then
    install=$(prompt "Would you like to install Zsh and set it as your default shell? (y/n)" "y")
  fi

  if [[ ! "$install" =~ ^[Yy]$ ]]; then
    warning "Zsh installation skipped. Proceeding with the setup."
    return 0
  fi

  info "Installing Zsh and related packages..."
  sudo pacman -S --noconfirm zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting || die "Failed to install Zsh packages."

  info "Changing default shell to Zsh..."
  chsh -s /bin/zsh || die "Failed to change the shell. Try running 'chsh -s /bin/zsh' manually."

  info "Installing Oh My Zsh..."
  cd ~/dotfiles || die "Failed to navigate to ~/dotfiles"
  bash install_zsh.sh || die "Oh My Zsh installation failed."

  info "Removing existing .zshrc..."
  rm -f ~/.zshrc

  local stow_folder="zsh"
  [ "$(whoami)" = "karna" ] && stow_folder="zsh_karna"

  info "Setting up Zsh configuration using Stow ($stow_folder)..."
  stow "$stow_folder" || die "Failed to stow $stow_folder configuration."

  local theme_src="$HOME/dotfiles/Extras/Extras/archcraft-dwm.zsh-theme"
  local theme_dest="$HOME/.oh-my-zsh/themes/archcraft-dwm.zsh-theme"
  if [[ -f "$theme_src" ]]; then
    cp "$theme_src" "$theme_dest"
    info "Custom Zsh theme installed."
  fi

  cd ~/dotfiles || die "Failed to navigate to ~/dotfiles"

  success "Zsh has been installed and set as your default shell."
}

setup_gpg_pass() {
  local response="${1:-}"
  if [[ ! "$response" =~ ^[Yy]$ ]]; then
    response=$(prompt "Do you want to set up GPG and Pass for password management? (y/n)" "y")
  fi

  if [[ "$response" =~ ^[Nn]$ ]]; then
    warning "Skipping GPG and Pass setup."
    sleep 1
    return
  fi

  info "Setting up GPG and Pass..."

  if ! pacman -Q gnupg pass rofi-wayland qrencode pass-import &>/dev/null; then
    info "Installing GPG and Pass..."
    sudo pacman -S --noconfirm gnupg pass qrencode rofi-wayland || die "Failed to install required packages."
    paru -S --noconfirm pass-import || die "Failed to install pass-import from AUR."
  else
    info "Required packages are already installed. Skipping installation."
  fi

  local backup_response
  backup_response=$(prompt "Do you already have a backup of your GPG keys and passwords and just want to import them? (y/n)" "n")

  if [[ "$backup_response" =~ ^[Yy]$ ]]; then
    info "To import your GPG keys and password store, follow these steps:"
    echo "  1. Clone your backup repo: git clone <YOUR_BACKUP_GIT_REPO_URL>"
    echo "  2. Import GPG keys: gpg --import <path_to_backup>/*.gpg"
    echo "  3. Copy password store to ~/.password-store/"
    echo "  4. Set GPG key trust: gpg --edit-key <your-email> → trust"
    echo "  5. Initialize pass: pass init <your-email>"

    warning "Skipping automated setup. Please follow the instructions above."
    sleep 5

    info "Reducing GPG key caching time for better security..."
    echo "default-cache-ttl 150" >> ~/.gnupg/gpg-agent.conf
    echo "max-cache-ttl 150" >> ~/.gnupg/gpg-agent.conf
    gpgconf --kill gpg-agent
    return
  fi

  local name email comment
  name=$(prompt "Enter your full name" "")
  email=$(prompt "Enter your email address" "")
  comment=$(prompt "Enter a comment (optional)" "")

  if gpg --list-keys "$email" &>/dev/null; then
    info "GPG key for $email already exists. Skipping key generation."
  else
    info "Generating a new GPG key..."
    cat > key-config <<EOF
%echo Generating a GPG key
Key-Type: RSA
Key-Length: 4096
Name-Real: $name
Name-Comment: ${comment:-None}
Name-Email: $email
Expire-Date: 0
%commit
%echo Done
EOF
    gpg --batch --full-generate-key key-config || die "Failed to generate GPG key."
    rm -f key-config
  fi

  if pass show test-check &>/dev/null; then
    info "Pass is already initialized. Skipping initialization."
  else
    info "Initializing pass with GPG key linked to $email..."
    pass init "$email" || die "Failed to initialize pass with GPG key."
  fi

  info "Reducing GPG key caching time for better security..."
  echo "default-cache-ttl 150" >> ~/.gnupg/gpg-agent.conf
  echo "max-cache-ttl 150" >> ~/.gnupg/gpg-agent.conf
  gpgconf --kill gpg-agent

  success "GPG and Pass setup completed successfully!"
  sleep 2
}

install_i3() {
  local install="${1:-}"
  if [[ ! "$install" =~ ^[Yy]$ ]]; then
    install=$(prompt "Would you like to install i3 and its dependencies? (y/n)" "y")
  fi

  if [[ ! "$install" =~ ^[Yy]$ ]]; then
    warning "i3 installation skipped. Proceeding with the setup..."
    return
  fi

  info "i3 installation will begin now..."

  local packages=(
    "i3-wm"
    "i3blocks"
    "i3lock"
    "feh"
    "picom"
    "i3status"
    "xss-lock"
    "autotiling"
    "alacritty"
    "kitty"
    "polybar"
  )

  for package in "${packages[@]}"; do
    install_package "$package" "$package" "paru -S --noconfirm --needed"
  done

  stow_with_check "$HOME/dotfiles/i3/.config/i3" "$HOME/.config/i3" "i3"
  stow_with_check "$HOME/dotfiles/rofi/.config/rofi" "$HOME/.config/rofi" "rofi"
  stow_with_check "$HOME/dotfiles/kitty/.config/kitty" "$HOME/.config/kitty" "kitty"
  stow_with_check "$HOME/dotfiles/alacritty/.config/alacritty" "$HOME/.config/alacritty" "alacritty"

  install_waldl

  success "i3 setup complete. Proceeding to next modules..."
  sleep 1
}


install_qtile() {
  local install="${1:-}"

  if [[ ! "$install" =~ ^[Yy]$ ]]; then
    install=$(prompt "Would you like to install Qtile and its dependencies? (y/n)" "y")
  fi

  if [[ ! "$install" =~ ^[Yy]$ ]]; then
    warning "Qtile installation skipped. Proceeding with the setup..."
    return
  fi

  info "Qtile installation will begin now..."

  # Packages to install
  local packages=(
    "qtile"
    "python-dbus-fast"
    "python-gobject"
    "cairo"
    "feh"
    "picom"
    "alacritty"
    "kitty"
    "qtile-extras"
    "python-pulsectl-asyncio"
    "python-mpd2"
    "xdg-desktop-portal-gtk"
  )

  for package in "${packages[@]}"; do
    install_package "$package" "$package" "paru -S --noconfirm --needed"
  done

  # Stow relevant configs
  stow_with_check "$HOME/dotfiles/qtile/.config/qtile" "$HOME/.config/qtile" "qtile"
  stow_with_check "$HOME/dotfiles/alacritty/.config/alacritty" "$HOME/.config/alacritty" "alacritty"
  stow_with_check "$HOME/dotfiles/rofi/.config/rofi" "$HOME/.config/rofi" "rofi"
  stow_with_check "$HOME/dotfiles/kitty/.config/kitty" "$HOME/.config/kitty" "kitty"

  # Install waldl
  install_waldl

  success "Qtile setup complete. Proceeding to next modules..."
  sleep 1
}

install_sway() {
  local install="${1:-}"

  if [[ ! "$install" =~ ^[Yy]$ ]]; then
    install=$(prompt "Would you like to install Sway and its dependencies? (y/n)" "y")
  fi

  if [[ ! "$install" =~ ^[Yy]$ ]]; then
    warning "Sway installation skipped. Proceeding with the setup..."
    return
  fi

  info "Sway installation will begin now..."

  # Packages to install
  local packages=(
    "brightnessctl"
    "grim"
    "slurp"
    "sway"
    "swaybg"
    "sway-contrib"
    "swaylock"
    "swayidle"
    "waybar"
    "xorg-xwayland"
    "rofi-wayland"
    "kitty"
    "xdg-desktop-portal-wlr"
    "xdg-desktop-portal"
    "xdg-desktop-portal-gtk"
    "autotiling"
    "wlroots"
    "wlr-randr"
    "qt5-wayland"
    "qt6-wayland"
    "clipse-bin"
    "bluetui"
    "system-config-printer"
    "chafa"
    "polkit"
    "wl-clipboard"
    "wtype"
    "ydotool"
    "wf-recorder"
    "speech-dispatcher"
    "cmake"
    "meson"
    "cpio"
    "smartmontools"
    "xdg-utils"
  )

  for package in "${packages[@]}"; do
    install_package "$package" "$package" "paru -S --noconfirm --needed"
  done

  # Stow relevant configs
  stow_with_check "$HOME/dotfiles/sway/.config/sway/" "$HOME/.config/sway/" "sway"
  stow_with_check "$HOME/dotfiles/rofi/.config/rofi" "$HOME/.config/rofi" "rofi"
  stow_with_check "$HOME/dotfiles/kitty/.config/kitty" "$HOME/.config/kitty" "kitty"

  # Define source and target using $HOME
  SOURCE="$HOME/.cache/wal/colors-waybar.css"
  TARGET="$HOME/dotfiles/sway/.config/sway/waybar/colors-waybar.css"

  # Remove existing symlink or file if it exists
  [ -L "$TARGET" ] || [ -e "$TARGET" ] && rm -f "$TARGET"

  # Create new symlink
  ln -s "$SOURCE" "$TARGET"

  echo "Symlink created: $TARGET -> $SOURCE"

  # Install waldl
  install_waldl

  success "Sway setup complete. Proceeding to next modules..."
  sleep 1
}


install_hyprland() {
  local install="${1:-}"

  if [[ ! "$install" =~ ^[Yy]$ ]]; then
    install=$(prompt "Would you like to install Hyprland and its dependencies? (y/n)" "y")
  fi

  if [[ ! "$install" =~ ^[Yy]$ ]]; then
    warning "Hyprland installation skipped. Proceeding with the setup..."
    return
  fi

  info "Hyprland installation will begin now..."

  # Packages to install
  local packages=(
    "hyprland"
    "hyprlock"
    "xdg-desktop-portal-hyprland"
    "hyprlang"
    "clipse-bin"
    "hyprland-qtutils"
    "bluetui"
    "hyprpicker"
    "hyprpaper"
    "kitty"
    "system-config-printer"
    "chafa"
    "hypridle"
    "waybar"
    "wl-clipboard"
    "speech-dispatcher"
    "cmake"
    "meson"
    "cpio"
    "grim"
    "slurp"
    "wtype"
    "ydotool"
    "wf-recorder"
    # "wofi"
    "qt5-wayland"
    "qt6-wayland"
    "wlroots"
    "xdg-desktop-portal-wlr"
    "wlr-randr"
    "pyprland"
  )

  for package in "${packages[@]}"; do
    install_package "$package" "$package" "paru -S --noconfirm --needed"
  done

  info "Configuring Hyprland..."

  local stow_folder
  if [[ "$(whoami)" == "karna" ]]; then
    stow_folder="hyprland"
  else
    stow_folder="hyprland_gen"
  fi

  if [[ ! -f "$HOME/.config/hypr/hyprland.conf" ]]; then
    stow_with_check "$HOME/dotfiles/$stow_folder/.config/hypr" "$HOME/.config/hypr" "$stow_folder"
    stow_with_check "$HOME/dotfiles/rofi/.config/rofi" "$HOME/.config/rofi" "rofi"
    stow_with_check "$HOME/dotfiles/kitty/.config/kitty" "$HOME/.config/kitty" "kitty"
    success "Hyprland configuration has been set up."
  else
    warning "Hyprland configuration file already exists. Skipping stow."
  fi

  # Define source and target using $HOME
  SOURCE="$HOME/.cache/wal/colors-waybar.css"
  TARGET="$HOME/dotfiles/$stow_folder/.config/waybar/colors-waybar.css"

  # Remove existing symlink or file if it exists
  [ -L "$TARGET" ] || [ -e "$TARGET" ] && rm -f "$TARGET"

  # Create new symlink
  ln -s "$SOURCE" "$TARGET"

  echo "Symlink created: $TARGET -> $SOURCE"

  install_waldl

  success "Setup is complete. Proceeding to next modules..."
  sleep 2
}

# Define Miniconda installer URL and installer name
MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-py310_24.3.0-0-Linux-x86_64.sh"
INSTALLER_NAME="Miniconda3.sh"

install_miniconda() {
  info "Setting up Miniconda..."

  local install_choice="${1:-}"  # Optional positional parameter

  if [[ "$install_choice" =~ ^[Yy]$ ]]; then
    install_choice="y"
  else
    install_choice=$(prompt "Would you like to install Miniconda?" "y")
  fi

  if [[ ! "$install_choice" =~ ^[Yy]$ ]]; then
    warning "Miniconda installation skipped. Proceeding with the setup."
    return
  fi

  info "Miniconda installation will begin now..."

  # Download Miniconda installer
  info "Downloading Miniconda installer..."
  wget -q --show-progress -O "$INSTALLER_NAME" "$MINICONDA_URL"

  # Run the installer
  info "Running the Miniconda installer..."
  bash "$INSTALLER_NAME" -b -p "$HOME/miniconda" # Install silently in the $HOME/miniconda directory

  # Remove the installer after installation
  info "Cleaning up installer files..."
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
    die "Neither .bashrc nor .zshrc found. Exiting setup."
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
      info "Adding Conda initialization to $config..."
      echo "$CONDA_BLOCK" >> "$config"
    else
      success "Conda initialization block already present in $config."
    fi
  done

  # Now execute the Conda initialization code directly to initialize Conda
  if [[ "$SHELL" == *"bash"* ]]; then
    # Bash initialization
    eval "$($HOME/miniconda/bin/conda shell.bash hook)"
    info "Evaluating $HOME/miniconda/bin/conda shell.bash hook"
  elif [[ "$SHELL" == *"zsh"* ]]; then
    # Zsh initialization
    eval "$($HOME/miniconda/bin/conda shell.zsh hook)"
    info "Evaluating $HOME/miniconda/bin/conda shell.zsh hook"
  else
    die "Unsupported shell detected. Unable to initialize Conda."
  fi

  # Verify Conda and Python installation
  info "Verifying Miniconda installation..."
  conda --version
  python --version

  success "Miniconda installation and initialization completed successfully."
  info "Python Version: $(python --version)"
  info "Conda Version: $(conda --version)"
  info "Installation path: $HOME/miniconda"

  sleep 3
  success "Miniconda setup is complete. Proceeding with the script..."
}

install_kvm() {
  info "Setting up KVM..."

  local install_choice="${1:-}"

  if [[ "$install_choice" =~ ^[Yy]$ ]]; then
    install_choice="y"
  else
    install_choice=$(prompt "Would you like to install KVM QEMU Virtual Machine?" "y")
  fi

  if [[ ! "$install_choice" =~ ^[Yy]$ ]]; then
    warning "KVM installation skipped. Proceeding with the setup."
    return
  fi

  if systemctl is-active --quiet libvirtd && command -v virsh &>/dev/null && virsh list --all &>/dev/null; then
    success "KVM and libvirt appear to be already set up. Skipping reinstallation."
    return
  fi

  info "KVM installation will begin now..."

  info "Checking for hardware virtualization support..."
  if ! grep -qE '(vmx|svm)' /proc/cpuinfo; then
    die "Error: Your CPU does not support virtualization or it's disabled in BIOS. Please enable virtualization in BIOS settings."
  fi

  info "Installing KVM and required packages..."
  if ! sudo pacman -S --noconfirm --needed \
    qemu-full qemu-img libvirt virt-install virt-manager virt-viewer \
    spice-vdagent edk2-ovmf swtpm guestfs-tools libosinfo tuned \
    dnsmasq vde2 bridge-utils openbsd-netcat dmidecode iptables libguestfs; then
    die "Failed to install required packages. Aborting."
  fi

  info "Enabling and starting libvirt service..."
  sudo systemctl enable --now libvirtd.service || die "Failed to enable/start libvirtd.service"

  info "Adding user '$USER' to the libvirt group..."
  sudo usermod -aG libvirt "$USER" || warning "Could not add user to libvirt group"

  CONFIG_FILE="/etc/libvirt/libvirtd.conf"
  info "Configuring $CONFIG_FILE permissions..."
  sudo sed -i \
    -e 's/^#\?unix_sock_group.*/unix_sock_group = "libvirt"/' \
    -e 's/^#\?unix_sock_ro_perms.*/unix_sock_ro_perms = "0770"/' \
    -e 's/^#\?unix_sock_rw_perms.*/unix_sock_rw_perms = "0770"/' \
    "$CONFIG_FILE" || warning "Failed to update $CONFIG_FILE"

  sudo systemctl restart libvirtd.service || warning "Could not restart libvirtd.service"

  info "Configuring libvirt default network to autostart..."
  sudo virsh net-autostart default || warning "Failed to autostart default network"

  info "Checking and enabling nested virtualization..."
  cpu_vendor=$(lscpu | grep -i 'Vendor ID' | awk '{print $3}')
  if [[ "$cpu_vendor" == "GenuineIntel" ]]; then
    sudo modprobe -r kvm_intel 2>/dev/null
    sudo modprobe kvm_intel nested=1
    nested_status=$(cat /sys/module/kvm_intel/parameters/nested)
  elif [[ "$cpu_vendor" == "AuthenticAMD" ]]; then
    sudo modprobe -r kvm_amd 2>/dev/null
    sudo modprobe kvm_amd nested=1
    nested_status=$(cat /sys/module/kvm_amd/parameters/nested)
  else
    warning "Unknown CPU vendor. Skipping nested virtualization config."
    nested_status="unknown"
  fi
  info "Nested virtualization status: $nested_status"

  info "Verifying KVM modules are loaded..."
  lsmod | grep kvm || warning "KVM modules not found in lsmod output"

  # Optional: Check for UEFI firmware presence
  if [[ ! -f /usr/share/edk2-ovmf/x64/OVMF_CODE.fd ]]; then
    warning "OVMF UEFI firmware not found. UEFI VMs may not work properly."
  fi

  success "KVM installation completed successfully."

  info "Documentation: https://docs.getutm.app/guest-support/linux/"
  warning "You must log out and log back in for group changes to take effect."
  warning "Consider rebooting to apply all changes."
}

install_browser() {
  # Check if dialog is installed
  if ! command -v dialog &>/dev/null; then
    warning "dialog is required but not installed. Installing it now..."
    sudo pacman -S --noconfirm dialog || { error "Failed to install dialog. Exiting."; exit 1; }
  fi

  # If arguments are passed, install directly
  if [ $# -gt 0 ]; then
    info "Direct installation of the provided browsers..."
    browsers=("$@")  # Store the arguments in an array
  else
    info "Setting up browsers..." 
    sleep 1

    # Create checklist dialog
    dialog_cmd=(dialog --separate-output --checklist "Select browsers to install (Space to select, Enter to confirm):" 20 60 15)
    options=(
      1 "Zen-Browser" off
      2 "Firefox" off
      3 "Chromium" off
      4 "Vivaldi" off
      5 "qutebrowser" off
      6 "Brave (Default)" on
    )

    # Show dialog and get selections
    choices=$("${dialog_cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    clear  # Clear the dialog screen immediately after selection

    # If user canceled or made no selection, use default (Brave)
    if [ $? -ne 0 ] || [ -z "$choices" ]; then
      choices="6"  # Default to Brave if no selection
      warning "No selection made, defaulting to Brave."
    fi

    browsers=($choices)
  fi

  # Process the selected browsers
  for browser in "${browsers[@]}"; do
    case $browser in
      1)
        if is_installed "zen-browser-bin"; then
          info "Zen-Browser is already installed."
        else
          info "Installing Zen-Browser..."
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
          info "Firefox is already installed."
        else
          info "Installing Firefox..."
          sudo pacman -S --noconfirm firefox
          pip install --index-url https://test.pypi.org/simple/ pywalfox==2.8.0rc1
          pywalfox install
          curl -sSLf https://github.com/aclap-dev/vdhcoapp/releases/latest/download/install.sh | bash
        fi
        ;;
      3)
        if is_installed "chromium"; then
          info "Chromium is already installed."
        else
          info "Installing Chromium..."
          sudo pacman -S --noconfirm chromium
        fi
        ;;
      4)
        if is_installed "vivaldi"; then
          info "Vivaldi is already installed."
        else
          info "Installing Vivaldi..."
          paru -S --noconfirm vivaldi
        fi
        ;;
      5)
        if is_installed "qutebrowser"; then
          info "qutebrowser is already installed."
        else
          info "Installing qutebrowser..."
          sudo pacman -S --noconfirm qutebrowser
        fi
        ;;
      6)
        if is_installed "brave-bin" && command -v nativefier &>/dev/null; then
          info "Both Brave and nativefier are already installed."
        else
          if ! is_installed "brave-bin"; then
            info "Installing Brave..."
            paru -S --noconfirm brave-bin
          fi

          if ! command -v nativefier &>/dev/null; then
            info "Installing nativefier..."
            sudo npm install -g nativefier
          fi
        fi
        ;;
      *)
        die "Invalid choice: $browser"
        ;;
    esac
  done

  success "Browser installation complete."
}

install_torrent() {
    # Check if dialog is installed
    if ! command -v dialog &>/dev/null; then
      warning "dialog is required but not installed. Installing it now..."
      sudo pacman -S --noconfirm dialog || { error "Failed to install dialog. Exiting."; exit 1; }
    fi

    # If arguments are passed, install directly
    if [ $# -gt 0 ]; then
        info "Direct installation of the provided torrent applications..."
        apps=("$@")  # Store the arguments in an array
    else
        info "Setting up torrent applications, remote desktop tools, and VPNs..." 
        sleep 1

        # Create checklist dialog for selecting applications
        dialog_cmd=(dialog --separate-output --checklist "Select the applications you want to install (Space to select, Enter to confirm):" 20 60 15)
        options=(
            1 "torrent-cli (webtorrent-cli, webtorrent-mpv-hook, peerflix)" off
            2 "qBittorrent (Recommended)" off
            3 "Transmission" off
            4 "Remmina (Remote Desktop Client)" off
            5 "VNC Server" off
            6 "TeamViewer (Recommended)" off
            7 "AnyDesk (Remote Desktop)" off
            8 "xrdp (Remote Desktop Protocol)" off
            9 "OpenVPN (VPN)" off
            10 "WireGuard (VPN)" off
            11 "Varia (Download Manager on ARIA2)" off
            12 "Warehouse (Flatpak App Manager)" off
            13 "Gromit-MPX (On Screen Drawing Tool)" off
        )

        # Show dialog and get selections
        choices=$("${dialog_cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        clear  # Clear the dialog screen immediately after selection

        # If user canceled or made no selection, exit
        if [ $? -ne 0 ] || [ -z "$choices" ]; then
            success "No applications selected. Exiting."
            sleep 1
            return 
        fi

       apps=($choices) 
    fi

    # Process selected applications and install them
    for app in "${apps[@]}"; do
        case $app in
            1)
                if is_installed "webtorrent-cli" && is_installed "webtorrent-mpv-hook" && is_installed "peerflix"; then
                    info "torrent-cli is already installed."
                else
                    info "Installing torrent-cli (webtorrent-cli, webtorrent-mpv-hook, peerflix)..."
                    paru -S --noconfirm --needed webtorrent-cli webtorrent-mpv-hook peerflix
                fi
                ;;
            2)
                if is_installed "qbittorrent"; then
                    info "qBittorrent is already installed."
                else
                    info "Installing qBittorrent..."
                    sudo pacman -S --noconfirm qbittorrent
                fi
                ;;
            3)
                if is_installed "transmission-qt"; then
                    info "Transmission is already installed."
                else
                    info "Installing Transmission..."
                    sudo pacman -S --noconfirm transmission-qt
                fi
                ;;
            4)
                if is_installed "remmina"; then
                    info "Remmina (Remote Desktop Client) is already installed."
                else
                    info "Installing Remmina (Remote Desktop Client)..."
                    sudo pacman -S --noconfirm remmina
                fi
                ;;
            5)
                if is_installed "tigervnc"; then
                    info "VNC Server is already installed."
                else
                    info "Installing VNC Server..."
                    sudo pacman -S --noconfirm tigervnc
                fi
                ;;
            6)
                if is_installed "teamviewer"; then
                    info "TeamViewer is already installed."
                else
                    info "Installing TeamViewer..."
                    sudo pacman -S --noconfirm teamviewer
                fi
                ;;
            7)
                if is_installed "anydesk"; then
                    info "AnyDesk is already installed."
                else
                    info "Installing AnyDesk..."
                    sudo pacman -S --noconfirm anydesk
                fi
                ;;
            8)
                if is_installed "xrdp"; then
                    info "xrdp (Remote Desktop Protocol) is already installed."
                else
                    info "Installing xrdp (Remote Desktop Protocol)..."
                    sudo pacman -S --noconfirm xrdp
                fi
                ;;
            9)
                if is_installed "openvpn"; then
                    info "OpenVPN is already installed."
                else
                    info "Installing OpenVPN..."
                    sudo pacman -S --noconfirm openvpn
                fi
                ;;
            10)
                if is_installed "wireguard-tools"; then
                    info "WireGuard is already installed."
                else
                    info "Installing WireGuard..."
                    sudo pacman -S --noconfirm wireguard-tools
                fi
                ;;
            11)
                info "Installing varia..."
                flatpak install flathub io.github.giantpinkrobots.varia
                ;;
            12)
                info "Installing warehouse..."
                flatpak install flathub io.github.flattool.Warehouse
                ;;
            13)
                if is_installed "gromit-mpx"; then
                    info "Gromit-MPX is already installed."
                else
                    info "Installing Gromit-MPX..."
                    paru -S --noconfirm --needed gromit-mpx
                fi
                ;;
            *)
                die "Invalid choice: $app"
                ;;
        esac
        success "Selected applications have been installed." && sleep 1
    done
}

install_multiple_packages() {
  local packages=("$@")
  for package in "${packages[@]}"; do
    install_package "$package" "$package" "paru -S --noconfirm --needed" || { echo -e "${RED}Installation of $package failed${RESET}"; exit 1; }
  done
}

install_dev_tools() {
  # Check if dialog is installed
  if ! command -v dialog &>/dev/null; then
    error "dialog is required but not installed. Please install it first."
    warning "Run: sudo pacman -S dialog"
    exit 1
  fi

  # If arguments are passed, install directly
  if [ $# -gt 0 ]; then
    info "Direct installation of the provided tools..."
    tools=("$@")  # Store the arguments in an array
  else
    info "Setting up development tools, office tools, communication tools, and multimedia tools..." && sleep 1

    # Create checklist dialog
    dialog_cmd=(dialog --separate-output --checklist "Select tools to install (Space to select, Enter to confirm):" 30 80 30)
    options=(
      1 "Visual Studio Code" off
      2 "GitHub Desktop" off
      3 "Docker" off
      4 "Docker Desktop" off
      5 "Kubernetes" off
      6 "LaTeX" off
      7 "Discord" off
      8 "Obsidian" off
      9 "Telegram" off
      10 "LibreOffice" off
      11 "OnlyOffice" off
      12 "Skype" off
      13 "Slack" off
      14 "Zoom" off
      15 "Blender" off
      16 "Octave" off
      17 "OBS Studio" off
      18 "Inkscape" off
      19 "GIMP" off
      20 "VLC" off
      21 "Audacity" off
      22 "Krita" off
      23 "Shotcut" off
      24 "Steam" off
      25 "Minecraft" off
      26 "YouTUI (via cargo)" off
      27 "YTerMusic (via cargo)" off
      28 "Todoist CLI" off
      29 "Geary" off
      30 "KeepassXC" off
    )

    # Show dialog and get selections
    choices=$("${dialog_cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    clear

    # If user canceled or made no selection
    if [ $? -ne 0 ] || [ -z "$choices" ]; then
      warning "No tools selected for installation. Skipping."
      sleep 1
      return
    fi

    tools=($choices)  # If no args are passed, use the selections from dialog
  fi

  # Process the selected tools
  for app in "${tools[@]}"; do
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
          info "Installing kubectl..."
          curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
          sudo install -m 0755 kubectl /usr/local/bin/kubectl
          rm kubectl
        else
          success "kubectl is already installed."
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
      *) error "Invalid choice: $app" ;;
    esac
    success "Finished processing: $app"
    sleep 1
  done
}

install_extra_tools() {
  # Check if dialog is installed
  if ! command -v dialog &>/dev/null; then
    error "dialog is required but not installed. Please install it first."
    warning "Run: sudo pacman -S dialog"
    exit 1
  fi

  # If arguments are passed, install directly
  if [ $# -gt 0 ]; then
    info "Direct installation of the provided extra tools..."
    tools=("$@")  # Store the arguments in an array
  else
    info "Setting up additional tools and packages..." && sleep 1

    # Create checklist dialog
    dialog_cmd=(dialog --separate-output --checklist "Select extra tools to install (Space to select, Enter to confirm):" 20 60 15)
    options=(
      1 "Ani-Cli" off
      2 "Ani-Cli-PY" off
      3 "ytfzf" off
      4 "Zathura" off
      5 "Evince" off
      6 "Okular" off
      7 "Foxit-Reader" off
      8 "Master-PDF-Editor" off
      9 "MuPDF" off
    )

    # Show dialog and get selections
    choices=$("${dialog_cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    clear  # Clear the dialog screen immediately after selection

    # If user canceled or made no selection
    if [ $? -ne 0 ] || [ -z "$choices" ]; then
      warning "No extra tools selected for installation. Continuing..." && sleep 1
      return
    fi

    tools=($choices)  # If no args are passed, use the selections from dialog
  fi

  # Process the selected tools
  for app in "${tools[@]}"; do
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
        error "Invalid choice: $app"
        ;;
    esac
  done
  info "Processing for the selected extra tool(s) completed." && sleep 1
}

install_fonts() {
  info "Setting up Fonts..." && sleep 1

  local FONTS_DIR="$HOME/.local/share/fonts"
  local FONTS_SUBDIR="my-fonts-main"
  local FONTS_ZIP="$FONTS_DIR/my-fonts.zip"
  local FONTS_URL="https://gitlab.com/chaganti-reddy1/my-fonts/-/archive/main/my-fonts-main.zip"

  # Check if fonts already exist
  if [ -d "$FONTS_DIR/$FONTS_SUBDIR" ]; then
    success "Fonts directory already exists. Skipping installation..."
    sleep 1
    return
  fi

  # Create fonts directory if it doesn't exist
  warning "Creating fonts directory..."
  mkdir -p "$FONTS_DIR"

  # Download the zip file
  info "Downloading fonts..."
  if curl -L -o "$FONTS_ZIP" "$FONTS_URL"; then
    info "Extracting fonts..."
    unzip -q "$FONTS_ZIP" -d "$FONTS_DIR"

    info "Cleaning up zip file..."
    rm "$FONTS_ZIP"

    success "Fonts have been installed successfully."
    sleep 2
  else
    die "Failed to download fonts from $FONTS_URL"
    exit 1
  fi
}

install_dwm() {
  info "Setting up dwm..."

  local install_choice="${1:-}"  # Optional positional parameter

  if [[ "$install_choice" =~ ^[Yy]$ ]]; then
    install_choice="y"
  else
    install_choice=$(prompt "Would you like to install dwm (Dynamic Window Manager)?" "y")
  fi

  if [[ "$install_choice" =~ ^[Yy]$ ]]; then
    info "Starting dwm installation..."

    # Check if dwm and configs already exist
    if command -v dwm &>/dev/null && \
       [ -d ~/.config/dwm ] && \
       [ -d ~/.config/slstatus ] && \
       [ -d ~/.config/st ] && \
       [ -d ~/.config/dmenu ]; then
      success "dwm and its configurations are already installed. Skipping installation."
      return
    fi

    # Stow configuration folders
    info "Stowing dwm-related dotfiles..."
    cd ~/dotfiles || die "Failed to access ~/dotfiles"
    stow suckless
    stow DWMScripts

    # Build and install suckless components
    [[ -d ~/.config/dwm ]]     && { info "Installing dwm..."; cd ~/.config/dwm && sudo make clean install; }
    [[ -d ~/.config/slstatus ]] && { info "Installing slstatus..."; cd ~/.config/slstatus && sudo make clean install; }
    [[ -d ~/.config/st ]]      && { info "Installing st..."; cd ~/.config/st && sudo make install; }
    [[ -d ~/.config/dmenu ]]   && { info "Installing dmenu..."; cd ~/.config/dmenu && sudo make install; }

    # Install extra tool waldl
    install_waldl

    # Install compositor
    install_package "xcompmgr" "Xcompmgr (compositor)" "sudo pacman -S --noconfirm --needed"
    install_package "libxft" "libxft (font support)" "sudo pacman -S --noconfirm --needed"
    install_package "libxinerama" "libxinerama (Xinerama support)" "sudo pacman -S --noconfirm --needed"

    # Setup desktop session file
    if [ ! -f /usr/share/xsessions/dwm.desktop ]; then
      info "Setting up dwm session desktop file..."
      sudo mkdir -p /usr/share/xsessions/
      sudo cp ~/dotfiles/Extras/Extras/usr/share/xsessions/dwm.desktop /usr/share/xsessions || die "Failed to copy dwm.desktop"
    fi

    success "dwm has been successfully installed and configured."
    sleep 1
  else
    warning "dwm installation skipped."
    sleep 1
  fi
}


install_bspwm() {
  info "Setting up BSPWM..."

  local install_choice="${1:-}"  # Optional positional parameter

  if [[ "$install_choice" =~ ^[Yy]$ ]]; then
    install_choice="y"
  else
    install_choice=$(prompt "Would you like to install bspwm?" "y")
  fi

  if [[ "$install_choice" =~ ^[Yy]$ ]]; then
    info "Starting bspwm installation..."

    # List of required packages
    local bspwm_packages=(
      "bspwm" "sxhkd" "pastel" "alacritty" "polybar" "xfce4-power-manager"
      "xsettingsd" "xorg-xsetroot" "wmname" "xcolor" "yad" "pulsemixer"
      "maim" "feh" "ksuperkey" "betterlockscreen" "light" "networkmanager-dmenu-git"
    )

    # Install packages
    for pkg in "${bspwm_packages[@]}"; do
      install_package "$pkg" "$pkg" "paru -S --noconfirm --needed"
    done

    # Stow config directories with check
    info "Setting up bspwm-related configurations..."
    cd "$HOME/dotfiles" || die "Could not enter dotfiles directory"

    stow_with_check "$HOME/dotfiles/feh" "$HOME/.fehbg" "feh"
    stow_with_check "$HOME/dotfiles/bspwm" "$HOME/.config/bspwm" "bspwm"
    stow_with_check "$HOME/dotfiles/networkmanager-dmenu" "$HOME/.config/networkmanager-dmenu" "networkmanager-dmenu"
    stow_with_check "$HOME/dotfiles/rofi" "$HOME/.config/rofi" "rofi"

    # Install waldl (extra tool)
    install_waldl

    success "bspwm has been successfully installed and configured."
    sleep 1
  else
    warning "bspwm installation skipped."
    sleep 1
  fi
}

install_ollama() {
  info "Setting up Ollama..."

  local install_choice="${1:-}"  # Optional positional parameter, default to empty if not passed

  if [[ "$install_choice" =~ ^[Yy]$ ]]; then
    install_choice="y"
  else
    install_choice=$(prompt "Would you like to install Ollama (a tool to run large language models locally)?" "y")
  fi

  if [[ "$install_choice" =~ ^[Yy]$ ]]; then
    info "Ollama installation will begin now."

    if ! command -v ollama &>/dev/null; then
      info "Ollama not found. Installing..."

      curl -fsSL https://ollama.com/install.sh | sh || die "Failed to install Ollama."

      success "Ollama has been installed. You can now use it to run local large language models."
      sleep 2
      clear

      warning "Now you will see a lot of text but don't panic."
      warning "Just type 'y' or 'n' to choose models for installation as their names appear."
      sleep 7
      clear

      # Start ollama in background
      ollama serve & disown
      sleep 1

      # Ask user to install various models
      local models=("deepseek-r1:8b" "deepseek-coder:6.7b" "llama3:8b" "mistral" "zephyr" "llava:7b")

      for model in "${models[@]}"; do
        clear
        local model_choice
        model_choice=$(prompt "Would you like to install the model '$model'?" "y")

        if [[ "$model_choice" =~ ^[Yy]$ ]]; then
          info "Installing model '$model'..."
          ollama pull "$model" || warning "Failed to pull model '$model'"
          success "Model '$model' installed."
          sleep 1
        else
          warning "Model '$model' installation skipped."
          sleep 1
        fi
      done

      clear
      success "Ollama setup completed."
      sleep 2
    else
      success "Ollama is already installed on your system."
      sleep 1
    fi
  else
    warning "Ollama installation skipped. Proceeding with the setup."
    sleep 1
  fi
}

install_pip_packages() {
  info "Setting up PIP Packages..."

  # Safely handle $1, default to an empty string if $1 is not set
  local install_choice
  install_choice="${1:-}"  # Use $1 if provided, otherwise default to an empty string

  if [[ -n "$install_choice" && "$install_choice" =~ ^[Yy]$ ]]; then
    install_choice="y"
  else
    install_choice=$(prompt "Would you like to install my PIP packages?" "y")
  fi

  if [[ "$install_choice" =~ ^[Yy]$ ]]; then
    info "Installing PIP packages..."

    # Determine pip install command based on whether conda is available
    local pip_cmd
    if command -v conda &>/dev/null; then
      pip_cmd="pip install"
      info "Conda detected. Using regular pip install."
    else
      pip_cmd="pip install --break-system-packages"
      warning "Conda not found. Using pip with --break-system-packages (Arch-safe)."
    fi

    # List of packages to install
    local pip_packages=(
      "pynvim" "numpy" "pandas" "matplotlib" "seaborn" "scikit-learn" "jupyterlab"
      "ipykernel" "ipywidgets" "tensorflow" "python-prctl" "inotify-simple" "psutil"
      "opencv-python" "keras" "mov-cli-youtube" "mov-cli" "mov-cli-test" "otaku-watcher"
      "film-central" "daemon" "jupyterlab_wakatime" "pygobject" "spotdl" "beautifulsoup4"
      "requests" "flask" "streamlit" "pywal16" "zxcvbn" "pyaml" "my_cookies" "codeium-jupyter"
      "pymupdf" "tk-tools" "ruff-lsp" "python-lsp-server" "semgrep" "transformers" "spacy"
      "nltk" "sentencepiece" "ultralytics" "roboflow" "pipreqs" "feedparser" "pypdf2" "fuzzywuzzy"
    )

    # Install each package if it's not already installed
    for package in "${pip_packages[@]}"; do
      if ! pip show "$package" &>/dev/null; then
        info "Installing $package..."
        $pip_cmd "$package" || warning "Failed to install $package"
      else
        success "$package is already installed."
      fi
    done

    # Install PyTorch (CPU version)
    if ! pip show "torch" &>/dev/null; then
      info "Installing PyTorch (CPU version)..."
      $pip_cmd torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu || warning "Failed to install PyTorch"
    else
      success "PyTorch is already installed."
    fi

    success "PIP packages installation completed."
    sleep 1
  else
    warning "PIP packages installation skipped. Proceeding with the setup."
    sleep 1
  fi
}

install_grub_theme() {
  info "Setting up GRUB theme..."

  local install_choice="${1:-}"  # Optional positional parameter, default to empty if not passed

  if [[ "$install_choice" =~ ^[Yy]$ ]]; then
    install_choice="y"
  else
    install_choice=$(prompt "Would you like to install a GRUB theme?" "y")
  fi

  if [[ "$install_choice" =~ ^[Yy]$ ]]; then
    info "GRUB theme setup will begin now."

    local theme_src="$HOME/dotfiles/Extras/Extras/boot/grub/themes/SekiroShadow/"
    local theme_dest="/boot/grub/themes/SekiroShadow"

    if [[ -d "$theme_src" ]]; then
      info "Copying GRUB theme files..."
      sudo cp -r "$theme_src" /boot/grub/themes/
      success "GRUB theme files copied successfully."
    else
      error "GRUB theme files not found at $theme_src. Skipping theme setup."
      return 1
    fi

    # Add GRUB theme path if not already configured
    if ! grep -q 'GRUB_THEME="/boot/grub/themes/SekiroShadow/theme.txt"' /etc/default/grub; then
      echo 'GRUB_THEME="/boot/grub/themes/SekiroShadow/theme.txt"' | sudo tee -a /etc/default/grub >/dev/null
      info "GRUB theme path added to /etc/default/grub."
    else
      info "GRUB theme already configured."
    fi

    # Ensure os-prober is enabled
    if ! grep -q 'GRUB_DISABLE_OS_PROBER="false"' /etc/default/grub; then
      echo 'GRUB_DISABLE_OS_PROBER="false"' | sudo tee -a /etc/default/grub >/dev/null
      info "os-prober enabled in GRUB configuration."
    else
      info "os-prober is already enabled."
    fi

    # Regenerate GRUB config
    info "Regenerating GRUB configuration..."
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    success "GRUB theme setup is complete, and GRUB config has been updated."
    sleep 1
  else
    warning "GRUB theme setup skipped. Proceeding with the setup."
    sleep 1
  fi
}

install_display_manager() {
  info "Display/Login Manager Setup"

  local install_dm="${1:-}"  # Optional positional parameter, default to empty if not passed
  local choice

  if [[ "$install_dm" =~ ^[Yy]$ ]]; then
    install_dm="y"
    choice="$2"  # Optional second argument for non-interactive choice
  else
    install_dm=$(prompt "Would you like to install a Display/Login Manager?" "y")
  fi

  if [[ "$install_dm" =~ ^[Yy]$ ]]; then
    # If choice is not provided as an argument, prompt for it
    if [[ -z "$choice" ]]; then
      info "Choose a Display Manager:"
      echo "1) SDDM (Simple Desktop Display Manager - GUI)"
      echo "2) LY (Simple TUI Login Manager - Terminal-based)"
      echo "3) LightDM (LightDM Display Manager - XFCE-based)"
      read -rp "Enter your choice (1/2/3): " choice
    fi

    case "$choice" in
      1)
        info "Installing SDDM..."
        sudo pacman -S --noconfirm sddm

        info "Enabling SDDM to start at boot..."
        sudo systemctl enable sddm.service

        local sddm_theme_src="$HOME/dotfiles/Extras/Extras/usr/share/sddm/themes/simple-sddm/"
        if [[ -d "$sddm_theme_src" ]]; then
          sudo cp -r "$sddm_theme_src" /usr/share/sddm/themes
          success "SDDM theme files copied successfully."
        else
          warning "SDDM theme files not found. Skipping theme setup."
        fi

        if [[ -f "$HOME/dotfiles/Extras/Extras/etc/sddm.conf" ]]; then
          sudo cp "$HOME/dotfiles/Extras/Extras/etc/sddm.conf" /etc/sddm.conf
          success "SDDM configuration file copied successfully."
        else
          warning "SDDM configuration file not found. Skipping configuration setup."
        fi

        success "SDDM has been installed and enabled to start at boot."
        ;;
      
      2)
        info "Installing LY..."
        paru -S --noconfirm --needed ly

        info "Enabling LY to start at boot..."
        sudo systemctl enable ly.service

        if [[ -f "$HOME/dotfiles/Extras/Extras/etc/ly/config.ini" ]]; then
          sudo cp "$HOME/dotfiles/Extras/Extras/etc/ly/config.ini" /etc/ly/config.ini
          success "LY configuration file copied successfully."
        else
          warning "LY configuration file not found. Skipping configuration setup."
        fi

        success "LY has been installed and enabled to start at boot."
        ;;

      3)
        info "Installing LightDM..."
        paru -S --noconfirm --needed lightdm lightdm-gtk-greeter

        info "Enabling LightDM to start at boot..."
        sudo systemctl enable lightdm.service

        success "LightDM has been installed and enabled to start at boot."
        ;;

      *)
        error "Invalid choice. No display manager installed."
        ;;
    esac
    sleep 1
  else
    warning "Display Manager installation skipped. Proceeding with the setup."
    sleep 1
  fi
}


download_wallpapers() {
  info "Downloading Wallpapers..."

  local answer="${1:-}"  # Optional positional parameter

  if [[ "$answer" =~ ^[Yy]$ ]]; then
    download_wallpapers="y"
  else
    download_wallpapers=$(prompt "Would you like to download wallpapers?" "y")
  fi

  if [[ "$download_wallpapers" =~ ^[Yy]$ ]]; then
    if [[ ! -d "$HOME/Pictures/pix" ]]; then
      warning "Pix folder not found in ~/Pictures. Downloading wallpapers..."

      cd ~/Downloads/ || return
      curl -L -o wall.zip https://gitlab.com/chaganti-reddy1/wallpapers/-/archive/main/wallpapers-main.zip
      unzip wall.zip
      cd wallpapers-main || return

      if pacman -Q bspwm &>/dev/null; then
        info "Moving wallpapers to /usr/share/backgrounds/..."
        sudo mkdir -p /usr/share/backgrounds/
        sudo mv wall/* /usr/share/backgrounds/
        success "Wallpapers moved to /usr/share/backgrounds/."
      fi

      info "Moving pix folder to ~/Pictures/..."
      mv pix ~/Pictures/

      info "Cleaning up temporary files..."
      cd ~/Downloads/
      rm -rf wallpapers-main wall.zip

      cd ~/dotfiles/ || return

      success "Wallpapers have been downloaded and installed successfully."
      sleep 1
    else
      warning "Pix folder already exists in ~/Pictures/, skipping download."
      sleep 1
    fi
  else
    warning "Wallpapers download skipped. Proceeding with the setup."
    sleep 1
  fi
}

install_extras() {
  local install_themes_icons="${1:-}"  # Default to empty for prompt if not provided
  local install_extras_config="${2:-}"  # Default to empty for prompt if not provided

  # -------------------------- Themes and Icons --------------------------
  if [[ -z "$install_themes_icons" ]]; then
    install_themes_icons=$(prompt "Would you like to install themes and icons?" "y")
  fi

  if [[ "$install_themes_icons" =~ ^[Yy]$ ]]; then
    info "Installing themes and icons..."

  cd ~/Downloads || return
  curl -L -o archcraft-themes.zip https://gitlab.com/chaganti-reddy1/archcraft-themes/-/archive/main/archcraft-themes-main.zip
  unzip archcraft-themes.zip
  rm archcraft-themes.zip

  mkdir -p ~/.icons ~/.themes

  local extracted_dir="archcraft-themes-main"
  if [[ ! -d "$extracted_dir/themes" ]]; then
    error "'themes' directory not found after extraction."
    return 1
  fi
  if [[ ! -d "$extracted_dir/icons" ]]; then
    error "'icons' directory not found after extraction."
    return 1
  fi

  # Move themes (skip existing)
  for theme_dir in "$extracted_dir/themes/"*; do
    if [[ -d "$theme_dir" ]]; then
      local theme_name
      theme_name=$(basename "$theme_dir")
      if [[ -e "$HOME/.themes/$theme_name" ]]; then
        echo "$theme_name already exists in ~/.themes. Skipping."
      else
        mv "$theme_dir" "$HOME/.themes/"
      fi
    fi
  done

  # Move icons (skip existing)
  for icon_dir in "$extracted_dir/icons/"*; do
    if [[ -d "$icon_dir" ]]; then
      local icon_name
      icon_name=$(basename "$icon_dir")
      if [[ -e "$HOME/.icons/$icon_name" ]]; then
        echo "$icon_name already exists in ~/.icons. Skipping."
      else
        mv "$icon_dir" "$HOME/.icons/"
      fi
    fi
  done

  cd ~/Downloads || return
  rm -rf "$extracted_dir"
  cd ~/dotfiles || return

    # Copy Dunst icons
    sudo cp -r ~/dotfiles/Extras/Extras/dunst/ /usr/share/icons/

    # Override Flatpak GTK Themes and Icons
    sudo flatpak override --filesystem=$HOME/.themes
    sudo flatpak override --filesystem=$HOME/.icons
    sudo flatpak override --env=GTK_THEME=Kripton
    sudo flatpak override --env=ICON_THEME=Luv-Folders-Dark

    success "Themes and Icons have been installed."
  else
    warning "Themes and Icons installation skipped."
  fi

  # -------------------------- Extra Configurations --------------------------
  if [[ -z "$install_extras_config" ]]; then
    install_extras_config=$(prompt "Would you like to install extra configurations?" "y")
  fi

  if [[ "$install_extras_config" =~ ^[Yy]$ ]]; then
    info "Installing extra configurations..."
    
    # Check if the current user is "karna"
    if [ "$(whoami)" == "karna" ]; then
      info "Configuring for user Karna..."

      # Remove existing configurations for Karna
      rm -rf ~/.bashrc
      stow bash_karna BTOP_karna cava dunst face_karna neofetch flameshot gtk-2 gtk-3_karna Kvantum latexmkrc libreoffice mpd_karna mpv_karna myemojis ncmpcpp_karna newsboat_karna nvim NWG octave pandoc pavucontrol qt6ct qutebrowser yazi redyt screenlayout screensaver sxiv Templates Thunar xarchiver xsettingsd zathura kitty enchant vim

      # Copy essential system files for karna user
      sudo cp ~/dotfiles/Extras/Extras/etc/nanorc /etc/nanorc
      sudo cp ~/dotfiles/Extras/Extras/etc/bash.bashrc /etc/bash.bashrc
      sudo cp ~/dotfiles/Extras/Extras/etc/DIR_COLORS /etc/DIR_COLORS
      sudo cp ~/dotfiles/Extras/Extras/etc/environment /etc/environment
      sudo cp ~/dotfiles/Extras/Extras/etc/mpd.conf /etc/mpd.conf
      sudo cp ~/dotfiles/Extras/Extras/nvim.desktop /usr/share/applications/nvim.desktop

      # Install custom tools for karna
      sudo rm -rf /usr/bin/kunst && curl -L git.io/raw-kunst > kunst && chmod +x kunst && sudo mv kunst /usr/bin/

      cargo install leetcode-cli

      sudo npm install -g @mermaid-js/mermaid-cli
      go install github.com/maaslalani/typer@latest
      cp ~/dotfiles/Extras/Extras/.wakatime.cfg.cpt ~/
      warning "decrypting your wakatime API key ..."
      sleep 1
      ccrypt -d ~/.wakatime.cfg.cpt

      success "Extras have been installed for Karna."
    else
      info "Configuring for non-Karna user..."

      # Remove existing configurations for non-Karna users
      rm -rf ~/.bashrc
      stow bashrc BTOP dunst neofetch flameshot gtk-2 gtk-3 Kvantum mpd mpv ncmpcpp newsboat NWG pandoc pavucontrol qt6ct qutebrowser ranger redyt screensaver sxiv Templates themes Thunar xsettingsd zathura

      # Ask user to confirm stowing nvim_gen
      read -p "Would you like to stow nvim_gen? (y/n): " stow_nvim_gen
      stow_nvim_gen="${stow_nvim_gen:-y}" # Default to "y" if no input is provided

      if [[ "$stow_nvim_gen" == "y" || "$stow_nvim_gen" == "Y" ]]; then
        stow nvim_gen
      fi 

      # Additional system files for non-Karna users
      sudo cp ~/dotfiles/Extras/Extras/etc/nanorc /etc/nanorc
      sudo cp ~/dotfiles/Extras/Extras/etc/bash.bashrc /etc/bash.bashrc
      sudo cp ~/dotfiles/Extras/Extras/etc/DIR_COLORS /etc/DIR_COLORS
      sudo cp ~/dotfiles/Extras/Extras/etc/environment /etc/environment
      sudo cp ~/dotfiles/Extras/Extras/kunst /usr/bin/kusnt
      sudo cp ~/dotfiles/Extras/Extras/nvim.desktop /usr/share/applications/nvim.desktop

      success "Extras have been installed."
    fi
  else
    warning "Extras installation skipped."
  fi
}

# -------------------------- Main Program --------------------------
clear
echo -e "\n${BOLD}${CYAN}==> Arch Linux Dotfiles Setup${RESET}\n"
sleep 1

if [[ "$(whoami)" == "karna" ]]; then
  # check_privileges
  # setup_user_dirs
  # configure_pacman
  # system_update
  # clone_or_download_dotfiles
  # install_aur_helpers 1
  # setup_git_info y
  # install_dependencies "${selected_helper:-paru}"
  # install_zsh y
  # setup_gpg_pass y
  # # install_i3
  # # install_qtile y
  install_sway y
  # install_hyprland y
  # # install_miniconda
  # install_kvm y
  # install_browser 5 6
  # install_torrent 1 13
  # install_dev_tools 3 6 7 9 10 16 
  # install_extra_tools 1 2 3 4
  # install_fonts
  # install_dwm y
  # # install_bspwm
  # install_ollama y
  # install_pip_packages y 
  # install_grub_theme y
  # install_display_manager y 1
  # download_wallpapers
  # install_extras y y
else
  check_privileges
  setup_user_dirs
  configure_pacman
  system_update
  clone_or_download_dotfiles
  install_aur_helpers
  setup_git_info
  install_dependencies
  install_zsh
  setup_gpg_pass
  install_i3
  install_qtile
  install_hyprland
  install_miniconda
  install_kvm
  install_browser
  install_torrent
  install_dev_tools
  install_extra_tools
  install_fonts
  install_dwm
  install_bspwm
  install_ollama
  install_pip_packages
  install_grub_theme
  install_display_manager
  download_wallpapers
fi

echo ""
success "Initial system setup complete!"
info "You can now continue with your dotfiles installation."

