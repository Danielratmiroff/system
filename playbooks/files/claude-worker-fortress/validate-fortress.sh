#!/bin/bash
# Claude Worker Fortress - Post-Deployment Validation Script
# Run this script after executing setup_claude_worker_fortress.yml
# Usage: sudo ./validate-fortress.sh

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

log_pass() { echo -e "${GREEN}[PASS]${NC} $1"; ((PASS++)); }
log_fail() { echo -e "${RED}[FAIL]${NC} $1"; ((FAIL++)); }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; ((WARN++)); }
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }

echo "========================================="
echo "Claude Worker Fortress Validation Script"
echo "========================================="
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root (use sudo)"
    exit 1
fi

# Section 1: Prerequisites
log_info "Section 1: System Prerequisites"
echo "---"

for pkg in bubblewrap uidmap dbus-user-session fuse-overlayfs slirp4netns apparmor apparmor-utils acl curl git; do
    if dpkg -l "$pkg" &>/dev/null; then
        log_pass "Package '$pkg' is installed"
    else
        log_fail "Package '$pkg' is NOT installed"
    fi
done

if which bwrap &>/dev/null; then
    log_pass "bubblewrap binary (bwrap) is available"
else
    log_fail "bubblewrap binary (bwrap) is NOT available"
fi

if aa-status --enabled &>/dev/null; then
    log_pass "AppArmor is enabled"
else
    log_fail "AppArmor is NOT enabled"
fi
echo ""

# Section 2: User Configuration
log_info "Section 2: User Configuration"
echo "---"

if id claude_worker &>/dev/null; then
    log_pass "User 'claude_worker' exists"
else
    log_fail "User 'claude_worker' does NOT exist"
fi

if grep -q "^claude_worker:" /etc/passwd 2>/dev/null; then
    SHELL=$(grep "^claude_worker:" /etc/passwd | cut -d: -f7)
    if [[ "$SHELL" == "/bin/bash" ]]; then
        log_pass "User 'claude_worker' has bash shell"
    else
        log_warn "User 'claude_worker' shell is '$SHELL' (expected /bin/bash)"
    fi
fi

if grep -q "^claude_worker:!" /etc/shadow 2>/dev/null || grep -q "^claude_worker:\*" /etc/shadow 2>/dev/null; then
    log_pass "User 'claude_worker' password is locked"
else
    log_warn "User 'claude_worker' password may not be locked"
fi

# Check user cannot sudo
if sudo -u claude_worker -l 2>&1 | grep -q "not allowed to run sudo"; then
    log_pass "User 'claude_worker' cannot use sudo"
elif ! sudo -u claude_worker -l 2>&1 | grep -q "may run"; then
    log_pass "User 'claude_worker' has no sudo privileges"
else
    log_fail "User 'claude_worker' may have sudo access"
fi

# Check directories
for dir in .config .local/bin .local/share .cache workspace projects; do
    if [[ -d "/home/claude_worker/$dir" ]]; then
        log_pass "Directory '/home/claude_worker/$dir' exists"
    else
        log_fail "Directory '/home/claude_worker/$dir' does NOT exist"
    fi
done

if [[ -f "/home/claude_worker/.bashrc" ]]; then
    if grep -q "DOCKER_HOST" /home/claude_worker/.bashrc; then
        log_pass ".bashrc contains DOCKER_HOST configuration"
    else
        log_fail ".bashrc missing DOCKER_HOST configuration"
    fi
    if grep -q "XDG_RUNTIME_DIR" /home/claude_worker/.bashrc; then
        log_pass ".bashrc contains XDG_RUNTIME_DIR configuration"
    else
        log_fail ".bashrc missing XDG_RUNTIME_DIR configuration"
    fi
else
    log_fail ".bashrc does NOT exist"
fi
echo ""

# Section 3: Security Configuration
log_info "Section 3: Security Configuration"
echo "---"

if [[ -f "/etc/security/limits.d/99-claude-worker.conf" ]]; then
    log_pass "PAM limits file exists"
    if grep -q "nofile" /etc/security/limits.d/99-claude-worker.conf; then
        log_pass "PAM limits contains nofile setting"
    else
        log_fail "PAM limits missing nofile setting"
    fi
else
    log_fail "PAM limits file does NOT exist"
fi

if [[ -f "/etc/apparmor.d/claude-worker-fortress" ]]; then
    log_pass "AppArmor profile file exists"
else
    log_fail "AppArmor profile file does NOT exist"
fi

if aa-status 2>/dev/null | grep -q "claude-worker-fortress"; then
    if aa-status 2>/dev/null | sed -n '/profiles are in enforce mode/,/profiles are in complain mode/p' | grep -q "claude-worker-fortress"; then
        log_pass "AppArmor profile 'claude-worker-fortress' is in enforce mode"
    else
        log_warn "AppArmor profile exists but may not be in enforce mode"
    fi
