#!/bin/bash
# Claude Worker Fortress Container Entrypoint
# Initializes network firewall and starts shell

set -euo pipefail

log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $*"
}

log_info "Starting Claude Worker Fortress container..."

# Initialize firewall (requires NET_ADMIN capability)
if [[ -x /usr/local/bin/init-firewall.sh ]]; then
    log_info "Initializing network firewall..."
    sudo /usr/local/bin/init-firewall.sh
else
    log_info "Firewall script not found, skipping..."
fi

log_info "========================================="
log_info "Claude Worker Fortress container ready"
log_info "Network: Whitelist-only (use init-firewall.sh)"
log_info "Claude:  claude --dangerously-skip-permissions"
log_info "========================================="

# Execute the command passed to the container
exec "$@"
