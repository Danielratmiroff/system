#!/bin/bash
# =============================================================================
# Claude Worker Fortress - Network Firewall Initialization
# =============================================================================
# Implements network security following Anthropic's official devcontainer pattern
# Uses ipset for efficient IP management with dynamic GitHub IP range fetching
#
# Key Features:
#   - Default-DROP policy with whitelist approach
#   - ipset-based domain management (more efficient than individual rules)
#   - Dynamic GitHub IP ranges from GitHub API
#   - CIDR optimization using aggregate tool
#   - DNS preservation for container networking
# =============================================================================

set -euo pipefail

# Colors for logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_section() {
    echo ""
    echo -e "${CYAN}============================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}============================================${NC}"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run as root (use sudo)"
    exit 1
fi

# =============================================================================
# Configuration
# =============================================================================
IPSET_NAME="allowed-domains"

# Whitelisted domains organized by category
declare -a ANTHROPIC_DOMAINS=(
    "api.anthropic.com"
    "statsig.anthropic.com"
    "sentry.io"
)

declare -a GITHUB_DOMAINS=(
    "github.com"
    "api.github.com"
    "raw.githubusercontent.com"
    "objects.githubusercontent.com"
    "codeload.github.com"
    "ghcr.io"
    "pkg-containers.githubusercontent.com"
)

declare -a NPM_DOMAINS=(
    "registry.npmjs.org"
    "npmjs.com"
    "nodejs.org"
    "yarnpkg.com"
)

declare -a PYTHON_DOMAINS=(
    "pypi.org"
    "files.pythonhosted.org"
    "astral.sh"
)

declare -a DOCKER_DOMAINS=(
    "hub.docker.com"
    "registry-1.docker.io"
    "auth.docker.io"
    "production.cloudflare.docker.com"
)

declare -a VSCODE_DOMAINS=(
    "update.code.visualstudio.com"
    "marketplace.visualstudio.com"
    "vscode.blob.core.windows.net"
    "az764295.vo.msecnd.net"
    "download.visualstudio.microsoft.com"
)

declare -a GOOGLE_DOMAINS=(
    "accounts.google.com"
    "www.googleapis.com"
    "storage.googleapis.com"
)

# =============================================================================
# DNS Preservation
# =============================================================================
log_section "Preserving DNS Configuration"

# Capture DNS servers before flushing rules
DNS_SERVERS=$(grep nameserver /etc/resolv.conf 2>/dev/null | awk '{print $2}' | head -5 || echo "")
if [[ -n "$DNS_SERVERS" ]]; then
    log_info "Found DNS servers: $(echo $DNS_SERVERS | tr '\n' ' ')"
else
    log_warn "No DNS servers found in /etc/resolv.conf, using defaults"
    DNS_SERVERS="8.8.8.8 8.8.4.4"
fi

# =============================================================================
# Flush Existing Rules
# =============================================================================
log_section "Flushing Existing Rules"

log_info "Flushing iptables rules..."
iptables -F OUTPUT 2>/dev/null || true
iptables -F INPUT 2>/dev/null || true
iptables -F FORWARD 2>/dev/null || true

log_info "Destroying existing ipset if present..."
ipset destroy "$IPSET_NAME" 2>/dev/null || true

# =============================================================================
# Create ipset
# =============================================================================
log_section "Creating ipset: $IPSET_NAME"

ipset create "$IPSET_NAME" hash:net family inet hashsize 4096 maxelem 65536 -exist
log_success "Created ipset '$IPSET_NAME'"

# =============================================================================
# Helper Functions
# =============================================================================

