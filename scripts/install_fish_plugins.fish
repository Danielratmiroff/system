#!/usr/bin/env fish

function print_status
    set_color green
    echo ">>> $argv"
    set_color normal
end

function print_error
    set_color red
    echo "ERROR: $argv"
    set_color normal
end

# Check if Fish shell is installed
if not type -q fish
    print_error "Fish shell is not installed. Please install it first."
    exit 1
end

print_status "Installing Fisher..."
# Install Fisher
if not functions -q fisher
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
    fisher install jorgebucaran/fisher
    print_status "Fisher installed successfully!"
else
    print_status "Fisher is already installed."
end

print_status "Installing Oh My Fish..."
# Install Oh My Fish
if not test -d ~/.local/share/omf
    curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
    print_status "Oh My Fish installed successfully!"
else
    print_status "Oh My Fish is already installed."
end

if not functions -q nvm
    print_status "Installing nvm.fish..."
    fisher install jorgebucaran/nvm.fish
    print_status "nvm.fish installed successfully!"
else
    print_status "nvm.fish is already installed."
end

print_status "Installation completed successfully!"
print_status "Please restart your shell or run 'exec fish' to apply changes."
