if status is-interactive
    # Commands to run in interactive sessions can go here
end

source $HOME/automation/.secrets
set -g -x fish_greeting ''
set -g -x GO111MODULE on
set -g theme_powerline_fonts no
set -g JAVA_HOME /usr/lib/jvm/java-17-openjdk-amd64
set -g EDITOR vim

# -------------------
# Theme config
# -------------------
source $HOME/automation/dotfiles/fish/theme_bobthefish.fish
set -g -x theme_color_scheme solarized-dark

# User distinction for Claude
if test "$USER" = "claude"
    set -g theme_display_user yes
end

# Display current user as a small hint at the beginning of the prompt
function fish_mode_prompt
    set_color brblack
    echo -n "[$USER] "
    set_color normal
end

# Set wezterm user variable for user detection
# This allows wezterm to know which user the shell is running as
function __wezterm_set_user_var --on-event fish_prompt
    if test -n "$WEZTERM_PANE"
        printf "\033]1337;SetUserVar=%s=%s\007" "SHELL_USER" (echo -n $USER | base64)
    end
end

# -------------------
# Aliases 
# -------------------
alias nv nvim
alias vim nvim

alias cursor '$HOME/automation/appimages/apps/cursor*AppImage'
alias cursorcli 'cursor-agent'
#alias fd (which fdfind)

# AI stuff
alias claude-vm '$HOME/automation/playbooks/files/claude-worker-vm/claude-vm'
alias ai 'claude-vm'
alias aicd 'cd $HOME/code/test/'
alias aicode='cursor --remote ssh-remote+claude-vm /home/ubuntu/code/'

# Win VM
alias win_console 'lxc console win11 --type=vga'
alias win_start 'lxc start win11 --console=vga'

# Navigation
alias rm 'rm -i'
alias .. 'cd ..'
alias ... 'cd .. && cd ..'
alias cda 'cd $HOME/automation'
alias dot 'cd $HOME/automation/dotfiles/'
alias cdd 'cd $HOME/code/bycs-messenger-android/'
alias cdk 'cd $HOME/code/keycloakify-projects/'
alias cds 'cd $HOME/.ssh/'
alias cdt 'cd $HOME/code/tududi/'
alias edit 'nv $HOME/automation/dotfiles/fish/config.fish'
alias term 'nv $HOME/automation/dotfiles/wezterm.lua'
alias hotk 'nv $HOME/automation/dotfiles/qtile/config.py'

# File listing
alias ls 'eza --icons'
alias la 'eza -a --icons'
alias ld 'eza -TD --icons'
alias lda 'eza -TDa --icons'
alias ll 'eza -lT -g --sort=type --icons --level=1 --no-user'
alias lll 'eza -lT -g --sort=type --icons --level=2 --no-user'
alias llll 'eza -lT -g --sort=type --icons --level=3 --no-user'
alias lla 'eza -alT -g --sort=type --icons --level=1 --no-user --octal-permissions'
alias llla 'eza -alT -g --sort=type --icons --level=2 --no-user --octal-permissions'
alias lllla 'eza -alT -g --sort=type --icons --level=3 --no-user --octal-permissions'

# Extras
alias catp='batcat --paging=never'
alias cat='batcat --style=plain --paging=never'
alias ips='ip -c -br addr'
alias del='trash -vrf'
alias py='python3'
alias venv='source ./venv/bin/activate.fish'
alias po='poetry'


# Multipass
alias mp='multipass'

# Kubernetes
alias minik='minikube'
alias kubectl='minikube kubectl --'
alias k='kubectl'
kubectl completion fish | source

# Git
alias g='git'
alias ga='git add -A'
alias gc='git commit -m '
alias gp='git push origin '
alias gt='git tag -a '

# abbr -a gch 'git checkout'

# Play
alias gobuild='go build -o termi'

# -------------------
# Helper functions
# -------------------

# Sonar android project
function sonar
    ./gradlew sonar
end

