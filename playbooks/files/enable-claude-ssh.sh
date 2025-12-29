#!/bin/bash
# enable-claude-ssh - Grant claude user access to daniel's SSH agent and xhost

DANIEL_UID=1000
CLAUDE_USER=claude
CLAUDE_HOME="/home/${CLAUDE_USER}"
SOCKET_PATH="/run/user/${DANIEL_UID}/gnupg/S.gpg-agent.ssh"
BASH_ALIASES="${CLAUDE_HOME}/.bash_aliases"

# Add user to xhost
xhost +SI:localuser:claude

# Check if socket exists
if [[ ! -S "$SOCKET_PATH" ]]; then
    echo "Error: SSH agent socket not found at $SOCKET_PATH"
    echo "Is gpg-agent running? Try: gpg-connect-agent /bye"
    exit 1
fi

# Set ACLs for socket access
setfacl -m u:${CLAUDE_USER}:rx /run/user/${DANIEL_UID}
setfacl -m u:${CLAUDE_USER}:rx /run/user/${DANIEL_UID}/gnupg
setfacl -m u:${CLAUDE_USER}:rw "$SOCKET_PATH"

# Configure SSH_AUTH_SOCK in claude's environment (add if not present)
SSH_AUTH_LINE="export SSH_AUTH_SOCK=${SOCKET_PATH}"
if ! grep -q "^export SSH_AUTH_SOCK=" "$BASH_ALIASES" 2>/dev/null; then
    echo "$SSH_AUTH_LINE" >> "$BASH_ALIASES"
fi

echo "SSH agent access enabled for claude user"
echo "Socket: $SOCKET_PATH"
echo "SSH_AUTH_SOCK configured in: $BASH_ALIASES"
