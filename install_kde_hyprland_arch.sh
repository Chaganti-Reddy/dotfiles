#!/bin/env bash
set -u
set -o pipefail

# -------------------------- CONFIGURATION --------------------------
LOG_FILE="$HOME/.cache/dotfiles-install.log"
CHECKPOINT_DIR="$HOME/.cache/setup_checkpoints"
DOTFILES_DIR="$HOME/dotfiles"

mkdir -p "$CHECKPOINT_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

# -------------------------- COLORS & UTILS --------------------------
BOLD=$(tput bold)
RESET=$(tput sgr0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)

exec > >(tee -a "$LOG_FILE") 2>&1

die() {
    echo -e "${BOLD}${RED}ERROR:${RESET} $*" >&2
    exit 1
}
info() { echo -e "${BOLD}${BLUE}INFO:${RESET} $*"; }
success() { echo -e "${BOLD}${GREEN}SUCCESS:${RESET} $*"; }
warning() { echo -e "${BOLD}${CYAN}WARNING:${RESET} $*"; }

prompt() {
    local message="${1:-}"
    local default="${2:-}"
    local input
    read -rp "$message [default: $default]: " input
    echo "${input:-$default}"
}

# -------------------------- CHECKPOINT SYSTEM --------------------------
# Usage: run_task "Task Name" function_name [args...]
run_task() {
    local task_name="$1"
    local task_id
    task_id=$(echo "$task_name" | tr -c '[:alnum:]' '_')
    shift

    if [ -f "$CHECKPOINT_DIR/$task_id" ]; then
        success "Skipping '$task_name' (Already Completed)."
        return 0
    fi

    echo -e "\n${BOLD}${CYAN}>>> RUNNING: $task_name${RESET}"

    # Run the command passed as argument
    "$@"
    local status=$?

    if [ $status -eq 0 ]; then
        touch "$CHECKPOINT_DIR/$task_id"
        success "'$task_name' done."
    else
        die "'$task_name' FAILED. Fix the error and re-run to resume."
    fi
}

MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-py311_24.11.1-0-Linux-x86_64.sh"
INSTALLER_NAME="Miniconda3.sh"

