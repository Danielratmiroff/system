#!/bin/bash

# This script is for installing Nvidia drivers on Ubuntu 20.04
set -e

# ----------------
# Variables
# ----------------
DRIVER_FILE=$HOME/system/drivers/NVIDIA*.run

# ----------------
# Help section
# ----------------
help_function() {
  echo "# Usage: ./nvidia_drivers_install.sh [step]"
  echo "# Step 1: Install from source"
  echo "# Step 2: Disable display manager"
  echo "# Step 3: Install the driver"
}

cmdline_space() {
  echo "-------------------"
}

# ----------------
# Step 1 
# ----------------
execute_step_one() {
  cmdline_space
  echo "Installing Nvidia drivers"
  read -r -p "# Do you want to install from source? (y/n) -- (not recommended)" install_source

  if [ $install_source == "y" ]; then
    echo "# Installing from source"
    install_from_source
  else
    echo "# Installing automatically"
    auto_install
  fi

  exit 0
}

auto_install() {
  cmdline_space
  echo "# Checking displays"
  sudo lshw -c display

  echo "# Adding repository"
  sudo add-apt-repository ppa:graphics-drivers
  sudo apt-get update -y

  echo "# Checking devices and installing the driver"
  ubuntu-drivers devices
  sudo ubuntu-drivers autoinstall
}

install_from_source() {
  lspci -nn | grep VGA # Check nvidia model

  cmdline_space
  is_driver_available

  configure_os_before_install

  cmdline_space
  echo "### Step 1/3 ###"
  echo "# Ready to reboot"
}

configure_os_before_install() {
  echo "# Disabling nouveau"

  sudo bash -c "echo blacklist nouveau > /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
  sudo bash -c "echo options nouveau modeset=0 >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf"

  echo "# Regenerating initial RAM filesystem"
  sudo update-initramfs -u
}

is_driver_available() {
  files=( $DRIVER_FILE )

  if [ -e "${files[0]}" ]; then
    echo "# Driver found"

  else
    echo "# Driver not found"
    echo "# Download the right driver from there: https://www.nvidia.com/Download/index.aspx"
    exit 1
  fi
}

# ----------------
# Step 2
# ----------------
execute_step_two() {
  cmdline_space
  echo "# Disabling display manager"
  echo "##### CAUTION: Rebooting will be necessary #####"
  sleep 5
  sudo systemctl stop display-manager.service
  exit 0
}

# ----------------
# Step 3
# ----------------
execute_step_three() {
  cmdline_space
  echo "# Starting installation..."
  sleep 3
  sudo sh $DRIVER_FILE
  exit 0
}

# ----------------
# Script
# ----------------
if [ $# -eq 0  ]; then
  echo "### No step argument provided, please provide a step number"
  help_function
fi

if [ $1 == "-h" ] || [ $1 == "--help" ]; then
  echo "# This script is for installing Nvidia drivers on Ubuntu 20.04"
  help_function
  exit 0
fi

if (( $1 == 1)); then
  echo "# Updating the system"
  sudo apt update -y
  sudo apt upgrade -y

  execute_step_one

elif (( $1 == 2)); then
  execute_step_two

elif (( $1 == 3)); then
  execute_step_three

else
  echo "# Wrong argument supplied"
  help_function
  exit 1
fi
