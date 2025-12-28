#!/bin/env bash
set -u

# -------------------------- CONFIGURATION --------------------------
LOG_FILE="$HOME/dotfiles-install.log"
CHECKPOINT_DIR="$HOME/.cache/setup_checkpoints"
mkdir -p "$CHECKPOINT_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

# -------------------------- LOGGING SETUP --------------------------
exec > >(tee -a "$LOG_FILE") 2>&1

# -------------------------- UTILS & COLORS --------------------------
BOLD=$(tput bold)
RESET=$(tput sgr0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
YELLOW=$(tput setaf 3)

die() { echo -e "${BOLD}${RED}ERROR:${RESET} $*" >&2; exit 1; }
info() { echo -e "${BOLD}${BLUE}INFO:${RESET} $*"; }
success() { echo -e "${BOLD}${GREEN}SUCCESS:${RESET} $*"; }
warning() { echo -e "${BOLD}${CYAN}WARNING:${RESET} $*"; }

# Ensure dialog is installed before doing anything
if ! command -v dialog &>/dev/null; then
    echo "Installing 'dialog' for the User Interface..."
    sudo pacman -S --noconfirm dialog &>/dev/null
fi

# Helper: Show a Yes/No box. Returns 0 for Yes, 1 for No.
# Usage: ui_yesno "Title" "Message Body"
ui_yesno() {
    dialog --title "$1" --backtitle "Arch Linux Setup" \
           --yesno "$2" 10 60 \
           2>&1 >/dev/tty
}

# Helper: Show a Message box (OK button)
# Usage: ui_msg "Title" "Message Body"
ui_msg() {
    dialog --title "$1" --backtitle "Arch Linux Setup" \
           --msgbox "$2" 10 60 \
           2>&1 >/dev/tty
}

# Helper: Input box
# Usage: result=$(ui_input "Title" "Message")
ui_input() {
    dialog --title "$1" --backtitle "Arch Linux Setup" \
           --inputbox "$2" 10 60 \
           2>&1 >/dev/tty
}

# -------------------------- CHECKPOINT SYSTEM --------------------------
run_task() {
    local task_name="$1"
    local task_id
    task_id=$(echo "$task_name" | tr -c '[:alnum:]' '_') 
    shift

    if [ -f "$CHECKPOINT_DIR/$task_id" ]; then
        success "Skipping '$task_name' (Already Completed)."
        return 0
    fi

    # clear screen for cleaner UI transition, but keep log history in file
    # clear 
    echo -e "\n${BOLD}${CYAN}>>> RUNNING: $task_name${RESET}"
    
    "$@"
    local status=$?

    if [ $status -eq 0 ]; then
        touch "$CHECKPOINT_DIR/$task_id"
        success "Task '$task_name' completed."
    else
        die "Task '$task_name' FAILED. Check $LOG_FILE."
    fi
}

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
        echo "Skipping $name (correct symlink)."
    else
        if [ -e "$symlink" ] || [ -L "$symlink" ]; then mv "$symlink" "$symlink.bak"; fi
        stow "$name" && echo "Stowed $name"
    fi
}

is_installed() { pacman -Qi "$1" &>/dev/null || paru -Q "$1" &>/dev/null; }

install_package() {
    local pkg=$1
    local name=$2
    local cmd=$3
    if is_installed "$pkg"; then
        success "$name is already installed."
    else
        info "Installing $name..."
        $cmd "$pkg"
    fi
}

check_privileges() {
    if [[ $EUID -eq 0 ]]; then die "Do not run as root. Run as user."; fi
    if ! sudo -v; then die "Sudo privileges required."; fi
}

setup_user_dirs() {
    info "Creating directories..."
    mkdir -p ~/Downloads ~/Documents ~/Music ~/Pictures ~/Video ~/Templates ~/Pictures/Screenshots ~/.mpd
}

configure_pacman() {
    if grep -q "ILoveCandy" /etc/pacman.conf; then return; fi
    sudo sed -i '/^ParallelDownloads/d' /etc/pacman.conf
    sudo sed -i "/#UseSyslog/a ILoveCandy\nParallelDownloads=10\nColor" /etc/pacman.conf
}

