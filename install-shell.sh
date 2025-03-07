#!/bin/bash

# Utility functions for logging
log_info() { echo -e "\e[32m[INFO] $1\e[0m"; }
log_warn() { echo -e "\e[33m[WARN] $1\e[0m"; }
log_error() { echo -e "\e[31m[ERROR] $1\e[0m"; }

# Function to prompt user with a default value
prompt() {
  local message=$1
  local default_value=$2
  read -rp "$message [default: $default_value]: " response
  echo "${response:-$default_value}"  # Use default if input is empty
}

install_zsh() {
  log_info "Setting up Zsh..."
  sleep 1

  install=$(prompt "Would you like to install Zsh and set it as your default shell? (y/n)" "y")
  if [[ ! "$install" =~ ^[Yy]$ ]]; then
    log_warn "Zsh installation skipped. Proceeding with the setup."
    return 0
  fi

  log_info "Installing Zsh and related packages..."
  sudo pacman -S --noconfirm zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting || {
    log_error "Failed to install Zsh packages."
    return 1
  }

  log_info "Changing default shell to Zsh..."
  if ! chsh -s /bin/zsh; then
    log_error "Failed to change the shell. Try running 'chsh -s /bin/zsh' manually."
    return 1
  fi

  log_info "Installing Oh My Zsh..."
  cd ~/dotfiles || { log_error "Failed to navigate to ~/dotfiles"; return 1; }
  
  bash install_zsh.sh || { log_error "Oh My Zsh installation failed."; return 1; }

  # Remove existing Zsh config
  rm -f ~/.zshrc

  # Set correct Stow folder
  stow_folder="zsh"
  if [ "$(whoami)" == "karna" ]; then
    stow_folder="zsh_karna"
  fi

  log_info "Setting up Zsh configuration using Stow ($stow_folder)..."
  stow "$stow_folder" || { log_error "Failed to stow $stow_folder configuration."; return 1; }

  # Copy custom theme if present
  cp Extras/Extras/archcraft-dwm.zsh-theme ~/.oh-my-zsh/themes/archcraft-dwm.zsh-theme 2>/dev/null && \
    log_info "Custom Zsh theme installed."

  log_info "Zsh has been installed and set as your default shell."
  sleep 2
}

install_zsh