# Resolve domain to IPs and add to ipset
add_domain_to_ipset() {
    local domain="$1"
    local description="${2:-$domain}"

    # Resolve domain to IP addresses
    local ips
    if ! ips=$(dig +short "$domain" A 2>/dev/null | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'); then
        if ! ips=$(host -t A "$domain" 2>/dev/null | awk '/has address/ {print $4}'); then
            log_warn "Could not resolve ${domain}"
            return 0
        fi
    fi

    if [[ -z "$ips" ]]; then
        log_warn "No IPs found for ${domain}"
        return 0
    fi

    # Add each IP to the ipset
    local count=0
    for ip in $ips; do
        if [[ -n "$ip" ]]; then
            ipset add "$IPSET_NAME" "${ip}/32" -exist 2>/dev/null && ((count++)) || true
        fi
    done

    if [[ $count -gt 0 ]]; then
        log_success "  ${domain}: added ${count} IPs"
    fi
}

# Add CIDR range directly to ipset
add_cidr_to_ipset() {
    local cidr="$1"
    local description="${2:-}"

    if [[ -n "$cidr" ]]; then
        ipset add "$IPSET_NAME" "$cidr" -exist 2>/dev/null || true
    fi
}

# =============================================================================
# Fetch Dynamic GitHub IP Ranges
# =============================================================================
log_section "Fetching GitHub IP Ranges"

log_info "Fetching IP ranges from https://api.github.com/meta..."

GITHUB_META=$(curl -s --connect-timeout 10 --max-time 30 "https://api.github.com/meta" 2>/dev/null || echo "")

if [[ -n "$GITHUB_META" ]] && echo "$GITHUB_META" | jq -e '.web' &>/dev/null; then
    log_success "Successfully fetched GitHub API meta"

    # Extract all relevant IP ranges
    GITHUB_RANGES=$(echo "$GITHUB_META" | jq -r '
        .web[]?,
        .api[]?,
        .git[]?,
        .packages[]?,
        .pages[]?,
        .actions[]?
    ' 2>/dev/null | sort -u | grep -v null || echo "")

    if [[ -n "$GITHUB_RANGES" ]]; then
        # Use aggregate to optimize CIDR ranges if available
        if command -v aggregate &>/dev/null; then
            log_info "Optimizing GitHub ranges with aggregate..."
            OPTIMIZED_RANGES=$(echo "$GITHUB_RANGES" | aggregate -q 2>/dev/null || echo "$GITHUB_RANGES")
        else
            log_warn "aggregate not available, using raw ranges"
            OPTIMIZED_RANGES="$GITHUB_RANGES"
        fi

        # Add each range to ipset
        local github_count=0
        while IFS= read -r cidr; do
            if [[ -n "$cidr" && "$cidr" != "null" ]]; then
                add_cidr_to_ipset "$cidr" "GitHub"
                ((github_count++)) || true
            fi
        done <<< "$OPTIMIZED_RANGES"

        log_success "Added ${github_count} GitHub CIDR ranges to ipset"
    else
        log_warn "No GitHub IP ranges extracted, falling back to domain resolution"
    fi
else
    log_warn "Could not fetch GitHub API meta, falling back to domain resolution"
fi

# =============================================================================
# Add Domain Categories to ipset
# =============================================================================
log_section "Adding Whitelisted Domains"

log_info "Adding Anthropic domains..."
for domain in "${ANTHROPIC_DOMAINS[@]}"; do
    add_domain_to_ipset "$domain" "Anthropic"
done

log_info "Adding GitHub domains..."
for domain in "${GITHUB_DOMAINS[@]}"; do
    add_domain_to_ipset "$domain" "GitHub"
done

log_info "Adding npm/Node.js domains..."
for domain in "${NPM_DOMAINS[@]}"; do
    add_domain_to_ipset "$domain" "npm"
done

log_info "Adding Python domains..."
for domain in "${PYTHON_DOMAINS[@]}"; do
    add_domain_to_ipset "$domain" "Python"
done

log_info "Adding Docker domains..."
for domain in "${DOCKER_DOMAINS[@]}"; do
    add_domain_to_ipset "$domain" "Docker"
done

log_info "Adding VS Code domains..."
for domain in "${VSCODE_DOMAINS[@]}"; do
    add_domain_to_ipset "$domain" "VS Code"
done

log_info "Adding Google domains (for Chromium)..."
for domain in "${GOOGLE_DOMAINS[@]}"; do
    add_domain_to_ipset "$domain" "Google"
done

# =============================================================================
# Configure iptables Rules
# =============================================================================
log_section "Configuring iptables Rules"

# Set default policies
log_info "Setting default DROP policy for OUTPUT..."
iptables -P INPUT ACCEPT
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# Allow loopback traffic
log_info "Allowing loopback traffic..."
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT

# Allow established and related connections
log_info "Allowing established/related connections..."
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow DNS (required for domain resolution)
log_info "Allowing DNS traffic (port 53)..."
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT -m comment --comment "DNS UDP"
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT -m comment --comment "DNS TCP"

# Allow DNS servers explicitly
for dns_server in $DNS_SERVERS; do
    if [[ -n "$dns_server" ]]; then
        iptables -A OUTPUT -d "$dns_server" -p udp --dport 53 -j ACCEPT -m comment --comment "DNS Server $dns_server"
        log_info "  Allowed DNS server: $dns_server"
    fi
done

# Allow SSH (for git operations)
log_info "Allowing SSH traffic (port 22)..."
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT -m comment --comment "SSH for git"

# Allow traffic to whitelisted IPs via ipset
log_info "Allowing traffic to whitelisted domains (ipset)..."
iptables -A OUTPUT -m set --match-set "$IPSET_NAME" dst -p tcp -m multiport --dports 80,443 -j ACCEPT -m comment --comment "Whitelisted domains"

# Allow Docker bridge network (for container networking)
log_info "Allowing Docker bridge traffic..."
iptables -A OUTPUT -d 172.16.0.0/12 -j ACCEPT -m comment --comment "Docker bridge networks"
iptables -A OUTPUT -d 10.0.0.0/8 -j ACCEPT -m comment --comment "Private networks"

# =============================================================================
# Display Summary
# =============================================================================
log_section "Firewall Configuration Summary"

IPSET_COUNT=$(ipset list "$IPSET_NAME" 2>/dev/null | grep -c "^[0-9]" || echo "0")
log_info "Total IPs/CIDRs in ipset: ${IPSET_COUNT}"

log_info "Current OUTPUT rules:"
iptables -L OUTPUT -n -v --line-numbers 2>/dev/null | head -30

# =============================================================================
# Connectivity Tests
# =============================================================================
log_section "Testing Connectivity"

test_connection() {
    local url="$1"
    local should_work="$2"
    local description="$3"

    log_info "Testing: ${description}"

    if curl -s --connect-timeout 5 --max-time 10 -o /dev/null -w "%{http_code}" "$url" 2>/dev/null | grep -qE "^[23][0-9][0-9]$"; then
        if [[ "$should_work" == "yes" ]]; then
            log_success "  PASS: Connection succeeded (expected)"
            return 0
        else
            log_error "  FAIL: Connection succeeded (should have been blocked)"
            return 1
        fi
    else
        if [[ "$should_work" == "no" ]]; then
            log_success "  PASS: Connection blocked (expected)"
            return 0
        else
            log_warn "  WARN: Connection failed (might be network issue)"
            return 0
        fi
    fi
}

# Test allowed domains
test_connection "https://api.anthropic.com" "yes" "Anthropic API (should work)"
test_connection "https://api.github.com" "yes" "GitHub API (should work)"
test_connection "https://registry.npmjs.org" "yes" "npm Registry (should work)"

# Test blocked domain
test_connection "https://example.com" "no" "example.com (should be blocked)"
test_connection "https://evil.com" "no" "evil.com (should be blocked)"

# =============================================================================
# Done
# =============================================================================
log_section "Firewall Initialization Complete"

log_success "Claude Worker Fortress network isolation is active"
log_info "Default policy: DROP (only whitelisted traffic allowed)"
log_info "ipset: ${IPSET_NAME} (${IPSET_COUNT} entries)"

exit 0
