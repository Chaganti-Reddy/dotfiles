#!/bin/bash

# Exit script on error
set -e

# Colors for output
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

# Logging functions
log_info() { echo -e "${GREEN}[INFO]${RESET} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${RESET} $1"; }
log_error() { echo -e "${RED}[ERROR]${RESET} $1"; }

# Prompt user with default value handling
prompt() {
  local message="$1"
  local default="$2"
  local input
  read -rp "$message [$default]: " input
  echo "${input:-$default}"
}

# Function to prompt for Git username
get_git_username() {
  while true; do
    git_username=$(prompt "Enter your Git username" "")
    if [[ -n "$git_username" ]]; then break; fi
    log_warn "Git username cannot be empty. Please try again."
  done
}

# Function to prompt for Git email
get_git_email() {
  while true; do
    git_email=$(prompt "Enter your Git email" "")
    if [[ "$git_email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then break; fi
    log_warn "Invalid email address. Please try again."
  done
}

# Function to select Git editor
select_git_editor() {
  echo -e "\nSelect your preferred editor for Git:"
  echo "1) Vim"
  echo "2) Nano"
  echo "3) VSCode"
  echo "4) Neovim"
  echo "5) None (skip editor configuration)"
  
  editor_choice=$(prompt "Enter your choice" "1")

  case $editor_choice in
    1) editor="vim" ;;
    2) editor="nano" ;;
    3) editor="code" ;;
    4) editor="nvim" ;;
    5) editor="" ;;
    *) log_warn "Invalid choice. Defaulting to Vim."; editor="vim" ;;
  esac
}

# Function to apply Git configuration
configure_git() {
  log_info "Applying Git configuration..."
  git config --global user.name "$git_username"
  git config --global user.email "$git_email"
  
  if [[ -n $editor ]]; then
    git config --global core.editor "$editor"
    log_info "Editor set to $editor."
  else
    log_info "Editor configuration skipped."
  fi

  log_info "Applying additional Git tweaks..."
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

  log_info "Git successfully configured!"
  git config --list | grep -E "user.name|user.email|core.editor|init.defaultBranch|alias|push.default"
}

# Main function
main() {
  log_info "Starting Git setup..."

  # Ask user whether to proceed
  proceed=$(prompt "Do you want to proceed with Git setup? (y/n)" "y")
  if [[ ! "$proceed" =~ ^[Yy]$ ]]; then
    log_warn "Git setup skipped."
    exit 0
  fi

  # Get user input
  get_git_username
  get_git_email
  select_git_editor

  # Confirm before applying
  echo -e "\n${GREEN}Please confirm the Git configuration:${RESET}"
  echo "Username: $git_username"
  echo "Email: $git_email"
  [[ -n $editor ]] && echo "Editor: $editor" || echo "Editor: None (skipped)"
  
  confirm=$(prompt "Do you want to proceed with this configuration? (y/n)" "y")
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    log_warn "Git configuration canceled. No changes were made."
    return 0
  fi

  # Apply Git configuration
  configure_git
}

# Run main function
main