else
    log_fail "AppArmor profile 'claude-worker-fortress' is NOT loaded"
fi
echo ""

# Section 4: Rootless Docker
log_info "Section 4: Rootless Docker"
echo "---"

if grep -q "^claude_worker:" /etc/subuid; then
    log_pass "Subordinate UIDs configured for claude_worker"
else
    log_fail "Subordinate UIDs NOT configured for claude_worker"
fi

if grep -q "^claude_worker:" /etc/subgid; then
    log_pass "Subordinate GIDs configured for claude_worker"
else
    log_fail "Subordinate GIDs NOT configured for claude_worker"
fi

if [[ -f "/var/lib/systemd/linger/claude_worker" ]]; then
    log_pass "Lingering enabled for claude_worker"
else
    log_fail "Lingering NOT enabled for claude_worker"
fi

if [[ -f "/home/claude_worker/.config/systemd/user/docker.service" ]]; then
    log_pass "Rootless docker service file exists"
else
    log_fail "Rootless docker service file does NOT exist"
fi

# Check if rootless Docker is running
CLAUDE_UID=$(id -u claude_worker 2>/dev/null || echo "")
if [[ -n "$CLAUDE_UID" && -S "/run/user/$CLAUDE_UID/docker.sock" ]]; then
    log_pass "Rootless Docker socket exists at /run/user/$CLAUDE_UID/docker.sock"
else
    log_warn "Rootless Docker socket not found (may need user login)"
fi
echo ""

# Section 5: ipset and Network Configuration
log_info "Section 5: ipset and Network Configuration"
echo "---"

# Check if ipset is available
if command -v ipset &>/dev/null; then
    log_pass "ipset command is available"
else
    log_fail "ipset command is NOT available"
fi

# Check if iptables is available
if command -v iptables &>/dev/null; then
    log_pass "iptables command is available"
else
    log_fail "iptables command is NOT available"
fi

# Check if aggregate tool is available (for CIDR optimization)
if command -v aggregate &>/dev/null; then
    log_pass "aggregate tool is available (CIDR optimization)"
else
    log_warn "aggregate tool is NOT available (optional but recommended)"
fi

# Check if jq is available (needed for GitHub API parsing)
if command -v jq &>/dev/null; then
    log_pass "jq command is available (GitHub API parsing)"
else
    log_fail "jq command is NOT available (needed for GitHub API)"
fi

# Test GitHub API accessibility (needed for dynamic IP ranges)
if curl -s --connect-timeout 5 --max-time 10 "https://api.github.com/meta" | jq -e '.web' &>/dev/null; then
    log_pass "GitHub API is accessible (for dynamic IP ranges)"
else
    log_warn "GitHub API not accessible (firewall will use fallback domain resolution)"
fi
echo ""

# Section 6: DevContainers CLI
log_info "Section 6: DevContainers CLI"
echo "---"

# Check if NVM is installed
if [[ -f "/home/claude_worker/.nvm/nvm.sh" ]]; then
    log_pass "NVM is installed"
else
    log_fail "NVM is NOT installed"
fi

# Check if Node.js is available via NVM
if sudo -u claude_worker bash -c 'export NVM_DIR="$HOME/.nvm"; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; node --version' &>/dev/null; then
    NODE_VERSION=$(sudo -u claude_worker bash -c 'export NVM_DIR="$HOME/.nvm"; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; node --version' 2>/dev/null)
    log_pass "Node.js is available (${NODE_VERSION})"
else
    log_fail "Node.js is NOT available"
fi

# Check if devcontainer CLI is installed
if sudo -u claude_worker bash -c 'export NVM_DIR="$HOME/.nvm"; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; devcontainer --version' &>/dev/null; then
    DC_VERSION=$(sudo -u claude_worker bash -c 'export NVM_DIR="$HOME/.nvm"; [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"; devcontainer --version' 2>/dev/null)
    log_pass "DevContainers CLI is installed (${DC_VERSION})"
else
    log_fail "DevContainers CLI is NOT installed"
fi

# Check fortress helper scripts
for script in fortress-init fortress-up fortress-exec; do
    if [[ -x "/home/claude_worker/.local/bin/$script" ]]; then
        log_pass "Helper script '$script' is installed and executable"
    else
        log_fail "Helper script '$script' is NOT installed or not executable"
    fi
done
echo ""

# Section 7: Fortress Template Files
log_info "Section 7: Fortress Template Files"
echo "---"

if [[ -d "/home/claude_worker/fortress" ]]; then
    log_pass "Fortress directory exists"
else
    log_fail "Fortress directory does NOT exist"