system_update() {
    info "Updating System..."
    sudo pacman -Sy
    sudo pacman -Su --noconfirm
    sudo pacman -S --needed --noconfirm git dialog
}

clone_or_download_dotfiles() {
    local target_dir="${HOME}/dotfiles"
    if [ -d "$target_dir" ]; then return 0; fi

    if [[ "$(whoami)" != "karna" ]]; then
        wget --progress=bar:force "https://gitlab.com/Chaganti-Reddy/dotfiles/-/archive/main/dotfiles-main.zip" -O "${HOME}/dotfiles-main.zip"
        unzip -q "${HOME}/dotfiles-main.zip" -d "${HOME}"
        mv "${HOME}/dotfiles-main" "${target_dir}"
        rm "${HOME}/dotfiles-main.zip"
    else
        git clone "https://gitlab.com/Chaganti-Reddy/dotfiles.git" "$target_dir"
    fi
}

install_aur_helpers() {
    local param="${1:-}"
    local selected_helper=""

    # Automation check
    if [[ "$param" == "1" || "$param" == "2" ]]; then
        if [ "$param" == "1" ]; then selected_helper="paru"; else selected_helper="yay"; fi
    else
        # UI Selection
        local choices
        choices=$(dialog --title "AUR Helper" --backtitle "Arch Setup" \
            --radiolist "Select AUR Helper to install:" 12 60 2 \
            1 "Paru (Recommended)" on \
            2 "Yay" off \
            2>&1 >/dev/tty)
        
        if [ "$choices" == "1" ]; then selected_helper="paru"; 
        elif [ "$choices" == "2" ]; then selected_helper="yay"; 
        else return; fi
    fi

    if [ "$selected_helper" == "paru" ]; then
        if ! command -v paru &>/dev/null; then
            info "Building Paru..."
            git clone https://aur.archlinux.org/paru-bin.git ~/Downloads/paru-bin
            cd ~/Downloads/paru-bin && makepkg -si --noconfirm --needed
            rm -rf ~/Downloads/paru-bin
        fi
    else
        if ! command -v yay &>/dev/null; then
            info "Building Yay..."
            git clone https://aur.archlinux.org/yay.git ~/Downloads/yay
            cd ~/Downloads/yay && makepkg -si --noconfirm --needed
            rm -rf ~/Downloads/yay
        fi
    fi
    cd ~/dotfiles
}

install_waldl() {
    if ! command -v waldl &>/dev/null; then
        cd "$HOME/dotfiles/Extras/Extras/waldl-master" && sudo make install && cd "$HOME/dotfiles"
    fi
}

setup_git_info() {
    local auto="${1:-}"
    
    # Check if we should run (UI Prompt or Argument)
    if [[ "$auto" != "y" ]]; then
        if ! ui_yesno "Git Configuration" "Do you want to configure Git globals now?"; then return; fi
    fi

    local git_user git_mail editor
    if [[ "$(whoami)" == "karna" ]]; then
        git_user="Chaganti-Reddy"
        git_mail="chagantivenkataramireddy4@gmail.com"
        editor="nvim"
    else
        git_user=$(ui_input "Git Username" "Enter your Git Username:")
        git_mail=$(ui_input "Git Email" "Enter your Git Email:")
        
        local ed_choice
        ed_choice=$(dialog --title "Git Editor" --menu "Select default editor:" 15 60 5 \
            1 "Vim" 2 "Nano" 3 "VSCode" 4 "Neovim" 2>&1 >/dev/tty)
        
        case $ed_choice in
            1) editor="vim" ;; 2) editor="nano" ;; 3) editor="code" ;; 4) editor="nvim" ;; *) editor="vim" ;;
        esac
    fi

    git config --global user.name "$git_user"
    git config --global user.email "$git_mail"
    git config --global core.editor "$editor"
    git config --global credential.helper "cache --timeout=3601"
    git config --global push.autoSetupRemote true
    success "Git configured."
}

