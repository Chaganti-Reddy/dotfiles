#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

echo -e "${CYAN}Setting up Ollama...${RESET}"

# Ask the user if they want to install Ollama
read -p "Would you like to install Ollama (a tool to run large language models locally)? (y/n): " install_ollama

if [[ "$install_ollama" == "y" || "$install_ollama" == "Y" ]]; then
  echo -e "${YELLOW}Ollama installation will begin now.${RESET}"

  # Check if Ollama is available through the AUR or if manual installation is needed
  # We will use AUR (Arch User Repository) to install it using an AUR helper like paru.

  # Install Ollama using paru (or an AUR helper of your choice)
  if ! command -v ollama &>/dev/null; then
    echo -e "${YELLOW}Ollama not found, installing Ollama from AUR...${RESET}"

    # Install Ollama from the AUR using curl (if not already installed)
    curl -fsSL https://ollama.com/install.sh | sh

    echo -e "${GREEN}Ollama has been installed. You can now use it to run local large language models.${RESET}" && sleep 2
    clear

    echo -e "${CYAN}Now you will see a lot of text but don't panic. Just put 'y' or 'n' for installing various models as their names will be shown at the first line...${RESET}" && sleep 10
    clear

    # Ask the user if they want to install models
    ollama serve &
    clear
    models=("deepseek-r1:8b" "deepseek-coder:6.7b" "llama3:8b" "mistral" "zephyr" "llava:7b")
    for model in "${models[@]}"; do
      clear
      echo -e "${CYAN}Would you like to install the model '$model'? (y/n)${RESET}"
      read -r install_model

      if [[ "$install_model" == "y" || "$install_model" == "Y" ]]; then
        echo -e "${YELLOW}Installing model '$model'...${RESET}"

        # Pull the model
        ollama pull "$model"

        echo -e "${GREEN}Model '$model' has been installed.${RESET}" && sleep 1
      else
        echo -e "${YELLOW}Model '$model' installation skipped.${RESET}" && sleep 1
      fi
    done
    clear
    echo -e "${GREEN}Ollama setup completed. Proceeding...${RESET}" && sleep 2
  else
    echo -e "${GREEN}Ollama is already installed on your system.${RESET}" && sleep 1
  fi
else
  echo -e "${YELLOW}Ollama installation skipped. Proceeding with the setup.${RESET}" && sleep 1
fi
