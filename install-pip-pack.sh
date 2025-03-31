#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

echo -e "${CYAN}Setting up PIP Packages...${RESET}"

# Ask the user if they want to install PIP packages, defaulting to "yes"
read -p "Would you like to install my PIP packages? (y/n): " install_pip_packages
install_pip_packages="${install_pip_packages:-y}"  # Default to "y" if no input is provided

# Initialize Conda shell for the current session
eval "$($HOME/miniconda/bin/conda shell.zsh hook)"

# Check if conda is available, if not, skip the installation
if command -v conda &>/dev/null; then
  if [[ "$install_pip_packages" == "y" || "$install_pip_packages" == "Y" ]]; then
    echo -e "${YELLOW}Conda detected, installing PIP packages...${RESET}"

    # List of packages to install
    pip_packages=("pynvim" "numpy" "pandas" "matplotlib" "seaborn" "scikit-learn" "jupyterlab" "ipykernel" "ipywidgets" "tensorflow" "python-prctl" "inotify-simple" "psutil" "opencv-python" "keras" "mov-cli-youtube" "mov-cli" "mov-cli-test" "otaku-watcher" "film-central" "daemon" "jupyterlab_wakatime" "pygobject" "spotdl" "beautifulsoup4" "requests" "flask" "streamlit" "pywal16" "zxcvbn" "pyaml" "my_cookies" "codeium-jupyter" "pymupdf" "tk-tools" "ruff-lsp" "python-lsp-server" "semgrep" "transformers" "spacy" "nltk" "sentencepiece" "ultralytics" "roboflow" "pipreqs")
    
    # Install each package if it's not already installed
    for package in "${pip_packages[@]}"; do
      if ! pip show "$package" &>/dev/null; then
        echo -e "${CYAN}Installing $package...${RESET}"
        pip install "$package"
      else
        echo -e "${GREEN}$package is already installed.${RESET}"
      fi
    done

    # Install PyTorch (CPU version)
    if ! pip show "torch" &>/dev/null; then
      echo -e "${CYAN}Installing PyTorch (CPU version)...${RESET}"
      pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
    else
      echo -e "${GREEN}PyTorch is already installed.${RESET}"
    fi

    echo -e "${GREEN}PIP packages installation completed.${RESET}"
    sleep 1 
  else
    echo -e "${YELLOW}PIP packages installation skipped. Proceeding with the setup.${RESET}" && sleep 1
  fi
else
  echo -e "${RED}Conda not found, skipping PIP packages installation.${RESET}" && sleep 1
fi