install_dependencies() {
    # Assuming paru is installed
    local helper="paru"
    if ! command -v paru &>/dev/null; then helper="yay"; fi
    
    info "Installing Dependencies from packages.txt..."
    if [ -f "$HOME/dotfiles/packages.txt" ]; then
        # Read file, remove comments/empty lines
        local pkgs=$(grep -vE "^\s*#" "$HOME/dotfiles/packages.txt" | tr '\n' ' ')
        $helper -S --needed --noconfirm $pkgs
    fi

    sudo updatedb
    sudo mandb
    sudo systemctl enable --now tlp bluetooth
    sudo usermod -aG video,input "$USER"
}

install_shell() {
    local auto="${1:-}"
    if [[ "$auto" != "y" ]]; then
        if ! ui_yesno "ZSH Setup" "Install ZSH and Oh-My-Zsh?"; then return; fi
    fi

    sudo pacman -S --noconfirm zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting
    if [[ "$SHELL" != "/bin/zsh" ]]; then sudo chsh -s /bin/zsh "$USER"; fi
    
    cd ~/dotfiles
    if [ -f "install_zsh.sh" ]; then bash install_zsh.sh; fi
    rm -f ~/.zshrc
    
    local stow_folder="zsh"
    [ "$(whoami)" == "karna" ] && stow_folder="zsh_karna"
    stow "$stow_folder"

    local theme_src="$HOME/dotfiles/Extras/Extras/archcraft-dwm.zsh-theme"
    local theme_dest="$HOME/.oh-my-zsh/themes/archcraft-dwm.zsh-theme"
    if [[ -f "$theme_src" ]]; then mkdir -p "$(dirname "$theme_dest")"; cp "$theme_src" "$theme_dest"; fi
}

setup_gpg_pass() {
    local auto="${1:-}"
    if [[ "$auto" != "y" ]]; then
        if ! ui_yesno "GPG & Pass" "Setup GPG and Password Store?"; then return; fi
    fi

    sudo pacman -S --noconfirm gnupg pass qrencode rofi
    paru -S --noconfirm pass-import

    # Karna Automation check - skip interactive key gen if auto
    if [[ "$auto" == "y" && "$(whoami)" == "karna" ]]; then
        # Assuming keys exist or skipping gen for automated run
        return
    fi

    if ui_yesno "Import Keys" "Do you have a backup to import instead of generating new keys?"; then
        ui_msg "Manual Step" "Please manually import your GPG keys later using 'gpg --import'."
        return
    fi

    local name email
    name=$(ui_input "GPG Name" "Enter Full Name:")
    email=$(ui_input "GPG Email" "Enter Email:")
    
    if ! gpg --list-keys "$email" &>/dev/null; then
        # Generate in background to avoid breaking dialog
        gpg --batch --passphrase "" --quick-gen-key "$name <$email>" default default
    fi
    pass init "$email"
    
    echo "default-cache-ttl 150" >> ~/.gnupg/gpg-agent.conf
    gpgconf --kill gpg-agent
}

# -------------------------- DESKTOP ENVIRONMENTS --------------------------

install_i3() {
    if [[ "${1:-}" != "y" ]]; then if ! ui_yesno "Install i3" "Install i3 WM and configs?"; then return; fi; fi
    
    paru -S --noconfirm --needed i3-wm i3blocks xorg-xrdb xwallpaper xcompmgr i3status xss-lock autotiling kitty redshift conky betterlockscreen sxhkd
    
    cd ~/dotfiles
    stow_with_check "$HOME/dotfiles/i3/.config/i3" "$HOME/.config/i3" "i3"
    stow_with_check "$HOME/dotfiles/i3blocks/.config/i3blocks/" "$HOME/.config/i3blocks" "i3blocks"
    stow_with_check "$HOME/dotfiles/rofi/.config/rofi" "$HOME/.config/rofi" "rofi"
    stow_with_check "$HOME/dotfiles/kitty/.config/kitty" "$HOME/.config/kitty" "kitty"
    install_waldl
}

