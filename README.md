# 🚀 Personal System Automation

Welcome to my personal system automation repository! 

This project helps me maintain a consistent development environment across different machines using Ansible playbooks and dotfiles.

## 📋 Prerequisites

### Installing Ansible
```bash
sudo apt update
sudo apt install -y ansible
```

### Installing Ansible Dependencies
```bash
# Install required collections
ansible-galaxy collection install community.general
```

## 🎯 Adding a New Target Host

```bash
sudo vim $HOME/automation/config/hosts.ini
```

## 📦 Managing AppImages

### Adding a New AppImage

1. Copy AppImage to apps directory
```bash
# $HOME/automation/appimages/apps/
```

2. Copy icon to icons directory
```bash
# $HOME/automation/appimages/icons/
```

## 🛠️ Main Features

### 1. Dotfiles Management
```bash
# Set up all dotfile symlinks
ansible-playbook playbooks/configure_dotfiles_symlinks.yaml
```
See the [dotfiles README](dotfiles/README.md) for more details.

### 2. AppImage Management
```bash
# Install local AppImages
ansible-playbook playbooks/install_local_app_images.yaml
```
See the [appimages README](appimages/README.md) for more details.

### 3. Install Ubuntu packages
```bash
# Install packages
ansible-playbook playbooks/packages_ubuntu_install.yaml
```

### 4. Shell Configuration
```bash
# Install fish plugins
ansible-playbook playbooks/configure_fish_shell.yaml
```
### 5. Nerd Fonts
```bash
# Install nerd fonts
ansible-playbook playbooks/nerdfonts_install.yaml
```