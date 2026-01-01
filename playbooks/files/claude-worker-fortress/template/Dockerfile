# =============================================================================
# Claude Worker Fortress - CLI Development Container
# =============================================================================
# Extends Anthropic's official devcontainer for CLI-based development tasks.
#
# Features:
#   - Full Claude Code CLI environment
#   - Network isolation capabilities (iptables/ipset)
#   - Zsh with Powerlevel10k theme
#   - Git Delta for enhanced diffs
#   - GitHub CLI
# =============================================================================

FROM node:20

# -----------------------------------------------------------------------------
# Build Arguments
# -----------------------------------------------------------------------------
ARG CLAUDE_CODE_VERSION=latest
ARG GIT_DELTA_VERSION=0.18.2

# -----------------------------------------------------------------------------
# Environment Variables
# -----------------------------------------------------------------------------
ENV DEBIAN_FRONTEND=noninteractive

# -----------------------------------------------------------------------------
# Base System Packages
# -----------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Core utilities
    less \
    git \
    procps \
    sudo \
    fzf \
    zsh \
    man-db \
    unzip \
    gnupg2 \
    jq \
    nano \
    vim \
    curl \
    ca-certificates \
    # Network utilities
    iptables \
    ipset \
    iproute2 \
    dnsutils \
    aggregate \
    # Bubblewrap for Claude's internal native sandbox
    bubblewrap \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# GitHub CLI
# -----------------------------------------------------------------------------
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# Git Delta (syntax-highlighting pager for git)
# -----------------------------------------------------------------------------
RUN ARCH=$(dpkg --print-architecture) \
    && if [ "$ARCH" = "amd64" ]; then \
        DELTA_ARCH="x86_64"; \
    elif [ "$ARCH" = "arm64" ]; then \
        DELTA_ARCH="aarch64"; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi \
    && curl -fsSL "https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/delta-${GIT_DELTA_VERSION}-${DELTA_ARCH}-unknown-linux-gnu.tar.gz" \
        | tar -xz -C /tmp \
    && mv "/tmp/delta-${GIT_DELTA_VERSION}-${DELTA_ARCH}-unknown-linux-gnu/delta" /usr/local/bin/delta \
    && chmod +x /usr/local/bin/delta \
    && rm -rf /tmp/delta-*

# -----------------------------------------------------------------------------
# Zsh with Powerlevel10k Theme
# -----------------------------------------------------------------------------
RUN sh -c "$(curl -fsSL https://github.com/deluan/zsh-in-docker/releases/download/v1.2.1/zsh-in-docker.sh)" -- \
    -t https://github.com/romkatv/powerlevel10k \
    -p git \
    -p fzf \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-syntax-highlighting

# -----------------------------------------------------------------------------
# Claude Code CLI
# -----------------------------------------------------------------------------
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}

# -----------------------------------------------------------------------------
# User Configuration
# -----------------------------------------------------------------------------
# The 'node' user already exists in the node:20 base image
# Configure restricted sudo access (firewall script only) and shell
# Following Anthropic's security model - least privilege principle
RUN echo "node ALL=(ALL) NOPASSWD: /usr/local/bin/init-firewall.sh" >> /etc/sudoers.d/node \
    && chmod 0440 /etc/sudoers.d/node \
    && chsh -s /bin/zsh node

# -----------------------------------------------------------------------------
# Copy Scripts
# -----------------------------------------------------------------------------
COPY init-firewall.sh /usr/local/bin/init-firewall.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/init-firewall.sh \
    && chmod +x /usr/local/bin/entrypoint.sh

# -----------------------------------------------------------------------------
# Working Directory and User
# -----------------------------------------------------------------------------
WORKDIR /home/node/workspace
RUN chown -R node:node /home/node/workspace

# -----------------------------------------------------------------------------
# Entrypoint
# -----------------------------------------------------------------------------
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Default command - start interactive shell
CMD ["zsh"]