install_qtile() {
    if [[ "${1:-}" != "y" ]]; then if ! ui_yesno "Install Qtile" "Install Qtile and configs?"; then return; fi; fi
    
    paru -S --noconfirm --needed qtile python-dbus-fast python-gobject cairo feh picom alacritty kitty qtile-extras python-pulsectl-asyncio python-mpd2 xdg-desktop-portal-gtk redshift

    cd ~/dotfiles
    stow_with_check "$HOME/dotfiles/qtile/.config/qtile" "$HOME/.config/qtile" "qtile"
    stow_with_check "$HOME/dotfiles/rofi/.config/rofi" "$HOME/.config/rofi" "rofi"
    install_waldl
}

install_hyprland() {
    if [[ "${1:-}" != "y" ]]; then if ! ui_yesno "Install Hyprland" "Install Hyprland and configs?"; then return; fi; fi
    
    paru -S --noconfirm --needed hyprland hyprlock xdg-desktop-portal-hyprland hyprlang cliphist conky hyprland-qtutils hyprpicker hyprpaper kitty system-config-printer chafa hypridle waybar wl-clipboard speech-dispatcher cmake meson cpio grim slurp wtype ydotool wf-recorder redshift qt5-wayland qt6-wayland wlroots xdg-desktop-portal-wlr wlr-randr pyprland

    local stow_folder="hyprland_gen"
    if [[ "$(whoami)" == "karna" ]]; then stow_folder="hyprland"; fi

    cd ~/dotfiles
    if [[ ! -f "$HOME/.config/hypr/hyprland.conf" ]]; then
        stow_with_check "$HOME/dotfiles/$stow_folder/.config/hypr" "$HOME/.config/hypr" "$stow_folder"
        stow_with_check "$HOME/dotfiles/rofi/.config/rofi" "$HOME/.config/rofi" "rofi"
        stow_with_check "$HOME/dotfiles/kitty/.config/kitty" "$HOME/.config/kitty" "kitty"
    fi
    
    # Portal Fix
    mkdir -p "$HOME/.config/xdg-desktop-portal"
    echo -e "[preferred]\ndefault=hyprland;gtk\norg.freedesktop.impl.portal.FileChooser=gtk" > "$HOME/.config/xdg-desktop-portal/hyprland-portals.conf"

    install_waldl
}

install_dwm() {
    if [[ "${1:-}" != "y" ]]; then if ! ui_yesno "Install DWM" "Install DWM and configs?"; then return; fi; fi
    
    paru -S --noconfirm --needed xcompmgr xorg-xrdb xwallpaper kitty redshift conky betterlockscreen
    
    cd ~/dotfiles
    stow_with_check "$HOME/dotfiles/dwm/.config/dwm" "$HOME/.config/dwm" "dwm"
    stow_with_check "$HOME/dotfiles/dwm/.dwm" "$HOME/.dwm" "dwm-scripts"
    
    cd ~/.config/dwm/dwm && rm -f config.h && sudo make clean install
    cd ~/.config/dwm/dmenu/ && sudo make clean install
    cd ~/.config/dwm/slstatus/ && rm -f config.h && sudo make clean install
    
    sudo cp ~/dotfiles/Extras/Extras/usr/share/xsessions/dwm.desktop /usr/share/xsessions/
    sudo cp ~/dotfiles/dwm/.dwm/startdwm.sh /usr/local/bin/startdwm.sh
    
    install_waldl
}

install_bspwm() {
    if [[ "${1:-}" != "y" ]]; then if ! ui_yesno "Install BSPWM" "Install BSPWM and configs?"; then return; fi; fi
    
    paru -S --noconfirm --needed bspwm sxhkd pastel alacritty polybar xfce4-power-manager xsettingsd xorg-xsetroot wmname xcolor yad pulsemixer maim feh ksuperkey betterlockscreen light networkmanager-dmenu-git
    
    cd ~/dotfiles
    stow_with_check "$HOME/dotfiles/bspwm" "$HOME/.config/bspwm" "bspwm"
    stow_with_check "$HOME/dotfiles/rofi" "$HOME/.config/rofi" "rofi"
    install_waldl
}

