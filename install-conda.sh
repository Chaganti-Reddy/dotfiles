#!/bin/bash

# Define color codes for easy use
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'  # Reset to default color

echo -e "${CYAN}Setting up Miniconda...${RESET}" && sleep 1

# Ask the user if they want to install Miniconda
echo -e -n "${YELLOW}Would you like to install Miniconda? (y/n) [default: y]: ${RESET}"
read -e response
response=${response:-y} # Default to 'y' if the user presses Enter

if [[ ! "$response" =~ ^[Yy]$ ]]; then
  echo -e "${MAGENTA}Miniconda installation skipped. Proceeding with the setup.${RESET}" 
  sleep 1
else
  echo -e "${CYAN}Miniconda installation will begin now...${RESET}" && sleep 1

  # Define Miniconda installer URL
  MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-py310_24.3.0-0-Linux-x86_64.sh"
  INSTALLER_NAME="Miniconda3.sh"

  # Download Miniconda installer
  echo -e "${YELLOW}Downloading Miniconda installer...${RESET}"
  wget -q --show-progress -O "$INSTALLER_NAME" "$MINICONDA_URL"

  # Run the installer
  echo -e "${YELLOW}Running the Miniconda installer...${RESET}"
  bash "$INSTALLER_NAME" -b -p "$HOME/miniconda" # Install silently in the $HOME/miniconda directory

  # Remove the installer after installation
  echo -e "${CYAN}Cleaning up installer files...${RESET}"
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
    echo -e "${RED}Neither .bashrc nor .zshrc found. Exiting setup.${RESET}"
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
      echo -e "${YELLOW}Adding Conda initialization to $config...${RESET}"
      echo "$CONDA_BLOCK" >> "$config"
    else
      echo -e "${GREEN}Conda initialization block already present in $config.${RESET}"
    fi
  done

  # Now execute the Conda initialization code directly to initialize Conda
  if [[ "$SHELL" == *"bash"* ]]; then
    # Bash initialization
    eval "$($HOME/miniconda/bin/conda shell.bash hook)"
    echo -e "${CYAN}Evaluating $HOME/miniconda/bin/conda shell.bash hook${RESET}"
  elif [[ "$SHELL" == *"zsh"* ]]; then
    # Zsh initialization
    eval "$($HOME/miniconda/bin/conda shell.zsh hook)"
    echo -e "${CYAN}Evaluating $HOME/miniconda/bin/conda shell.zsh hook${RESET}"
  else
    echo -e "${RED}Unsupported shell detected. Unable to initialize Conda.${RESET}"
    exit 1
  fi

  # Verify Conda and Python installation
  echo -e "${CYAN}Verifying Miniconda installation...${RESET}"
  conda --version
  python --version

  echo -e "\n${GREEN}Miniconda installation and initialization completed successfully.${RESET}"
  echo -e "${YELLOW}Python Version: $(python --version)${RESET}"
  echo -e "${YELLOW}Conda Version: $(conda --version)${RESET}"
  echo -e "${CYAN}Installation path: $HOME/miniconda${RESET}\n"

  sleep 3
  echo -e "${GREEN}Miniconda setup is complete. Proceeding with the script...${RESET}"
fi
