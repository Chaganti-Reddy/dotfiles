#!/bin/env bash
set -euo pipefail

# -------------------------- Colors and Logging --------------------------
BOLD=$(tput bold)
RESET=$(tput sgr0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
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

# -------------------------- Error Handling --------------------------
trap 'die "An unexpected error occurred."' ERR

# Optional: log everything to a file (uncomment if needed)
# exec > >(tee -a ~/dotfiles-install.log) 2>&1

## INITIALSTUFF
mkdir -p ~/Downloads ~/Documents ~/Music ~/Pictures ~/Video ~/Templates ~/Pictures/Screenshots ~/.mpd

target_line="#UseSyslog"
check_line="ILoveCandy"

# sudo sed -i '/^ParallelDownloads/d' /etc/pacman.conf
# sudo sed -i "/$target_line/a ILoveCandy\nParallelDownloads=10\nColor" /etc/pacman.conf

## PARU INSTALLATION
# cd ~/Downloads
# sudo pacman -Syyu --noconfirm git
# git clone https://aur.archlinux.org/paru-bin.git
# cd paru-bin
# makepkg -si
# cd ~/Downloads
# rm -rf paru-bin
# cd ~/dotfiles

## SYSTEM STUFF
# paru -S --noconfirm bash-completion tlp tlp-rdw git openssh curl wget system-config-printer base-devel intel-ucode bash-language-server btop fastfetch bat exa fd ripgrep fzf stow stylua tar tree time unrar unzip bluez bluez-utils brightnessctl xfsprogs ntfs-3g clang gcc clipnotify inotify-tools psutils yakuake e2fsprogs efibootmgr gc git-lfs gstreamer jq screenkey maim lazygit lolcat sxiv shellcheck net-tools numlockx prettier progress zip rsync trash-cli pandoc python-pywal glow xarchiver man-db man-pages ncdu python-pip nwg-look zbar os-prober pamixer parallel shfmt tesseract tesseract-data-eng python-prctl vscode-css-languageserver ffmpegthumbnailer lua-language-server bmon playerctl rmpc mpd mpv mpc poppler poppler-glib gnome-disk-utility gparted pavucontrol yad timeshift gnu-free-fonts go hugo hunspell hunspell-en_us imagemagick ueberzugpp luacheck mlocate translate-shell jdk-openjdk meld blueman newsboat  dart-sass  speedtest-cli lynx atool figlet luarocks network-manager-applet glfw alsa-firmware pipewire pipewire-audio pipewire-alsa pipewire-pulse wireplumber sof-firmware alsa-ucm-conf viewnior qalculate-gtk pyright python-black vscode-html-languageserver typescript-language-server mdformat ydotool ccls jedi-language-server wakatime flatpak ghostscript qpdf mupdf-tools openssl dbus sqlite hspell nuspell dictd cargo xmlstarlet lua51 gdb yq dos2unix 7zip perl-image-exiftool python-psutil preload ttf-ms-fonts didyoumean-bin arch-wiki-docs sysstat lazydocker-bin gopls gopls gomodifytags gotests gore graphviz python-pyflakes python-isort python-pipenv python-nose python-pytest tidy stylelint js-beautify cpptools-debug-bin dialog python-watchdog advcpmv maven speech-dispatcher python-lsp-server system-config-printer python-plyer taplo-cli reflector

# sudo systemctl enable --now tlp.service
# sudo systemctl enable --now bluetooth.service
# sudo updatedb
# sudo mandb
# sudo usermod -aG video "$USER"
# sudo usermod -aG input $USER
#
# ## GIT && ZSH STUFF
# sudo pacman -S zsh  zsh-completions zsh-autosuggestions zsh-syntax-highlighting zoxide

# git_username="Chaganti-Reddy"
# git_email="chagantivenkataramireddy4@gmail.com"
# editor="nvim"
# git config --global user.name "$git_username"
# git config --global user.email "$git_email"
# git config --global core.editor "$editor"
# git config --global core.autocrlf input
# git config --global init.defaultBranch main
# git config --global pull.rebase true
# git config --global credential.helper "cache --timeout=3601"
# git config --global color.ui auto
# git config --global alias.st status
# git config --global alias.co checkout
# git config --global alias.br branch
# git config --global alias.ci commit
# git config --global alias.unstage 'reset HEAD --'
# git config --global log.decorate true
# git config --global push.default simple
# git config --global push.autoSetupRemote true
#
# git config --list | grep -E "user.name|user.email|core.editor|init.defaultBranch|alias|push.default"
#
# echo "Git setup complete!"

# chsh -s /bin/zsh
# cd ~/dotfiles
# bash install_zsh.sh
# rm -f ~/.zshrc
#
# stow_folder="zsh"
# [ "$(whoami)" = "karna" ] && stow_folder="zsh_karna"
# stow "$stow_folder"
# theme_src="$HOME/dotfiles/Extras/Extras/archcraft-dwm.zsh-theme"
# theme_dest="$HOME/.oh-my-zsh/themes/archcraft-dwm.zsh-theme"
#
# if [[ -f "$theme_src" ]]; then
#     cp "$theme_src" "$theme_dest"
#     echo "Custom Zsh theme installed."
# fi
#
# cd ~/dotfiles
#
# ## NODEJS
# curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

## VIM && NEOVIM && EMACS
# paru -S --noconfirm vim neovim html-xml-utils aspell emacs tree-sitter-cli tree-sitter-bash tree-sitter-rust

## PREFESSIONAL STUFF
# paru -S visual-studio-code-bin discord telegram-desktop-bin  libreoffice-fresh texlive-bin texlive-meta texlive-latex tex-fmt-bin perl-yaml-tiny perl-file-homedir perl-unicode-linebreak docker
# paru -S obs-studio wlrobs-hg

# sudo systemctl enable docker.service
# sudo usermod -aG docker "$USER"

## BROWSER && TORRENT STUFF
# paru -S --noconfirm firefox aria2 python-adblock qutebrowser dnsmasq webtorrent-cli webtorrent-mpv-hook peerflix
# sudo npm install -g nativefier bash-language-server
# curl -sSLf https://github.com/aclap-dev/vdhcoapp/releases/latest/download/install.sh | bash

## NAUTILUS STUFF
# paru -S gvfs gvfs-afc gvfs-google gvfs-goa gvfs-gphoto2 gvfs-mtp gvfs-nfs gvfs-onedrive gvfs-smb tumbler thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman thunar-vcs-plugin

## GPG && ENCRYPTION STUFF
# paru -S --noconfirm pass gnupg ccrypt git-remote-gcrypt qrencode

# echo "default-cache-ttl 150" >>~/.gnupg/gpg-agent.conf
# echo "max-cache-ttl 150" >>~/.gnupg/gpg-agent.conf
# gpgconf --kill gpg-agent

## THEMING STUFF
# paru -S whitesur-cursor-theme-git --noconfirm

## ANIME && YT STUFF
# paru -S fastanime yt-dlp-git ani-cli-git ani-skip-git

## FONTS STUFF
# paru -S adobe-source-code-pro-fonts noto-fonts noto-fonts-cjk  noto-fonts-emoji ttf-hack ttf-jetbrains-mono ttf-ubuntu-font-family ttf-ubuntu-mono-nerd ttf-ubuntu-nerd ttf-opensans ttf-dejavu-nerd ttf-firacode-nerd otf-droid-nerd ttf-cascadia-code-nerd ttf-opensans ttf-hack-nerd ttf-ibmplex-mono-nerd ttf-jetbrains-mono-nerd ttf-ubuntu-mono-nerd ttf-roboto-mono-nerd otf-apple-fonts  ttf-material-design-icons-webfont ttf-iosevka-nerd ttf-iosevkaterm-nerd --noconfirm

# install_fonts() {
#     info "Setting up Fonts..." && sleep 1
#
#     local FONTS_DIR="$HOME/.local/share/fonts"
#     local FONTS_SUBDIR="my-fonts-main"
#     local FONTS_ZIP="$FONTS_DIR/my-fonts.zip"
#     local FONTS_URL="https://gitlab.com/chaganti-reddy1/my-fonts/-/archive/main/my-fonts-main.zip"
#
#     # Check if fonts already exist
#     if [ -d "$FONTS_DIR/$FONTS_SUBDIR" ]; then
#         success "Fonts directory already exists. Skipping installation..."
#         sleep 1
#         return
#     fi
#
#     # Create fonts directory if it doesn't exist
#     warning "Creating fonts directory..."
#     mkdir -p "$FONTS_DIR"
#
#     # Download the zip file
#     info "Downloading fonts..."
#     if curl -L -o "$FONTS_ZIP" "$FONTS_URL"; then
#         info "Extracting fonts..."
#         unzip -q "$FONTS_ZIP" -d "$FONTS_DIR"
#
#         info "Cleaning up zip file..."
#         rm "$FONTS_ZIP"
#
#         success "Fonts have been installed successfully."
#         sleep 2
#     else
#         die "Failed to download fonts from $FONTS_URL"
#         exit 1
#     fi
# }

## PDF STUFF
# paru -S zathura zathura-pdf-mupdf zathura-djvu zathura-ps zathura-cb
# cd ~/dotfiles/Extras/Extras/Zathura-Pywal-master/ || return
# ./install.sh
# cd ~/dotfiles/ || return
# sudo pacman -S okular --noconfirm

## INSTALL HYPRLAND && SETUP
# paru -S rofi-wayland rofi-emoji rofi-calc dunst udiskie hyprlang kitty yazi hyprland hyprlock xdg-desktop-portal-hyprland cliphist hyprland-qtutils hyprpicker hyprpaper system-config-printer chafa hypridle waybar wl-clipboard speech-dispatcher cmake meson cpio grim slurp wtype wf-recorder qt5-wayland qt6-wayland xdg-desktop-portal-wlr wlr-randr pyprland wofi wlogout youtube-music-bin avizo hyprsunset sunsetr-bin --noconfirm

# cd ~/dotfiles || return
# sudo cp -r ~/dotfiles/Extras/Extras/dunst/ /usr/share/icons/
# sudo flatpak override --filesystem=$HOME/.themes
# sudo flatpak override --filesystem=$HOME/.icons
# stow hyprland waybar rofi

## MINICONDA INSTALLATION STUFF

MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-py310_24.3.0-0-Linux-x86_64.sh"
INSTALLER_NAME="Miniconda3.sh"

install_miniconda() {
    info "Setting up Miniconda..."

    source ~/.bashrc
    # Check if conda is already installed
    if command -v conda &>/dev/null; then
        success "Conda is already installed at $(command -v conda). Skipping installation."
        return
    fi

    local install_choice="${1:-}" # Optional positional parameter

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
            echo "$CONDA_BLOCK" >>"$config"
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

    source ~/.bashrc

    success "Miniconda installation and initialization completed successfully."
    info "Python Version: $(python --version)"
    info "Conda Version: $(conda --version)"
    info "Installation path: $HOME/miniconda"

    sleep 3
    success "Miniconda setup is complete. Proceeding with the script..."
}

## QEMU && VIRTUALIZATION STUFF
# info "KVM installation will begin now..."
#
# info "Checking for hardware virtualization support..."
# if ! grep -qE '(vmx|svm)' /proc/cpuinfo; then
#     die "Error: Your CPU does not support virtualization or it's disabled in BIOS. Please enable virtualization in BIOS settings."
# fi
#
# info "Installing KVM and required packages..."
# if ! sudo pacman -S --noconfirm --needed \
#     qemu-full qemu-img libvirt virt-install virt-manager virt-viewer \
#     spice-vdagent edk2-ovmf swtpm guestfs-tools libosinfo tuned \
#     dnsmasq vde2 bridge-utils openbsd-netcat dmidecode iptables libguestfs; then
#     die "Failed to install required packages. Aborting."
# fi
#
# info "Enabling and starting libvirt service..."
# sudo systemctl enable --now libvirtd.service || die "Failed to enable/start libvirtd.service"
#
# info "Adding user '$USER' to the libvirt group..."
# sudo usermod -aG libvirt "$USER" || warning "Could not add user to libvirt group"
#
# CONFIG_FILE="/etc/libvirt/libvirtd.conf"
# info "Configuring $CONFIG_FILE permissions..."
# sudo sed -i \
#     -e 's/^#\?unix_sock_group.*/unix_sock_group = "libvirt"/' \
#     -e 's/^#\?unix_sock_ro_perms.*/unix_sock_ro_perms = "0770"/' \
#     -e 's/^#\?unix_sock_rw_perms.*/unix_sock_rw_perms = "0770"/' \
#     "$CONFIG_FILE" || warning "Failed to update $CONFIG_FILE"
#
# sudo systemctl restart libvirtd.service || warning "Could not restart libvirtd.service"
#
# info "Configuring libvirt default network to autostart..."
# sudo virsh net-autostart default || warning "Failed to autostart default network"
#
# info "Checking and enabling nested virtualization..."
# cpu_vendor=$(lscpu | grep -i 'Vendor ID' | awk '{print $3}')
# if [[ "$cpu_vendor" == "GenuineIntel" ]]; then
#     sudo modprobe -r kvm_intel 2>/dev/null
#     sudo modprobe kvm_intel nested=1
#     nested_status=$(cat /sys/module/kvm_intel/parameters/nested)
# elif [[ "$cpu_vendor" == "AuthenticAMD" ]]; then
#     sudo modprobe -r kvm_amd 2>/dev/null
#     sudo modprobe kvm_amd nested=1
#     nested_status=$(cat /sys/module/kvm_amd/parameters/nested)
# else
#     warning "Unknown CPU vendor. Skipping nested virtualization config."
#     nested_status="unknown"
# fi
# info "Nested virtualization status: $nested_status"
#
# info "Verifying KVM modules are loaded..."
# lsmod | grep kvm || warning "KVM modules not found in lsmod output"
#
# # Optional: Check for UEFI firmware presence
# if [[ ! -f /usr/share/edk2-ovmf/x64/OVMF_CODE.4m.fd ]]; then
#     warning "OVMF UEFI firmware not found. UEFI VMs may not work properly."
# fi
#
# success "KVM installation completed successfully."
#
# info "Documentation: https://docs.getutm.app/guest-support/linux/"
# warning "You must log out and log back in for group changes to take effect."
# warning "Consider rebooting to apply all changes."

## OLLAMA STUFF
# curl -fsSL https://ollama.com/install.sh -o ollama_install.sh
# chmod +x ollama_install.sh
# VERSION_ID=rolling bash ollama_install.sh
# rm ollama_install.sh

install_pip_packages() {
    info "Setting up PIP Packages..."

    # Safely handle $1, default to an empty string if $1 is not set
    local install_choice
    install_choice="${1:-}" # Use $1 if provided, otherwise default to an empty string

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
            "ipykernel" "ipywidgets" "python-prctl" "inotify-simple" "psutil" "libclang"
            "opencv-python" "keras" "mov-cli-youtube" "mov-cli" "mov-cli-test" "otaku-watcher"
            "film-central" "daemon" "jupyterlab_wakatime" "pygobject" "spotdl" "beautifulsoup4"
            "requests" "flask" "streamlit" "pywal16" "zxcvbn" "pyaml" "my_cookies" "codeium-jupyter"
            "pymupdf" "tk-tools" "ruff-lsp" "python-lsp-server" "semgrep" "transformers" "spacy"
            "nltk" "sentencepiece" "ultralytics" "roboflow" "pipreqs" "feedparser" "pypdf2" "fuzzywuzzy" "tensorflow" "sentence-transformers" "langchain-ollama" "pymupdf"
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

    local install_choice="${1:-}" # Optional positional parameter, default to empty if not passed

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

## SDDM STUFF
# sddm_theme_src="$HOME/dotfiles/Extras/Extras/usr/share/sddm/themes/simple-sddm/"
# if [[ -d "$sddm_theme_src" ]]; then
#     sudo cp -r "$sddm_theme_src" /usr/share/sddm/themes
#     success "SDDM theme files copied successfully."
# else
#     warning "SDDM theme files not found. Skipping theme setup."
# fi
#
# sudo cp ~/dotfiles/Extras/Extras/etc/sddm.conf /etc/sddm.conf

#####################################################################

# Check if the current user is "karna"
# if [ "$(whoami)" == "karna" ]; then
#     info "Configuring for user Karna..."
#
#     # Remove existing configurations for Karna
#     rm -rf ~/.bashrc
#     stow bash_karna BTOP_karna dunst face_karna neofetch latexmkrc libreoffice mpd_karna mpv_karna myemojis rmpc newsboat_karna nvim NWG octave pandoc pavucontrol qutebrowser yazi screenlayout sxiv Templates xarchiver zathura kitty enchant vim Okular fastanime
#
#     # Copy essential system files for karna user
#     sudo cp ~/dotfiles/Extras/Extras/etc/nanorc /etc/nanorc
#     sudo cp ~/dotfiles/Extras/Extras/etc/bash.bashrc /etc/bash.bashrc
#     sudo cp ~/dotfiles/Extras/Extras/etc/DIR_COLORS /etc/DIR_COLORS
#     sudo cp ~/dotfiles/Extras/Extras/etc/environment /etc/environment
#     sudo cp ~/dotfiles/Extras/Extras/etc/mpd.conf /etc/mpd.conf
#     sudo cp ~/dotfiles/Extras/Extras/nvim.desktop /usr/share/applications/nvim.desktop
#
#     # to work proper context menu for kde  applications apart from kde
#     mkdir $HOME/.config/menus/
#     curl -L https://raw.githubusercontent.com/KDE/plasma-workspace/master/menu/desktop/plasma-applications.menu -o $HOME/.config/menus/applications.menu
#
#     cp ~/dotfiles/Extras/Extras/.wakatime.cfg.cpt ~/
#     warning "decrypting your wakatime API key ..."
#     sleep 1
#     ccrypt -d ~/.wakatime.cfg.cpt
#
#     success "Extras have been installed for Karna."
# else
#     info "Configuring for non-Karna user..."
#
#     # Remove existing configurations for non-Karna users
#     rm -rf ~/.bashrc
#     stow bashrc BTOP dunst neofetch flameshot gtk-2 gtk-3 Kvantum mpd mpv rmpc newsboat NWG pandoc pavucontrol qt6ct qutebrowser ranger redyt sxiv Templates themes Thunar xsettingsd zathura
#
#     # Ask user to confirm stowing nvim_gen
#     read -p "Would you like to stow nvim_gen? (y/n): " stow_nvim_gen
#     stow_nvim_gen="${stow_nvim_gen:-y}" # Default to "y" if no input is provided
#
#     if [[ "$stow_nvim_gen" == "y" || "$stow_nvim_gen" == "Y" ]]; then
#         stow nvim_gen
#     fi
#
#     # Additional system files for non-Karna users
#     sudo cp ~/dotfiles/Extras/Extras/etc/nanorc /etc/nanorc
#     sudo cp ~/dotfiles/Extras/Extras/etc/bash.bashrc /etc/bash.bashrc
#     sudo cp ~/dotfiles/Extras/Extras/etc/DIR_COLORS /etc/DIR_COLORS
#     sudo cp ~/dotfiles/Extras/Extras/etc/environment /etc/environment
#     sudo cp ~/dotfiles/Extras/Extras/kunst /usr/bin/kusnt
#     sudo cp ~/dotfiles/Extras/Extras/nvim.desktop /usr/share/applications/nvim.desktop
#
#     success "Extras have been installed."
# fi

# install_grub_theme
# install_miniconda
# install_pip_packages
# install_waldl