install_sway() {
    if [[ "${1:-}" != "y" ]]; then if ! ui_yesno "Install Sway" "Install Sway and configs?"; then return; fi; fi
    paru -S --noconfirm --needed sway swaybg swaylock swayidle waybar xorg-xwayland rofi-wayland kitty xdg-desktop-portal-wlr autotiling
    cd ~/dotfiles
    stow_with_check "$HOME/dotfiles/sway/.config/sway/" "$HOME/.config/sway/" "sway"
    install_waldl
}

# -------------------------- TOOLS & APPS --------------------------

install_miniconda() {
    if command -v conda &>/dev/null; then return; fi
    if [[ "${1:-}" != "y" ]]; then if ! ui_yesno "Miniconda" "Install Miniconda?"; then return; fi; fi
    
    wget -q -O "Miniconda3.sh" "https://repo.anaconda.com/miniconda/Miniconda3-py310_24.3.0-0-Linux-x86_64.sh"
    bash "Miniconda3.sh" -b -p "$HOME/miniconda"
    rm "Miniconda3.sh"
    
    eval "$($HOME/miniconda/bin/conda shell.bash hook)"
    conda init bash
    conda init zsh
}

install_kvm() {
    if [[ "${1:-}" != "y" ]]; then if ! ui_yesno "KVM/QEMU" "Install Virtualization (KVM/QEMU)?"; then return; fi; fi
    if systemctl is-active --quiet libvirtd; then return; fi
    
    sudo pacman -S --noconfirm --needed qemu-full qemu-img libvirt virt-install virt-manager spice-vdagent edk2-ovmf swtpm guestfs-tools dnsmasq bridge-utils iptables
    sudo systemctl enable --now libvirtd
    sudo usermod -aG libvirt "$USER"
    sudo sed -i 's/^#\?unix_sock_group.*/unix_sock_group = "libvirt"/' /etc/libvirt/libvirtd.conf
    sudo sed -i 's/^#\?unix_sock_rw_perms.*/unix_sock_rw_perms = "0770"/' /etc/libvirt/libvirtd.conf
    sudo systemctl restart libvirtd
}

install_browser() {
    local args=("$@")
    if [ ${#args[@]} -eq 0 ]; then
        # UI Selection
        local choices
        choices=$(dialog --title "Browsers" --checklist "Select Browsers:" 15 60 5 \
            1 "Zen-Browser" off \
            2 "Firefox" off \
            3 "Chromium" off \
            4 "Vivaldi" off \
            5 "Qutebrowser" off \
            6 "Brave" off \
            2>&1 >/dev/tty)
        args=($choices)
    fi

    for choice in "${args[@]}"; do
        case $choice in
            1) paru -S --noconfirm --needed zen-browser-bin ;;
            2) sudo pacman -S --noconfirm firefox ;;
            3) sudo pacman -S --noconfirm chromium ;;
            4) paru -S --noconfirm --needed vivaldi ;;
            5) sudo pacman -S --noconfirm qutebrowser ;;
            6) paru -S --noconfirm --needed brave-bin ;;
        esac
    done
    
    if ! command -v nativefier &>/dev/null; then sudo npm install -g nativefier; fi
}

install_torrent() {
    local args=("$@")
    if [ ${#args[@]} -eq 0 ]; then
        local choices
        choices=$(dialog --title "Apps & Tools" --checklist "Select Tools:" 20 60 10 \
            1 "Torrent CLI" off 2 "qBittorrent" off 3 "Transmission" off \
            4 "Remmina" off 5 "VNC Server" off 6 "TeamViewer" off \
            7 "AnyDesk" off 8 "xrdp" off 9 "OpenVPN" off 10 "WireGuard" off \
            11 "Varia" off 12 "Warehouse" off 13 "Gromit-MPX" off \
            2>&1 >/dev/tty)
        args=($choices)
    fi

    for choice in "${args[@]}"; do
        case $choice in
            1) paru -S --noconfirm --needed webtorrent-cli webtorrent-mpv-hook peerflix ;;
            2) sudo pacman -S --noconfirm qbittorrent ;;
            3) sudo pacman -S --noconfirm transmission-qt ;;
            4) sudo pacman -S --noconfirm remmina ;;
            5) sudo pacman -S --noconfirm tigervnc ;;
            6) sudo pacman -S --noconfirm teamviewer ;;
            7) sudo pacman -S --noconfirm anydesk ;;
            8) sudo pacman -S --noconfirm xrdp ;;
            9) sudo pacman -S --noconfirm openvpn ;;
            10) sudo pacman -S --noconfirm wireguard-tools ;;
            11) flatpak install flathub io.github.giantpinkrobots.varia -y ;;
            12) flatpak install flathub io.github.flattool.Warehouse -y ;;
            13) paru -S --noconfirm --needed gromit-mpx ;;
        esac
    done
}

