#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

echo -e "${CYAN}Setting up MariaDB...${RESET}"

# Ask the user if they want to install and configure MariaDB
echo -e "${YELLOW}Would you like to install and configure MariaDB (a relational database management system)? (y/n)${RESET}"
read -r mariadb_installation

# Check if the user wants to proceed with MariaDB setup
if [[ "$mariadb_installation" == "Y" || "$mariadb_installation" == "y" || -z "$mariadb_installation" ]]; then
  # Check if MariaDB is installed
  if ! command -v mariadb &> /dev/null; then
    echo -e "${YELLOW}MariaDB is not installed. Installing now...${RESET}"
    
    # Install MariaDB
    sudo pacman -S mariadb --noconfirm

    # Initialize the database
    sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

    # Enable and start MariaDB service
    sudo systemctl enable --now mariadb

    echo -e "${GREEN}MariaDB has been installed and initialized.${RESET}"
  else
    echo -e "${GREEN}MariaDB is already installed.${RESET}"

    # Check if MariaDB is running or configured
    if systemctl is-active --quiet mariadb; then
      echo -e "${GREEN}MariaDB is already configured and running.${RESET}"
    else
      echo -e "${YELLOW}MariaDB is installed but not configured. Do you want to configure it now? (y/n)${RESET}"
      read -r mariadb_configure

      if [[ "$mariadb_configure" == "Y" || "$mariadb_configure" == "y" || -z "$mariadb_configure" ]]; then
        # Run the MariaDB secure installation
        sudo mariadb-secure-installation

        # Enable and start MariaDB service if not already running
        sudo systemctl enable --now mariadb

        echo -e "${GREEN}MariaDB has been configured and started.${RESET}"
      else
        echo -e "${YELLOW}Skipping MariaDB configuration.${RESET}"
      fi
    fi
  fi
else
  echo -e "${YELLOW}MariaDB installation and configuration skipped. Proceeding with the setup.${RESET}"
fi

sleep 2