fi

if [[ -d "/home/claude_worker/fortress/template" ]]; then
    log_pass "Fortress template directory exists"
else
    log_fail "Fortress template directory does NOT exist"
fi

for file in Dockerfile devcontainer.json entrypoint.sh init-firewall.sh settings.json; do
    if [[ -f "/home/claude_worker/fortress/template/$file" ]]; then
        log_pass "Template file '$file' exists"
    else
        log_fail "Template file '$file' does NOT exist"
    fi
done

if [[ -x "/home/claude_worker/fortress/template/entrypoint.sh" ]]; then
    log_pass "entrypoint.sh is executable"
else
    log_fail "entrypoint.sh is NOT executable"
fi

if [[ -x "/home/claude_worker/fortress/template/init-firewall.sh" ]]; then
    log_pass "init-firewall.sh is executable"
else
    log_fail "init-firewall.sh is NOT executable"
fi
echo ""

# Section 8: Docker Image
log_info "Section 8: Docker Image (Pre-built)"
echo "---"

if [[ -n "$CLAUDE_UID" ]]; then
    if sudo -u claude_worker bash -c "export XDG_RUNTIME_DIR=/run/user/$CLAUDE_UID; export DOCKER_HOST=unix://\$XDG_RUNTIME_DIR/docker.sock; docker images --format '{{.Repository}}' 2>/dev/null" | grep -q "claude-fortress"; then
        log_pass "Docker image 'claude-fortress' exists"
    else
        log_warn "Docker image 'claude-fortress' not found (build may not have completed)"
    fi
else
    log_warn "Cannot check Docker image (claude_worker UID not found)"
fi
echo ""

# Section 9: Logging Infrastructure
log_info "Section 9: Logging Infrastructure"
echo "---"

if [[ -d "/var/log/claude-worker-fortress" ]]; then
    log_pass "Log base directory exists"
else
    log_fail "Log base directory does NOT exist"
fi

for dir in apparmor violations reports; do
    if [[ -d "/var/log/claude-worker-fortress/$dir" ]]; then
        log_pass "Log subdirectory '$dir' exists"
    else
        log_fail "Log subdirectory '$dir' does NOT exist"
    fi
done

if [[ -f "/etc/logrotate.d/claude-worker-fortress" ]]; then
    log_pass "Logrotate configuration exists"
else
    log_fail "Logrotate configuration does NOT exist"
fi

if [[ -x "/usr/local/bin/claude-worker-fortress-monitor.sh" ]]; then
    log_pass "Monitor script is installed and executable"
else
    log_fail "Monitor script is NOT installed or not executable"
fi

if [[ -x "/usr/local/bin/claude-worker-fortress-report.sh" ]]; then
    log_pass "Report script is installed and executable"
else
    log_fail "Report script is NOT installed or not executable"
fi
echo ""

# Section 10: Legacy Launch Script
log_info "Section 10: Legacy Launch Script"
echo "---"

if [[ -f "/home/claude_worker/start-fortress.sh" ]]; then
    log_pass "start-fortress.sh exists (legacy)"
    if [[ -x "/home/claude_worker/start-fortress.sh" ]]; then
        log_pass "start-fortress.sh is executable"
    else
        log_fail "start-fortress.sh is NOT executable"
    fi
else
    log_warn "start-fortress.sh does NOT exist (optional - use fortress-up instead)"
fi
echo ""

# Summary
echo "========================================="
echo "Validation Summary"
echo "========================================="
echo -e "${GREEN}PASSED:${NC} $PASS"
echo -e "${RED}FAILED:${NC} $FAIL"
echo -e "${YELLOW}WARNINGS:${NC} $WARN"
echo ""

if [[ $FAIL -eq 0 ]]; then
    echo -e "${GREEN}All critical checks passed!${NC}"
    echo ""
    echo "Next steps (DevContainers workflow):"
    echo "  1. Log in as claude_worker: sudo -u claude_worker -i"
    echo "  2. Initialize a project:    fortress-init ~/projects/my-project"
    echo "  3. Set VNC password:        export VNC_PASSWORD='your-secure-password'"
    echo "  4. Start the fortress:      cd ~/projects/my-project && fortress-up"
    echo "  5. Access VNC at:           http://127.0.0.1:6080"
    echo "  6. Run Claude inside:       fortress-exec claude"
    echo ""
    echo "Or use the legacy workflow:"
    echo "  1. Log in as claude_worker: sudo -u claude_worker -i"
    echo "  2. Set VNC password:        export VNC_PASSWORD='your-secure-password'"
    echo "  3. Start the fortress:      ./start-fortress.sh"
    exit 0
else
    echo -e "${RED}Some checks failed. Review the output above.${NC}"
    exit 1
fi