install_dev_tools() {
    local args=("$@")
    if [ ${#args[@]} -eq 0 ]; then
        local choices
        choices=$(dialog --title "Development Tools" --checklist "Select Tools:" 20 60 10 \
            1 "VSCode" off 2 "GitHub Desktop" off 3 "Docker" off \
            7 "Discord" off 8 "Obsidian" off 9 "Telegram" off \
            10 "LibreOffice" off 14 "Zoom" off 15 "Blender" off \
            17 "OBS Studio" off 24 "Steam" off 25 "Minecraft" off \
            26 "YouTUI" off 27 "YTerMusic" off \
            2>&1 >/dev/tty)
        args=($choices)
    fi

    for choice in "${args[@]}"; do
        case $choice in
            1) paru -S --noconfirm --needed visual-studio-code-bin ;;
            2) paru -S --noconfirm --needed github-desktop-bin ;;
            3) paru -S --noconfirm --needed docker docker-compose; sudo usermod -aG docker "$USER" ;;
            7) sudo pacman -S --noconfirm discord ;;
            8) sudo pacman -S --noconfirm obsidian ;;
            9) paru -S --noconfirm --needed telegram-desktop-bin ;;
            10) sudo pacman -S --noconfirm libreoffice-fresh ;;
            14) paru -S --noconfirm --needed zoom ;;
            15) sudo pacman -S --noconfirm blender ;;
            17) sudo pacman -S --noconfirm obs-studio; paru -S --noconfirm --needed wlrobs-hg ;;
            24) paru -S --noconfirm --needed steam ;;
            25) paru -S --noconfirm --needed minecraft-launcher ;;
            26) cargo install youtui ;;
            27) cargo install ytermusic ;;
        esac
    done
}

install_extra_tools() {
    local args=("$@")
    if [ ${#args[@]} -eq 0 ]; then
        local choices
        choices=$(dialog --title "Extra Tools" --checklist "Select Extras:" 15 60 6 \
            1 "Ani-Cli" off 2 "Ani-Cli-Py" off 3 "YTFZF" off \
            4 "Zathura" off 10 "YT Music" off \
            2>&1 >/dev/tty)
        args=($choices)
    fi

    for choice in "${args[@]}"; do
        case $choice in
            1) paru -S --noconfirm --needed ani-cli-git ani-skip-git ;;
            2) pipx install anipy-cli ;;
            3) paru -S --noconfirm --needed ytfzf-git ;;
            4) sudo pacman -S --noconfirm zathura zathura-pdf-mupdf; cd ~/dotfiles/Extras/Extras/Zathura-Pywal-master/ && ./install.sh ;;
            10) paru -S --noconfirm --needed youtube-music ;;
        esac
    done
}

install_fonts() {
    info "Installing GitLab Fonts..."
    local FONTS_DIR="$HOME/.local/share/fonts"
    if [ -d "$FONTS_DIR/my-fonts-main" ]; then return; fi
    mkdir -p "$FONTS_DIR"
    curl -L -o fonts.zip "https://gitlab.com/chaganti-reddy1/my-fonts/-/archive/main/my-fonts-main.zip"
    unzip -q fonts.zip -d "$FONTS_DIR"
    rm fonts.zip
}

