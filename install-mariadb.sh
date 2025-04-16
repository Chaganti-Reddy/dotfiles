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

if [[ "$mariadb_installation" == "Y" || "$mariadb_installation" == "y" || -z "$mariadb_installation" ]]; then
  if ! command -v mariadb &> /dev/null; then
    echo -e "${YELLOW}MariaDB is not installed. Installing now...${RESET}"
    sudo pacman -S mariadb --noconfirm

    sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
    sudo systemctl enable --now mariadb

    echo -e "${GREEN}MariaDB has been installed and initialized.${RESET}"
  else
    echo -e "${GREEN}MariaDB is already installed.${RESET}"
    if systemctl is-active --quiet mariadb; then
      echo -e "${GREEN}MariaDB is already configured and running.${RESET}"
    else
      echo -e "${YELLOW}MariaDB is installed but not configured. Do you want to configure it now? (y/n)${RESET}"
      read -r mariadb_configure

      if [[ "$mariadb_configure" == "Y" || "$mariadb_configure" == "y" || -z "$mariadb_configure" ]]; then
        sudo mysql_secure_installation
        sudo systemctl enable --now mariadb
        echo -e "${GREEN}MariaDB has been configured and started.${RESET}"
      else
        echo -e "${YELLOW}Skipping MariaDB configuration.${RESET}"
      fi
    fi
  fi

  # Prompt for new user creation
  echo -e "${YELLOW}Would you like to create a new MariaDB user with full privileges? (y/n)${RESET}"
  read -r create_user
  if [[ "$create_user" == "Y" || "$create_user" == "y" || -z "$create_user" ]]; then
    echo -e "${CYAN}Enter the new username:${RESET}"
    read -r new_user
    echo -e "${CYAN}Enter the password for ${new_user}:${RESET}"
    read -rs new_pass
    echo

    # Run SQL commands to create the user
    sudo mariadb -u root <<EOF
CREATE USER '${new_user}'@'localhost' IDENTIFIED BY '${new_pass}';
GRANT ALL PRIVILEGES ON *.* TO '${new_user}'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

    echo -e "${GREEN}User '${new_user}' created with full privileges.${RESET}"
  else
    echo -e "${YELLOW}Skipping user creation.${RESET}"
  fi
else
  echo -e "${YELLOW}MariaDB installation and configuration skipped. Proceeding with the setup.${RESET}"
fi

sleep 2
