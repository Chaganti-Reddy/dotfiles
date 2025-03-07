#!/bin/bash

log_info() { echo -e "\e[32m[INFO] $1\e[0m"; }
log_warn() { echo -e "\e[33m[WARN] $1\e[0m"; }
log_error() { echo -e "\e[31m[ERROR] $1\e[0m"; }

install_paru() {
  log_info "This script requires an AUR helper to install dependencies. Checking for paru..."
  sleep 2

  if ! command -v paru &>/dev/null; then
    log_warn "Paru is not installed. Attempting installation..."

    # Navigate to Downloads and install paru
    cd ~/Downloads || { log_error "Failed to navigate to ~/Downloads"; return 1; }
    
    git clone https://aur.archlinux.org/paru-bin.git || { log_error "Failed to clone paru repository"; return 1; }
    cd paru-bin || { log_error "Failed to navigate to paru-bin"; return 1; }
    
    makepkg -si --noconfirm || { log_error "Failed to install paru"; return 1; }

    # Clean up
    log_info "Cleaning up installation files..."
    cd .. && rm -rf paru-bin

    log_info "Paru installed successfully."
    sleep 1
  else
    log_info "Paru is already installed."
    sleep 1
  fi
}

install_paru  # Run the function
cd ~/dotfiles || log_warn "Failed to navigate to ~/dotfiles. Continuing anyway."