install_ollama() {
    if [[ "${1:-}" != "y" ]]; then if ! ui_yesno "Ollama" "Install Ollama?"; then return; fi; fi
    curl -fsSL https://ollama.com/install.sh | sh
    ollama serve & disown
    sleep 2
    ollama pull deepseek-coder:6.7b
}

install_pip_packages() {
    if [[ "${1:-}" != "y" ]]; then if ! ui_yesno "Pip Packages" "Install custom pip packages?"; then return; fi; fi
    local pip_cmd="pip install --break-system-packages"
    if command -v conda &>/dev/null; then pip_cmd="pip install"; fi
    local pkgs=("pynvim" "numpy" "pandas" "matplotlib" "jupyterlab" "keras" "tensorflow" "torch" "transformers" "langchain-ollama")
    for p in "${pkgs[@]}"; do $pip_cmd "$p"; done
}

install_grub_theme() {
    if [[ "${1:-}" != "y" ]]; then if ! ui_yesno "GRUB Theme" "Install Sekiro GRUB Theme?"; then return; fi; fi
    local src="$HOME/dotfiles/Extras/Extras/boot/grub/themes/SekiroShadow/"
    if [ -d "$src" ]; then
        sudo cp -r "$src" /boot/grub/themes/
        echo 'GRUB_THEME="/boot/grub/themes/SekiroShadow/theme.txt"' | sudo tee -a /etc/default/grub
        sudo grub-mkconfig -o /boot/grub/grub.cfg
    fi
}

install_display_manager() {
    local auto="${1:-}"
    local choice="${2:-}"

    if [[ "$auto" != "y" ]]; then
        if ! ui_yesno "Display Manager" "Install a Display Manager?"; then return; fi
        choice=$(dialog --title "Login Manager" --menu "Select One:" 12 60 3 \
            1 "SDDM" 2 "LY" 3 "LightDM" 2>&1 >/dev/tty)
    fi

    case $choice in
        1) sudo pacman -S --noconfirm sddm; sudo systemctl enable sddm; sudo cp -r ~/dotfiles/Extras/Extras/usr/share/sddm/themes/simple-sddm /usr/share/sddm/themes ;;
        2) paru -S --noconfirm --needed ly; sudo systemctl enable ly ;;
        3) paru -S --noconfirm --needed lightdm lightdm-gtk-greeter; sudo systemctl enable lightdm ;;
    esac
}

