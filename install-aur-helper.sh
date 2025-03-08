#!/usr/bin/env bash

set -euo pipefail

log_info() { echo -e "\e[32m[INFO] $1\e[0m"; }
log_warn() { echo -e "\e[33m[WARN] $1\e[0m"; }
log_error() { echo -e "\e[31m[ERROR] $1\e[0m"; exit 1; }

install_paru() {
    log_info "Checking for AUR helper (paru)..."
    
    if command -v paru &>/dev/null; then
        log_info "paru is already installed."
        return 0
    fi

    log_info "paru not found. Starting installation..."
    local aur_dir="${HOME}/Downloads/paru-bin"
    local target_dir="${aur_dir%/*}"

    # Create downloads directory if needed
    mkdir -p "${target_dir}" || log_error "Failed to create directory: ${target_dir}"

    # Clone and build in a subshell to contain directory changes
    (
        cd "${target_dir}" || log_error "Failed to access: ${target_dir}"
        log_info "Cloning paru-bin repository..."
        git clone https://aur.archlinux.org/paru-bin.git || log_error "Failed to clone repository"
        cd paru-bin || log_error "Failed to enter paru-bin directory"
        makepkg -si --noconfirm --needed || log_error "Failed to build/install paru"
    )

    # Verify installation
    if ! command -v paru &>/dev/null; then
        log_error "paru installation failed - please install manually"
    fi

    # Cleanup
    log_info "Cleaning up installation files..."
    rm -rf "${aur_dir}"
}

main() {
    install_paru
    
    log_info "Navigating to dotfiles directory..."
    cd "${HOME}/dotfiles" 2>/dev/null || log_warn "dotfiles directory not found (${HOME}/dotfiles)"
}

main "$@"