function cw --wraps=claude-wt --description 'alias cw=claude-wt'
    command claude-wt $argv
end

# Ansible
function ap --wraps=ansible-playbook --description 'alias ap=ansible-playbook'
    ansible-playbook $HOME/automation/$argv
end

function sap --wraps=ansible-playbook --description 'alias sap=ansible-playbook -K'
    ansible-playbook -K $HOME/automation/$argv
end

# Git
function gl
    glab $argv
end
complete --wraps='glab' gl

function gchm
    git fetch origin master && git checkout -b $argv[1] origin/master
end

function gch
    git checkout $argv
end
complete --wraps='git checkout' gch

function ga
    git add -A
end
complete --wraps='git add -A' ga

function gac
    git add -A
    git commit -m "$argv"
end


function gcp
    git commit -m "$argv" && git push origin
end

function gacp
    git add -A
    git commit -m "$argv" && git push origin
end

function clean_gitignore
    git rm -r --cached .
    git add -A
    git commit -m ".gitignore is now working"
    echo "## Deleted git cache and committed the changes"
end

# Kubernetes
function kx
    if set -q argv[1]
        kubectl config use-context $argv[1]
    else
        kubectl config current-context
    end
end

function kn
    if set -q argv[1]
        kubectl config set-context --current --namespace $argv[1]
    else
        kubectl config view --minify | grep namespace | cut -d" " -f6
    end
end

function docker_clean
    docker rm (docker ps -aq)
    docker stop (docker ps -aq)
    docker kill (docker ps -aq)
    docker system prune -af --volumes
    docker rmi (docker images -aq)
    docker image prune -af
end

# Start projects GO env with Direnv
function setgoenv
    echo "export GOPATH=(pwd)" >>.envrc
    direnv allow .
end
function mkcd
    mkdir $argv
    cd $argv
end

function ecopy
  echo "$argv" | copy
end

function copy
    xclip -selection clipboard
end

function source_config
    source $HOME/automation/dotfiles/fish/config.fish
end

function lsc --description 'Find files and copy closest match path to clipboard'
    if not set -q argv[1]
        echo "Usage: lsc <pattern>"
        return 1
    end

    # Find all matches, sort by path length (closest first)
    set -l matches (find . -iname "*$argv[1]*" 2>/dev/null | awk '{print length, $0}' | sort -n | cut -d' ' -f2-)

    if test -z "$matches"
        echo "No matches found for: $argv[1]"
        return 1
    end

    # Get the closest (shortest path) match
    set -l closest $matches[1]
    set -l full_path (realpath "$closest")

    # Copy to clipboard
    echo "$full_path" | copy

    # Show all matches
    echo "Matches:"
    for match in $matches
        if test "$match" = "$closest"
            echo "  ✓ $match"
        else
            echo "    $match"
        end
    end

    echo ""
    echo "Copied: $full_path"
end

function fish_remove_path
    if set -l ind (contains -i -- $argv $fish_user_paths)
        set -e fish_user_paths[$ind]
    end
end

jump shell fish | source

# -------------------
# Start/Stop functions
# -------------------

function android_studio
    set cmd $argv[1]

    switch $cmd
        case start
            pkill java
            /snap/bin/android-studio
        case stop
            pkill java
            echo "Android Studio stopped"
        case '*'
            echo "Unknown command '$cmd'"
    end
end

function killport
    if test (count $argv) -eq 0
        echo "Usage: killport <port>"
        return 1
    end
    set -l pid (lsof -ti:$argv[1])
    if test -n "$pid"
        kill -9 $pid
        echo "Killed process on port $argv[1]"
    else
        echo "No process found on port $argv[1]"
    end
end

# -------------------
# Set Path Variable
# -------------------
function set_path_variables
    fish_add_path bin
    fish_add_path '~/bin'
    fish_add_path '~/.local/bin/'
    fish_add_path '$JAVA_HOME/bin'
    #fish_add_path /home/daniel/code/networkmanager-dmenu/networkmanager_dmenu

    # Go stuff
    fish_add_path '/usr/local/go-1.18/bin/'
    fish_add_path '$HOME/go/bin'
    fish_add_path '$HOME/go'
    fish_add_path '$GOPATH/bin'