download_wallpapers() {
    if [[ "${1:-}" != "y" ]]; then if ! ui_yesno "Wallpapers" "Download Wallpapers?"; then return; fi; fi
    if [ -d "$HOME/Pictures/pix" ]; then return; fi
    
    cd ~/Downloads
    curl -L -o wall.zip https://gitlab.com/chaganti-reddy1/wallpapers/-/archive/main/wallpapers-main.zip
    unzip -q wall.zip
    mv wallpapers-main/pix ~/Pictures/
    if pacman -Q bspwm &>/dev/null; then sudo mkdir -p /usr/share/backgrounds; sudo mv wallpapers-main/wall/* /usr/share/backgrounds/; fi
    rm -rf wallpapers-main wall.zip
    cd ~/dotfiles
}

install_extras() {
    sudo npm i -g bash-language-server
    
    if [[ "${1:-}" != "y" ]]; then
        if ui_yesno "Extras" "Install Themes, Icons, and Configs?"; then
            # Themes
            cd ~/Downloads
            curl -L -o archcraft.zip https://gitlab.com/chaganti-reddy1/archcraft-themes/-/archive/main/archcraft-themes-main.zip
            unzip -q archcraft.zip
            mkdir -p ~/.icons ~/.themes
            mv archcraft-themes-main/themes/* ~/.themes/
            mv archcraft-themes-main/icons/* ~/.icons/
            rm -rf archcraft.zip archcraft-themes-main
            cd ~/dotfiles
            
            # User Configs
            if [ "$(whoami)" == "karna" ]; then
                rm -rf ~/.bashrc
                stow bash_karna BTOP_karna dunst face_karna neofetch latexmkrc libreoffice mpd_karna mpv_karna myemojis rmpc newsboat_karna nvim NWG octave pandoc pavucontrol qutebrowser yazi sxiv Templates Thunar zathura kitty enchant vim Profile greenclip Okular redshift fastanime
                cp ~/dotfiles/Extras/Extras/.wakatime.cfg.cpt ~/
                ccrypt -d ~/.wakatime.cfg.cpt
            else
                stow bashrc BTOP dunst neofetch gtk-2 gtk-3 mpd mpv newsboat pavucontrol qutebrowser ranger sxiv Templates Thunar zathura
            fi
        fi
    fi
}

setup_ssh_and_upload() {
    local email
    email=$(ui_input "SSH Setup" "Enter Email for SSH Key:")
    ssh-keygen -t ed25519 -C "$email" -f "$HOME/.ssh/id_ed25519" -N ""
    ui_msg "SSH Created" "Key created at ~/.ssh/id_ed25519.pub.\nPlease manually upload to GitHub/GitLab."
}

# ==============================================================================
#  MAIN EXECUTION
# ==============================================================================

# clear
echo "Logs are being saved to $LOG_FILE"

if [[ "$(whoami)" == "karna" ]]; then
    # Karna Automation Mode
    run_task "Check Privileges" check_privileges
    run_task "User Dirs" setup_user_dirs
    run_task "Pacman Config" configure_pacman
    run_task "System Update" system_update
    run_task "Clone Dotfiles" clone_or_download_dotfiles
    run_task "AUR Helpers" install_aur_helpers 1
    run_task "Git Info" setup_git_info y
    run_task "Dependencies" install_dependencies
    run_task "Shell Setup" install_shell y
    run_task "GPG Setup" setup_gpg_pass y
    run_task "Install i3" install_i3 y
    run_task "Install Qtile" install_qtile y
    run_task "Install DWM" install_dwm y
    run_task "Install Sway" install_sway y
    run_task "Install Hyprland" install_hyprland y
    run_task "Miniconda" install_miniconda y
    run_task "KVM" install_kvm y
    run_task "Browsers" install_browser 5 6
    run_task "Torrents" install_torrent 1 13
    run_task "Dev Tools" install_dev_tools 3 6 7 9 10 16
    run_task "Extra Tools" install_extra_tools 1 2 3 4 6 10
    run_task "Fonts" install_fonts
    run_task "Ollama" install_ollama y
    run_task "Pip Packages" install_pip_packages y
    run_task "Grub Theme" install_grub_theme y
    run_task "Display Manager" install_display_manager y 2
    run_task "Wallpapers" download_wallpapers y
    run_task "Extras" install_extras y
    # ssh skipped for auto
else
    # Interactive Blue Box Mode
    run_task "Check Privileges" check_privileges
    run_task "User Dirs" setup_user_dirs
    run_task "Pacman Config" configure_pacman
    run_task "System Update" system_update
    run_task "Clone Dotfiles" clone_or_download_dotfiles
    run_task "AUR Helpers" install_aur_helpers
    run_task "Git Info" setup_git_info
    run_task "Dependencies" install_dependencies
    run_task "Shell Setup" install_shell
    run_task "GPG Setup" setup_gpg_pass
    run_task "Install i3" install_i3
    run_task "Install Qtile" install_qtile
    run_task "Install Hyprland" install_hyprland
    run_task "Miniconda" install_miniconda
    run_task "KVM" install_kvm
    run_task "Browsers" install_browser
    run_task "Torrents" install_torrent
    run_task "Dev Tools" install_dev_tools
    run_task "Extra Tools" install_extra_tools
    run_task "Fonts" install_fonts
    run_task "Install BSPWM" install_bspwm
    run_task "Ollama" install_ollama
    run_task "Pip Packages" install_pip_packages
    run_task "Grub Theme" install_grub_theme
    run_task "Display Manager" install_display_manager
    run_task "Wallpapers" download_wallpapers
    run_task "Extras" install_extras
    run_task "SSH Setup" setup_ssh_and_upload
fi

success "System Setup Complete!"
