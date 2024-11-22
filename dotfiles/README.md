# 🏠 dotfiles
My personal dotfiles configuration

The system creates symbolic links from this repository to the appropriate locations. 

## 🚀 Usage
To set up all symlinks for the configured applications:

```bash
ansible-playbook $HOME/automation/playbooks/configure_dotfiles_symlinks.yaml
```

This will automatically create all necessary symlinks for the configured applications.

## 📝 Adding a New Configuration

To add a new application's configuration to this system:

1. Add your configuration files to the `dotfiles` directory:
   ```bash
   # Example for a new app 'myapp'
   mkdir -p $HOME/automation/dotfiles/myapp
   cp -r $HOME/.config/myapp/ $HOME/automation/dotfiles/myapp/
   ```

2. Create a new symlink task file in `playbooks/tasks/`:
   ```bash
   create_myapp_symlink.yaml
   ```

3. Include the new task in `playbooks/configure_dotfiles_symlinks.yaml`:
   ```yaml
   - name: Include MyApp symlink tasks
     include_tasks:
       file: tasks/create_myapp_symlink.yaml
   ```

## 📋 Tasks templates

### 📁 Pattern (Multiple Files)

For applications that use multiple configuration files, use this pattern:

```yaml
---
- name: Ensure .config/myapp directory exists
  file:
    path: "{{ ansible_env.HOME }}/.config/myapp"
    state: directory
    mode: "0755"

- name: Find all files in myapp directory
  find:
    paths: "{{ ansible_env.HOME }}/automation/dotfiles/myapp"
    file_type: file
  register: myapp_files

- name: Create symlinks for all myapp files
  file:
    src: "{{ item.path }}"
    dest: "{{ ansible_env.HOME }}/.config/myapp/{{ item.path | basename }}"
    state: link
    force: true
  loop: "{{ myapp_files.files }}"
```

### 📄 Alternative Pattern (Single File)

For applications that use a single configuration file, use this pattern:

```yaml
---
- name: Create symlink for myapp config file
  file:
    src: "{{ ansible_env.HOME }}/automation/dotfiles/myapp.config"
    dest: "{{ ansible_env.HOME }}/myapp.config"
    state: link
    force: true
```