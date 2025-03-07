#!/bin/bash

# Define color codes for easy use
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'  # Reset to default color

echo -e "${CYAN}Setting up KVM...${RESET}" && sleep 1

# Ask the user if they want to install KVM QEMU
echo -e "${YELLOW}Would you like to install KVM QEMU Virtual Machine? (y/n) [default: y]: ${RESET}"
read -rp "" response
response=${response:-y} # Default to 'y' if the user presses Enter without input

if [[ ! "$response" =~ ^[Yy]$ ]]; then
  echo -e "${MAGENTA}KVM installation skipped. Proceeding with the setup.${RESET}" && sleep 1
else
  echo -e "${CYAN}KVM installation will begin now...${RESET}" && sleep 1

  # Install necessary packages for KVM and associated tools
  echo -e "${YELLOW}Installing KVM and required packages...${RESET}"
  sudo pacman -S --noconfirm qemu-full qemu-img libvirt virt-install virt-manager virt-viewer spice-vdagent edk2-ovmf dnsmasq swtpm guestfs-tools libosinfo tuned

  # Ensure system is ready for virtualization (nested virtualization check)
  echo -e "${YELLOW}Checking for hardware virtualization support...${RESET}"
  if ! grep -qE '(vmx|svm)' /proc/cpuinfo; then
    echo -e "${RED}Error: Your CPU does not support virtualization or it's disabled in BIOS. Please enable virtualization in BIOS settings.${RESET}" && sleep 2
  fi

  # Enable and start the libvirt service
  echo -e "${YELLOW}Starting libvirt service...${RESET}"
  sudo systemctl enable --now libvirtd.service

  # Add user to the libvirt group to allow access to KVM
  echo -e "${YELLOW}Adding user '$USER' to the libvirt group...${RESET}"
  sudo usermod -aG libvirt "$USER"

  # Autostart libvirt network (default network for virtual machines)
  echo -e "${YELLOW}Configuring libvirt network to autostart...${RESET}"
  sudo virsh net-autostart default

  # Enable KVM with nested virtualization (useful for running KVM inside a VM)
  echo -e "${YELLOW}Enabling KVM with nested virtualization...${RESET}"
  sudo modprobe -r kvm_intel
  sudo modprobe kvm_intel nested=1

  # Verify KVM modules
  echo -e "${CYAN}Verifying KVM modules are loaded...${RESET}"
  lsmod | grep kvm

  echo -e "${GREEN}KVM installation completed.${RESET}" && sleep 2
  clear

  # Provide user with additional info and documentation
  echo -e "${CYAN}For VM sharing details, visit: https://docs.getutm.app/guest-support/linux/${RESET}" && sleep 1
  echo -e "${YELLOW}Please restart your machine to apply all changes.${RESET}"
fi
