#!/bin/env bash
set -euo pipefail

# -------------------------- Configuration ---------------------------
SUB_SCRIPTS=(
  install-git.sh
  install-aur-helper.sh
  install-packages.sh
  install-shell.sh
  install-gpg.sh
  install-hypr.sh
  install-qtile.sh
  install-conda.sh
  install-kvm.sh
  install-browser.sh
  install-torrent.sh
  install-dev-apps.sh
  install-tools.sh
  install-mariadb.sh
  install-fonts.sh
  install-dwm.sh
  install-bspwm.sh
  install-ollama.sh
  install-pip-pack.sh
  install-grub.sh
  install-display-manager.sh
  install-wallpapers.sh
  install-extras.sh
)

# -------------------------- Functions ---------------------------
die() {
  echo -e "\033[1;31mERROR:\033[0m $*" >&2
  exit 1
}

info() {
  echo -e "\033[1;34mINFO:\033[0m $*"
}

success() {
  echo -e "\033[1;32mSUCCESS:\033[0m $*"
}

check_privileges() {
  if [[ $EUID -eq 0 ]]; then
    die "This script should not be run as root. Please run as regular user."
  fi
  
  if ! sudo -v; then
    die "User does not have sudo privileges or password is incorrect."
  fi
}

setup_user_dirs() {
  info "Creating standard user directories..."
  mkdir -p ~/{Downloads,dox,Music,Pictures,vid,Templates} || true
}

configure_pacman() {
  local target_line="#UseSyslog"
  local check_line="ILoveCandy"

  if grep -q "$check_line" /etc/pacman.conf; then
    info "Pacman already configured with candy theme"
    return
  fi

  sudo sed -i '/^ParallelDownloads/d' /etc/pacman.conf

  info "Configuring pacman..."
  sudo sed -i "/$target_line/a ILoveCandy\nParallelDownloads=10\nColor" /etc/pacman.conf
}

system_update() {
  info "Performing full system update..."
  sudo pacman --noconfirm -Syu
  sudo pacman -S --needed --noconfirm git
}

run_subscripts() {
  for script in "${SUB_SCRIPTS[@]}"; do
    if [[ ! -f "$script" ]]; then
      die "Missing required sub-script: $script"
    fi
    
    info "Executing $script..."
    if ! bash "$script"; then
      die "Failed during execution of $script"
    fi
  done
}

# -------------------------- Main Program ---------------------------
clear
echo -e "\n\033[1;36mArch Linux Setup Script\033[0m\n"
sleep 1

check_privileges
setup_user_dirs
configure_pacman
system_update
run_subscripts

success "All installations completed!"
info "Please review essentials.md before rebooting your system."
