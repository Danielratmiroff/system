# 📦 AppImages Management

This directory contains your AppImage applications and their icons. Follow these simple steps to add new AppImages to your system!

## 📝 Directory Structure

```
appimages/
├── apps/     # Store your .AppImage files here
└── icons/    # Store your application icons here
```

## 🚀 Adding a New AppImage

1. 📥 **Copy the AppImage file**
   ```bash
   # Copy your AppImage to the apps directory
   cp /path/to/your/MyApp.AppImage $HOME/automation/appimages/apps/
   ```

2. 🎨 **Add the application icon**
   ```bash
   # Copy your icon (PNG format recommended) to the icons directory
   cp /path/to/your/myapp-icon.png $HOME/automation/appimages/icons/
   ```

3. 🔄 **Run the installation playbook**
   ```bash
   # This will create desktop entries for all your AppImages
   ansible-playbook $HOME/automation/playbooks/install_local_app_images.yaml
   ```

## ✨ The playbook will:
- Create desktop entries for your AppImages
- Make them accessible from your application launcher
- Ensure proper permissions
- Set up icons for better visibility
