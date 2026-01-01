# Firejail profile for Chromium in Claude Worker Fortress
# Restricts filesystem access while allowing browser functionality

include chromium-common.profile

# Whitelist for browser data
whitelist ${HOME}/.config/chromium
whitelist ${HOME}/.cache/chromium
whitelist ${HOME}/Downloads

# Read-only workspace access (can view files, not modify via browser)
read-only ${HOME}/workspace

# Deny access to sensitive directories
blacklist ${HOME}/.claude
blacklist ${HOME}/.ssh
blacklist ${HOME}/.gnupg
blacklist ${HOME}/projects
blacklist ${HOME}/fortress
blacklist ${HOME}/.local/share/claude

# Security hardening
caps.drop all
nonewprivs
noroot
seccomp
