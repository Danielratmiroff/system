#!/bin/bash

# migrate this to python

set -e

# Install Nvidia drivers 

echo "# Updating the system"
sudo apt update -y
sudo apt upgrade -y

echo "# Current Nvidia driver installed:"
nvidia-smi

if [ $# -eq 0 ]; then
  echo "# No step argument supplied, starting from step 1..."
  fi

  elif [ $1 -eq 1 ]; then
    echo "# Installing from source"
    install_from_source

  elif [ $1 -eq 2 ]; then
    echo "# Installing from apt"
    sudo ubuntu-drivers autoinstall
    echo "# Ready to reboot"
    exit 0

  else
    echo "# Wrong argument supplied"
    echo "# Please use 1 or 2"
    exit 1
  fi

step_one() {
    read -r "# Do you want to install from source? (y/n)" source

    if [ $source == "y" ]; then
      echo "# Installing from source"
      install_from_source
      else
        echo "# Autoinstalling from apt"
        sudo ubuntu-drivers autoinstall
        echo "# Ready to reboot"
        exit 0
    exit 0
}

install_from_source() {
  lspci -nn | grep VGA
  find_driver()

  echo "# Disabling Nouveau"
  sudo bash -c "echo blacklist nouveau > /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
  sudo bash -c "echo options nouveau modeset=0 >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf"

  echo "# Updating initial RAM filesystem"
  sudo update-initramfs -u


  echo "### Step 1/3 is done ###"
  echo "# Reboot and run the script again"
  echo "# with number 2 as argument!!"
  echo "# Ready to reboot"
}

find_driver() {
  ls -l $HOME/system/drivers/NVIDIA*.run

  if $? -eq 0; then
    echo "# Driver found"
    exit 0

  else
    echo "# Driver not found"
    echo "# Download the right driver from there: https://www.nvidia.com/Download/index.aspx"
    exit 1
  fi
}
