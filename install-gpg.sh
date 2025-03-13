#!/bin/bash

setup_gpg_pass() {
    echo -e "\n[INFO] Do you want to set up GPG and Pass for password management? (Y/n)"
    read -r RESPONSE
    RESPONSE=${RESPONSE:-y}  # Default to 'y' if user presses Enter

    if [[ "$RESPONSE" =~ ^[Nn]$ ]]; then
        echo -e "[WARN] Skipping GPG and Pass setup." && sleep 1
        return
    fi

    echo -e "\n[INFO] Setting up GPG and Pass..."

    # Check if required packages are already installed
    if ! pacman -Q gnupg pass rofi qrencode pass-import &> /dev/null; then
        echo -e "\n[INFO] Installing GPG and Pass..."
        sudo pacman -S --noconfirm gnupg pass qrencode rofi-wayland
        paru -S --noconfirm pass-import
    else
        echo -e "\n[INFO] Required packages are already installed. Skipping installation."
    fi

    # Ask if the user wants to import an existing GPG key and passwords
    echo -e "\n[INFO] Do you already have a backup of your GPG keys and passwords and just want to import them? (y/n)"
    read -r BACKUP_RESPONSE
    BACKUP_RESPONSE=${BACKUP_RESPONSE:-n}

    if [[ "$BACKUP_RESPONSE" =~ ^[Yy]$ ]]; then
        echo -e "\n[INFO] To import your GPG keys and password store, follow these steps:"
        echo -e "  1. Clone your backup repository containing your GPG keys and password store to your local machine."
        echo -e "     You can do this by running: git clone <YOUR_BACKUP_GIT_REPO_URL>"
        echo -e "  2. Import your GPG keys by running: gpg --import <path_to_your_backups>/*.gpg"
        echo -e "  3. Copy your password store (usually the folder named 'pass') to ~/.password-store/"
        echo -e "  4. Change the trust value of your GPG key after importing it, using the following command:"
        echo -e "     gpg --edit-key <your-email>"
        echo -e "     Then type: trust, select the trust level, and save."
        echo -e "  5. Finally, initialize the pass store again to match the imported key by running:"
        echo -e "     pass init <your-email>"

        echo -e "\n[INFO] Once done, you can continue with the setup manually. Skipping the automated setup."
        sleep 5
        return
    fi

    # Ask for user details if no backup or if new setup
    echo -e "\n[INFO] Let's create a new GPG key and set up Pass for you!"
    echo -n "[INFO] Enter your full name: "
    read -r NAME
    echo -n "[INFO] Enter your email address: "
    read -r EMAIL
    echo -n "[INFO] Enter a comment (optional): "
    read -r COMMENT

    # Check if a GPG key for the email already exists
    if gpg --list-keys "$EMAIL" > /dev/null 2>&1; then
        echo -e "\n[INFO] GPG key for $EMAIL already exists. Skipping key generation."
    else
        echo -e "\n[INFO] Generating a new GPG key..."
        cat >key-config <<EOF
        %echo Generating a GPG key
        Key-Type: RSA
        Key-Length: 4096
        Name-Real: $NAME
        Name-Comment: ${COMMENT:-None}
        Name-Email: $EMAIL
        Expire-Date: 0
        %commit
        %echo Done
EOF
        gpg --batch --full-generate-key key-config
        rm -f key-config
    fi

    # Check if pass is already initialized
    if pass show test-check > /dev/null 2>&1; then
        echo -e "\n[INFO] Pass is already initialized. Skipping initialization."
    else
        echo -e "\n[INFO] Initializing pass with GPG key linked to $EMAIL..."
        pass init "$EMAIL"
    fi

    # Secure GPG - Disable key caching
    echo -e "\n[INFO] Reducing GPG key caching time for better security..." && sleep 0.5
    echo "default-cache-ttl 150" >> ~/.gnupg/gpg-agent.conf
    echo "max-cache-ttl 150" >> ~/.gnupg/gpg-agent.conf
    gpgconf --kill gpg-agent  # Restart agent to apply changes

    echo -e "\n[INFO] GPG and Pass setup completed successfully!" && sleep 2
}

setup_gpg_pass