end



# -------------------
# Keybindings
# -------------------
function fish_user_key_bindings
    #bind \ci peco_run_prompt_ai
    #bind \ca peco_select_automation_script # Bind for peco change directory to Ctrl+F
    #bind \cr peco_select_history # Bind for peco select history to Ctrl+R
    bind \ca fzf_select_automation_script # Bind for peco select history to Ctrl+R
    bind \cf fzf_select_cd # Bind for peco change directory to Ctrl+F
    bind \co fzf_find_file_nvim
end


# -------------------
# Plugin's functions
# -------------------
function fzf_select_automation_script
    set -l query (commandline)
    set -l fzf_flags --layout=reverse --height 40% --border
    if test -n "$query"
        set fzf_flags $fzf_flags --query "$query"
    end
    set -l automation_dir "$HOME/automation/playbooks/"
    set -l hosts_file "$HOME/automation/config/hosts.ini" # Hosts file for ansible
    set -l max_depth 1

    set -l selected_file (find $automation_dir -maxdepth $max_depth -not -path '*/\.*' -type f -printf '%P\n' | fzf $fzf_flags)

    if test -n "$selected_file"
        # Choose the command based on the extension
        set -l extension (string split "." $selected_file)[-1]
        if test "$extension" = sh
            echo "Running $selected_file..."
            /usr/bin/bash "$automation_dir/$selected_file"
        else if test "$extension" = yml -o "$extension" = yaml
            # Choose the host to run the script on
            set -l selected_host (grep -oP '\[\K[^]]+' $hosts_file | fzf $fzf_flags)
            if test -n "$selected_host"
                echo "Running $selected_file on $selected_host..."
                ansible-playbook -K -i $hosts_file "$automation_dir/$selected_file" -l $selected_host
            else
                echo "No host selected. Operation cancelled."
            end
        else
            echo "Unknown file type: $selected_file with extension $extension"
        end
        commandline -f repaint
    end
end

function fzf_select_cd
    set -l query (commandline)
    set -l fzf_flags --height 40% --layout=reverse --border --prompt="CD> " \
        --preview 'tree -C {} | head -200' \
        --preview-window=right:50% \
        --color='bg+:#3B4252,bg:#2E3440,spinner:#81A1C1,hl:#616E88,fg:#D8DEE9,header:#616E88,info:#81A1C1,pointer:#81A1C1,marker:#81A1C1,fg+:#D8DEE9,prompt:#81A1C1,hl+:#81A1C1'

    if test -n "$query"
        set fzf_flags $fzf_flags --query "$query"
    end

    set -l max_depth $FZF_SELECT_CD_MAX_DEPTH

    if test -z "$max_depth"
        set max_depth 1
    end

    set -l selected_dir (find . -maxdepth $max_depth -type d | fzf $fzf_flags)

    if test -n "$selected_dir"
        cd $selected_dir
        commandline -f repaint
    end
end

function fzf_find_file_nvim
    set -l fzf_flags --height 40% --layout=reverse --border --prompt="🔍 " \
        --preview 'batcat --style=numbers --color=always --line-range :300 {}' \
        --preview-window=right:60% \
        --color='bg:#1E1E2E,fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC,marker:#F5E0DC,spinner:#F5E0DC,prompt:#CBA6F7,hl:#F38BA8' \
        --bind 'ctrl-d:preview-down,ctrl-u:preview-up,ctrl-f:preview-page-down,ctrl-b:preview-page-up'

    set -l file (fdfind --type f --hidden --follow --exclude .git | fzf $fzf_flags)
    if test -n "$file"
        nvim $file
    end
    commandline -f repaint
end

# pnpm
set -gx PNPM_HOME "/home/daniel/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
