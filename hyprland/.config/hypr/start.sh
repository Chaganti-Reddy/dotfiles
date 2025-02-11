#!/bin/bash

export SSH_AUTH_SOCK
export GPG_AGENT_INFO
export GNOME_KEYRING_CONTROL
export GNOME_KEYRING_PID

sh ~/dotfiles/hyprland/.config/scripts/hyprstyle &


# Run ollama serve in the background silently.
ollama serve > /dev/null 2>&1 &