install_miniconda() {
    info "Setting up Miniconda..."

    source ~/.bashrc
    # Check if conda is already installed
    if command -v conda &>/dev/null; then
        success "Conda is already installed at $(command -v conda). Skipping installation."
        return
    fi

    local install_choice="${1:-}"

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

    info "Running the Miniconda installer..."
    bash "$INSTALLER_NAME" -b -u -p "$HOME/miniconda"

    info "Cleaning up installer files..."
    rm "$INSTALLER_NAME"

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

install_pip_packages() {
    info "Setting up PIP Packages..."

    local install_choice
    install_choice="${1:-}"

    if [[ -n "$install_choice" && "$install_choice" =~ ^[Yy]$ ]]; then
        install_choice="y"
    else
        install_choice=$(prompt "Would you like to install my PIP packages?" "y")
    fi

    if [[ "$install_choice" =~ ^[Yy]$ ]]; then
        if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
            info "Conda is active (Env: $CONDA_DEFAULT_ENV)."
        elif [ -f "$HOME/miniconda/etc/profile.d/conda.sh" ]; then
            info "Activating Conda base..."
            source "$HOME/miniconda/etc/profile.d/conda.sh"
            conda activate base || {
                warning "Failed to activate Conda. Skipping."
                return 0
            }
        else
            warning "Conda not found. Skipping to protect system Python."
            return 0
        fi

        local has_gpu=false
        # Check for nvidia-smi or lspci looking for nvidia
        if command -v nvidia-smi &>/dev/null; then
            has_gpu=true
            info "NVIDIA GPU detected via nvidia-smi."
        elif lspci 2>/dev/null | grep -i "nvidia" &>/dev/null; then
            has_gpu=true
            info "NVIDIA GPU detected via lspci."
        else
            info "No NVIDIA GPU detected. defaulting to CPU-optimized modes."
        fi

        info "Installing standard PIP packages..."
        local pip_packages=(
            "pynvim" "numpy" "pandas" "matplotlib" "seaborn" "scikit-learn" "jupyterlab"
            "ipykernel" "ipywidgets" "python-prctl" "inotify-simple" "psutil" "libclang"
            "opencv-python" "keras" "mov-cli-youtube" "mov-cli" "mov-cli-test" "otaku-watcher"
            "film-central" "daemon" "jupyterlab_wakatime" "pygobject" "spotdl" "beautifulsoup4"
            "requests" "flask" "streamlit" "pywal16" "zxcvbn" "pyaml" "my_cookies" "codeium-jupyter"
            "pymupdf" "tk-tools" "ruff-lsp" "python-lsp-server" "semgrep" "transformers" "spacy"
            "nltk" "sentencepiece" "ultralytics" "roboflow" "pipreqs" "feedparser" "pypdf2"
            "fuzzywuzzy" "sentence-transformers" "langchain-ollama" "viu-media[standard]"
        )

        # Smart Tensorflow Selection
        if [ "$has_gpu" = true ]; then
            # 'tensorflow[and-cuda]' ensures GPU libraries are downloaded
            pip_packages+=("tensorflow[and-cuda]")
        else
            # Standard tensorflow works fine for CPU too
            pip_packages+=("tensorflow")
        fi

        # Batch Install Logic
        local packages_to_install=()
        for package in "${pip_packages[@]}"; do
            local clean_name="${package%%[*}" # Remove brackets for checking
            if ! pip show "$clean_name" &>/dev/null; then
                packages_to_install+=("$package")
            fi
        done

        if [ ${#packages_to_install[@]} -gt 0 ]; then
            info "Installing ${#packages_to_install[@]} packages..."
            pip install "${packages_to_install[@]}" || warning "Some packages failed."
        fi

        if ! pip show "torch" &>/dev/null; then
            if [ "$has_gpu" = true ]; then
                info "Installing PyTorch (GPU/CUDA version)..."
                # This installs the standard version (Support for CPU + GPU) ~2.5GB
                pip install torch torchvision torchaudio
            else
                info "Installing PyTorch (CPU-Only version)..."
                # This explicitly forces the small CPU-only binaries ~200MB
                pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
            fi
        else
            success "PyTorch is already installed."
        fi

        success "PIP packages installation completed."
    else
        warning "PIP installation skipped."
    fi
    return 0
}

install_grub_theme() {
    info "Setting up GRUB theme..."

    local install_choice="${1:-}"

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
        unzip -q -o "$FONTS_ZIP" -d "$FONTS_DIR"

        info "Cleaning up zip file..."
        rm "$FONTS_ZIP"

        success "Fonts have been installed successfully."
        sleep 2
    else
        die "Failed to download fonts from $FONTS_URL"
        exit 1
    fi
}

install_themes() {
    sudo npm i -g bash-language-server
    # Themes
    cd ~/Downloads
    curl -L -o archcraft.zip https://gitlab.com/chaganti-reddy1/archcraft-themes/-/archive/main/archcraft-themes-main.zip
    unzip -q archcraft.zip
    mkdir -p ~/.icons ~/.themes
    mv archcraft-themes-main/themes/* ~/.themes/
    mv archcraft-themes-main/icons/* ~/.icons/
    rm -rf archcraft.zip archcraft-themes-main
    cd ~/dotfiles
}

install_waldl() {
    if command -v waldl &>/dev/null; then
        echo -e "${GREEN}waldl is already installed. Skipping installation.${RESET}"
    else
        echo -e "${CYAN}Installing waldl...${RESET}"
        cd "$HOME/dotfiles/Extras/Extras/waldl-master" && sudo make install && cd "$HOME/dotfiles" || die "waldl installation failed."
        echo -e "${GREEN}waldl installation successful.${RESET}"
    fi
}

step_prep_folders() {
    mkdir -p ~/Downloads ~/Documents ~/Music ~/Pictures ~/Video ~/Templates ~/Pictures/Screenshots ~/.mpd
}

step_pacman_config() {
    if ! grep -q "ILoveCandy" /etc/pacman.conf; then
        sudo sed -i '/^ParallelDownloads/d' /etc/pacman.conf
        sudo sed -i "/#UseSyslog/a ILoveCandy\nParallelDownloads=10\nColor" /etc/pacman.conf
    fi
}

step_install_paru() {
    if command -v paru &>/dev/null; then return 0; fi
    cd ~/Downloads || return 1
    sudo pacman -Syyu --noconfirm git base-devel
    rm -rf paru
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    rm -rf paru
    cd "$DOTFILES_DIR"
}

step_system_base() {
    local pkgs=(bash-completion tlp tlp-rdw git openssh curl wget system-config-printer base-devel intel-ucode bash-language-server btop fastfetch bat exa fd ripgrep fzf stow stylua tar tree time unrar unzip bluez bluez-utils brightnessctl xfsprogs ntfs-3g clang gcc clipnotify inotify-tools psutils yakuake e2fsprogs efibootmgr gc git-lfs gstreamer jq screenkey maim lazygit lolcat sxiv shellcheck net-tools numlockx prettier progress zip rsync trash-cli pandoc python-pywal glow xarchiver man-db man-pages ncdu python-pip nwg-look zbar os-prober pamixer parallel shfmt tesseract tesseract-data-eng python-prctl vscode-css-languageserver ffmpegthumbnailer lua-language-server bmon playerctl rmpc mpd mpv mpc poppler poppler-glib gnome-disk-utility gparted pavucontrol yad timeshift gnu-free-fonts go hugo hunspell hunspell-en_us imagemagick ueberzugpp luacheck mlocate translate-shell jdk-openjdk meld blueman newsboat dart-sass speedtest-cli lynx atool figlet luarocks network-manager-applet glfw alsa-firmware pipewire pipewire-audio pipewire-alsa pipewire-pulse wireplumber sof-firmware alsa-ucm-conf viewnior qalculate-gtk pyright python-black vscode-html-languageserver typescript-language-server mdformat ydotool ccls jedi-language-server wakatime flatpak ghostscript qpdf mupdf-tools openssl dbus sqlite hspell nuspell dictd cargo xmlstarlet lua51 gdb yq dos2unix 7zip perl-image-exiftool python-psutil preload sysstat lazydocker-bin gopls gomodifytags gotests gore graphviz python-pyflakes python-isort python-pipenv python-nose python-pytest tidy stylelint js-beautify cpptools-debug-bin dialog python-watchdog advcpmv maven speech-dispatcher python-lsp-server python-plyer taplo-cli reflector yakuake)
    paru -S --needed --noconfirm "${pkgs[@]}"

    sudo systemctl enable --now tlp.service
    sudo systemctl enable --now bluetooth.service
    sudo updatedb
}

step_git_zsh_setup() {
    # Git Config
    git_username="Chaganti-Reddy"
    git_email="chagantivenkataramireddy4@gmail.com"
    editor="nvim"
    git config --global user.name "$git_username"
    git config --global user.email "$git_email"
    git config --global core.editor "$editor"
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

    # ZSH Packages
    paru -S --needed --noconfirm zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting zoxide

    # Change Shell
    if [[ "$SHELL" != "/bin/zsh" ]]; then sudo chsh -s /bin/zsh "$USER"; fi

    # Install ZSH Scripts (if exists)
    if [ -f "$DOTFILES_DIR/install_zsh.sh" ]; then bash "$DOTFILES_DIR/install_zsh.sh"; fi

    rm -f ~/.zshrc
    cd ~/dotfiles || return
    stow zsh_karna

    # Custom Theme Copy
    local theme_src="$DOTFILES_DIR/Extras/Extras/archcraft-dwm.zsh-theme"
    local theme_dest="$HOME/.oh-my-zsh/themes/archcraft-dwm.zsh-theme"
    if [ -f "$theme_src" ]; then
        mkdir -p "$(dirname "$theme_dest")"
        cp "$theme_src" "$theme_dest"
    fi
}

step_nodejs() {
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
}

step_editors() {
    paru -S --needed --noconfirm vim neovim html-xml-utils aspell emacs tree-sitter-cli tree-sitter-bash tree-sitter-rust
}

step_professional() {
    paru -S --needed --noconfirm visual-studio-code-bin discord telegram-desktop-bin libreoffice-fresh texlive-bin texlive-meta texlive-latex tex-fmt-bin perl-yaml-tiny perl-file-homedir perl-unicode-linebreak docker
    # paru -S --needed --noconfirm obs-studio wlrobs-hg

    sudo systemctl enable docker.service
    sudo usermod -aG docker "$USER"
}

step_browsers() {
    paru -S --needed --noconfirm firefox aria2 python-adblock qutebrowser dnsmasq webtorrent-cli webtorrent-mpv-hook peerflix chromium
    sudo npm install -g nativefier bash-language-server || warning "npm install failed, check node"
    curl -sSLf https://github.com/aclap-dev/vdhcoapp/releases/latest/download/install.sh | bash
}

step_file_managers() {
    paru -S --needed --noconfirm gvfs gvfs-afc gvfs-google gvfs-goa gvfs-gphoto2 gvfs-mtp gvfs-nfs gvfs-onedrive gvfs-smb tumbler thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman thunar-vcs-plugin
}

step_encryption() {
    paru -S --needed --noconfirm pass gnupg ccrypt git-remote-gcrypt qrencode
    mkdir -p ~/.gnupg
    if ! grep -q "default-cache-ttl" ~/.gnupg/gpg-agent.conf 2>/dev/null; then
        echo "default-cache-ttl 150" >>~/.gnupg/gpg-agent.conf
        echo "max-cache-ttl 150" >>~/.gnupg/gpg-agent.conf
        gpgconf --kill gpg-agent
    fi
}

step_theming_anime() {
    paru -S --needed --noconfirm whitesur-cursor-theme-git yt-dlp-git ani-cli-git ani-skip-git
}

step_repo_fonts() {
    paru -S --needed --noconfirm adobe-source-code-pro-fonts noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-hack ttf-jetbrains-mono ttf-ubuntu-font-family ttf-ubuntu-mono-nerd ttf-ubuntu-nerd ttf-opensans ttf-dejavu-nerd ttf-firacode-nerd otf-droid-nerd ttf-cascadia-code-nerd ttf-hack-nerd ttf-ibmplex-mono-nerd ttf-jetbrains-mono-nerd ttf-roboto-mono-nerd ttf-material-design-icons-webfont ttf-iosevka-nerd ttf-iosevkaterm-nerd ttf-ms-fonts
}

step_pdf_zathura() {
    paru -S --needed --noconfirm zathura zathura-pdf-mupdf zathura-djvu zathura-ps zathura-cb okular
    # Zathura Pywal
    local zdir="$DOTFILES_DIR/Extras/Extras/Zathura-Pywal-master"
    if [ -d "$zdir" ]; then
        cd "$zdir" || return
        chmod +x install.sh
        ./install.sh
        cd "$DOTFILES_DIR"
    fi
}

step_hyprland_stack() {
    paru -S --needed --noconfirm rofi-wayland rofi-emoji rofi-calc dunst udiskie hyprlang kitty yazi hyprland hyprlock xdg-desktop-portal-hyprland cliphist hyprland-guiutils hyprpicker hyprpaper system-config-printer chafa hypridle waybar wl-clipboard speech-dispatcher cmake meson cpio grim slurp wtype wf-recorder qt5-wayland qt6-wayland xdg-desktop-portal-wlr wlr-randr pyprland wofi pear-desktop-bin hyprsunset sunsetr-bin thefuck foot

    sudo usermod -aG video "$USER"
    sudo usermod -aG input "$USER"

    mkdir -p "$HOME/.config/xdg-desktop-portal"
    echo "[preferred]" >"$HOME/.config/xdg-desktop-portal/hyprland-portals.conf"
    echo "default=hyprland;gtk" >>"$HOME/.config/xdg-desktop-portal/hyprland-portals.conf"
    echo "org.freedesktop.impl.portal.FileChooser=gtk" >>"$HOME/.config/xdg-desktop-portal/hyprland-portals.conf"
}

step_wallpapers() {
    if [ -d "$HOME/Pictures/pix" ]; then return; fi

    cd ~/Downloads
    curl -L -o wall.zip https://gitlab.com/chaganti-reddy1/wallpapers/-/archive/main/wallpapers-main.zip
    unzip -q wall.zip
    mv wallpapers-main/pix ~/Pictures/
    rm -rf wallpapers-main wall.zip
    cd ~/dotfiles
}

step_kvm_qemu() {
    info "Setting up KVM/QEMU..."
    if ! grep -qE '(vmx|svm)' /proc/cpuinfo; then
        warning "Virtualization not supported by CPU."
        return 0
    fi

    paru -S --needed --noconfirm qemu-full qemu-img libvirt virt-install virt-manager virt-viewer spice-vdagent edk2-ovmf swtpm guestfs-tools libosinfo dnsmasq vde2 bridge-utils openbsd-netcat dmidecode iptables libguestfs

    sudo systemctl enable --now libvirtd.service
    sudo usermod -aG libvirt "$USER"
    sudo sed -i 's/^#\?unix_sock_group.*/unix_sock_group = "libvirt"/' /etc/libvirt/libvirtd.conf
    sudo sed -i 's/^#\?unix_sock_rw_perms.*/unix_sock_rw_perms = "0770"/' /etc/libvirt/libvirtd.conf
    sudo systemctl restart libvirtd.service
}

step_sddm_theme() {
    local src="$DOTFILES_DIR/Extras/Extras/usr/share/sddm/themes/simple-sddm/"
    if [ -d "$src" ]; then sudo cp -r "$src" /usr/share/sddm/themes/; fi
    if [ -f "$DOTFILES_DIR/Extras/Extras/etc/sddm.conf" ]; then sudo cp "$DOTFILES_DIR/Extras/Extras/etc/sddm.conf" /etc/sddm.conf; fi
}

step_stow_karna() {
    cd "$DOTFILES_DIR" || return 1
    rm -rf ~/.bashrc
    rm -rf ~/.config/dolphinrc
    rm -rf ~/.config/gtkrc
    rm -rf ~/.config/kate-externaltoolspluginrc
    rm -rf ~/.config/katerc
    rm -rf ~/.config/katevirc
    rm -rf ~/.config/kcminputrc
    rm -rf ~/.config/kded_device_automounterrc
    rm -rf ~/.config/kdeglobals
    rm -rf ~/.config/kglobalshortcutsrc
    rm -rf ~/.config/konsolerc
    rm -rf ~/.config/konsolesshconfig
    rm -rf ~/.config/krunnerrc
    rm -rf ~/.config/kscreenlockerrc
    rm -rf ~/.config/ksmserverrc
    rm -rf ~/.config/kwinrc
    rm -rf ~/.config/plasma-org.kde.plasma.desktop-appletsrc
    rm -rf ~/.config/plasmanotifyrc
    rm -rf ~/.config/plasmaparc
    rm -rf ~/.config/plasmashellrc
    rm -rf ~/.config/powerdevilrc
    rm -rf ~/.config/powermanagementprofilesrc
    rm -rf ~/.config/user-dirs.dirs
    rm -rf ~/.config/yakuakerc
    rm -rf ~/.local/share/dolphin
    rm -rf ~/.local/share/kate
    rm -rf ~/.local/share/konsole
    rm -rf ~/.local/share/kxmlgui5

    local folders=(bash_karna BTOP_karna dunst face_karna neofetch latexmkrc libreoffice mpd_karna mpv_karna myemojis rmpc newsboat_karna nvim NWG octave pandoc pavucontrol qutebrowser yazi screenlayout sxiv Templates xarchiver zathura kitty enchant vim Okular fastfetch hyprland waybar rofi mimeapps gtk-2 gtk-3 KDE foot)

    for folder in "${folders[@]}"; do
        info "Stowing $folder"
        stow -R "$folder"
    done

    # External Configs
    sudo cp -r Extras/Extras/dunst/ /usr/share/icons/ || true
    if [ -d "Extras/Extras/etc" ]; then
        sudo cp Extras/Extras/etc/nanorc /etc/nanorc
        sudo cp Extras/Extras/etc/bash.bashrc /etc/bash.bashrc
        sudo cp Extras/Extras/etc/DIR_COLORS /etc/DIR_COLORS
        sudo cp Extras/Extras/etc/environment /etc/environment
        sudo cp Extras/Extras/etc/mpd.conf /etc/mpd.conf
    fi
    if [ -f "Extras/Extras/nvim.desktop" ]; then sudo cp Extras/Extras/nvim.desktop /usr/share/applications/nvim.desktop; fi

    mkdir -p "$HOME/.config/menus/"
    curl -L -s -o "$HOME/.config/menus/applications.menu" https://raw.githubusercontent.com/KDE/plasma-workspace/master/menu/desktop/plasma-applications.menu

    if [ -f "Extras/Extras/.wakatime.cfg.cpt" ]; then
        cp Extras/Extras/.wakatime.cfg.cpt ~/
        ccrypt -d ~/.wakatime.cfg.cpt || warning "Wakatime decrypt skipped"
    fi
}

# -------------------------- EXECUTION --------------------------
clear
echo -e "${BOLD}${BLUE}Starting Granular Setup (User: karna)${RESET}"

# Core
run_task "Prep Folders" step_prep_folders
run_task "Pacman Config" step_pacman_config
run_task "Install Paru" step_install_paru
run_task "System Base" step_system_base
run_task "Git & ZSH" step_git_zsh_setup
run_task "Node/NVM" step_nodejs
run_task "Editors" step_editors
run_task "Professional Tools" step_professional
run_task "Browsers" step_browsers
# run_task "File Managers" step_file_managers
run_task "Encryption/GPG" step_encryption
run_task "Theming & Anime" step_theming_anime
run_task "Repo Fonts" step_repo_fonts
run_task "Custom Fonts" install_fonts
run_task "Custom Themes" install_themes
run_task "PDF & Zathura" step_pdf_zathura
run_task "Hyprland Stack" step_hyprland_stack
run_task "Download Wallpapers" step_wallpapers
run_task "KVM/QEMU" step_kvm_qemu
run_task "Miniconda" install_miniconda "y"
run_task "Pip Packages" install_pip_packages "y"
run_task "Waldl" install_waldl
run_task "GRUB Theme" install_grub_theme "y"
run_task "SDDM Theme" step_sddm_theme
run_task "Stow Dotfiles" step_stow_karna

success "Setup Finished."
