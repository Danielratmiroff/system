#!/bin/bash

# Configure automated backups with gcloud and restic
# Bash script equivalent of the Ansible playbook

set -euo pipefail # Exit on error, undefined vars, and pipe failures

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1\n"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to prompt for user input with default values
prompt_with_default() {
    local prompt_text="$1"
    local default_value="$2"
    local var_name="$3"

    if [[ -n "$default_value" ]]; then
        read -p "$prompt_text [$default_value]: " user_input
        if [[ -z "$user_input" ]]; then
            user_input="$default_value"
        fi
    else
        read -p "$prompt_text: " user_input
        while [[ -z "$user_input" ]]; do
            log_error "This field is required."
            read -p "$prompt_text: " user_input
        done
    fi

    eval "$var_name='$user_input'"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install packages (supports apt-based systems)
install_package() {
    local package="$1"

    if command_exists "$package"; then
        log_info "$package is already installed"
        return 0
    fi

    log_info "Installing $package..."

    if command_exists apt-get; then
        sudo apt-get update
        sudo apt-get install -y "$package"
    fi

    log_success "$package installed successfully"
}

# Pre-flight checks
preflight_checks() {
    log_info "Running pre-flight checks..."

    # Check if restic password file exists
    if [[ ! -f "$RESTIC_PASSWORD_FILE" ]]; then
        log_error "Restic password file not found at $RESTIC_PASSWORD_FILE. Please create it."
        exit 1
    fi

    log_success "Pre-flight checks passed"
}

# Set up environment variables for restic and gcloud
setup_environment() {
    log_info "Setting up environment variables..."

    export RESTIC_PASSWORD_FILE="$RESTIC_PASSWORD_FILE"
    export GOOGLE_PROJECT_ID="$GCLOUD_PROJECT_ID"

    log_success "Environment variables configured"
}

# Install dependencies
install_dependencies() {
    log_info "Installing dependencies..."

    # Install gcloud SDK
    if ! command_exists gcloud; then
        log_info "Installing Google Cloud SDK..."
        # Add Google Cloud SDK repository
        echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
        curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
        sudo apt-get update
        install_package google-cloud-sdk
    fi

    # Install restic
    install_package restic

    log_success "Dependencies installed successfully"
}

# Configure gcloud and restic
configure_services() {
    log_info "Configuring gcloud and restic..."

    # Authenticate to Google Cloud with Service Account
    log_info "Authenticating to Google Cloud with service account..."
    gcloud auth activate-service-account --key-file="$GCLOUD_SERVICE_ACCOUNT_KEY_FILE"
    log_success "Google Cloud authentication successful"

    # Check if restic repository is initialized
    log_info "Checking if restic repository is initialized..."
    if ! restic -r "$RESTIC_REPOSITORY_URL" cat config >/dev/null 2>&1; then
        log_info "Initializing restic repository..."
        restic -r "$RESTIC_REPOSITORY_URL" init
        log_success "Restic repository initialized"
    else
        log_info "Restic repository already initialized"
    fi

    log_success "Services configured successfully"
}

# Perform backup
perform_backup() {
    log_info "Performing backup..."

    log_info "Backing up $PATH_TO_BACKUP to $RESTIC_REPOSITORY_URL..."

    if restic -r "$RESTIC_REPOSITORY_URL" backup "$PATH_TO_BACKUP"; then
        log_success "Backup completed successfully"
    else
        log_error "Backup failed"
        exit 1
    fi
}

# Maintain restic repository
maintain_repository() {
    log_info "Maintaining restic repository..."

    # Get list of snapshots before cleanup
    log_info "Getting list of snapshots..."
    restic -r "$RESTIC_REPOSITORY_URL" snapshots

    # Forget old snapshots
    log_info "Cleaning up old snapshots (keeping 3 yearly snapshots)..."
    restic -r "$RESTIC_REPOSITORY_URL" forget --keep-yearly 3 --prune

    # Check repository integrity
    log_info "Checking repository integrity..."
    if restic -r "$RESTIC_REPOSITORY_URL" check; then
        log_success "Repository integrity check passed"
    else
        log_error "Repository integrity check failed"
        exit 1
    fi

    log_success "Repository maintenance completed"
}

# Main function
main() {
    log_info "Starting automated backup configuration with gcloud and restic"

    # Collect user input
    log_info "Collecting configuration parameters..."

    prompt_with_default "Enter the Google Cloud project ID" "${GOOGLE_BACKUP_PROJECT_ID:-}" "GCLOUD_PROJECT_ID"
    prompt_with_default "Enter the Google Cloud Storage bucket name for backups" "${GOOGLE_BACKUP_BUCKET_NAME:-}" "GCLOUD_BUCKET_NAME"
    prompt_with_default "Enter the absolute path to the Google Cloud service account key file" "${GOOGLE_APPLICATION_CREDENTIALS:-}" "GCLOUD_SERVICE_ACCOUNT_KEY_FILE"
    prompt_with_default "Enter the absolute path to the restic password file" "${RESTIC_PASSWORD_FILE:-}" "RESTIC_PASSWORD_FILE"
    prompt_with_default "Enter the repository path within the GCS bucket" "${RESTIC_REPO_BUCKET_PATH:-backups}" "RESTIC_REPO_BUCKET_PATH"
    prompt_with_default "Enter the absolute path to the folder to backup" "${RESTIC_PATH_TO_BACKUP:-~}" "RESTIC_PATH_TO_BACKUP"

    # Set derived variables
    RESTIC_REPOSITORY_URL="gs:${GCLOUD_BUCKET_NAME}:/${RESTIC_REPO_BUCKET_PATH}"

    log_info "Configuration collected:"
    log_info "  Project ID: $GCLOUD_PROJECT_ID"
    log_info "  Bucket Name: $GCLOUD_BUCKET_NAME"
    log_info "  Service Account Key: $GCLOUD_SERVICE_ACCOUNT_KEY_FILE"
    log_info "  Restic Password File: $RESTIC_PASSWORD_FILE"
    log_info "  Repository URL: $RESTIC_REPOSITORY_URL"
    log_info "  Backup Path: $PATH_TO_BACKUP"

    # Execute tasks based on command line arguments or run all by default
    case "${1:-all}" in
    "preflight")
        preflight_checks
        ;;
    "install")
        install_dependencies
        ;;
    "configure")
        preflight_checks
        setup_environment
        configure_services
        ;;
    "backup")
        preflight_checks
        setup_environment
        perform_backup
        ;;
    "maintenance")
        preflight_checks
        setup_environment
        maintain_repository
        ;;
    "all")
        preflight_checks
        setup_environment
        install_dependencies
        configure_services
        perform_backup
        maintain_repository
        ;;
    *)
        log_error "Usage: $0 [preflight|install|configure|backup|maintenance|all]"
        log_info "  preflight   - Run pre-flight checks only"
        log_info "  install     - Install dependencies only"
        log_info "  configure   - Configure services only"
        log_info "  backup      - Perform backup only"
        log_info "  maintenance - Run repository maintenance only"
        log_info "  all         - Run all tasks (default)"
        exit 1
        ;;
    esac

    log_success "Script completed successfully!"
}

# Run main function with all arguments
main "$@"
