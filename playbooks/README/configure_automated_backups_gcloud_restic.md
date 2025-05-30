# Automated Backups with Google Cloud Storage and Restic

This bash script configures automated backups using Google Cloud Storage and Restic

## Prerequisites

- Linux system with bash shell
- sudo privileges for package installation
- Google Cloud service account with Storage Admin permissions
- Google Cloud Storage bucket created for backups

## Setup

1. **Create a Google Cloud service account key file:**

   ```bash
   # Download the service account key JSON file from Google Cloud Console
   # and save it to a secure location (e.g., ~/.config/gcloud/service-account-key.json)
   ```

2. **Create a restic password file:**

   ```bash
   # Create a file containing your restic repository password
   echo "your-secure-password" > ~/.config/restic/password
   chmod 600 ~/.config/restic/password
   ```

3. **Set environment variables (optional):**
   ```bash
   export GOOGLE_BACKUP_PROJECT_ID="your-project-id"
   export GOOGLE_BACKUP_BUCKET_NAME="your-backup-bucket"
   export GOOGLE_APPLICATION_CREDENTIALS="~/.config/gcloud/service-account-key.json"
   export RESTIC_PASSWORD_FILE="~/.config/restic/password"
   ```

## Usage

### Run all tasks (default)

```bash
./configure_automated_backups_gcloud_restic.sh
```

### Run specific tasks

```bash
# Run only pre-flight checks
./configure_automated_backups_gcloud_restic.sh preflight

# Install dependencies only
./configure_automated_backups_gcloud_restic.sh install

# Configure services only
./configure_automated_backups_gcloud_restic.sh configure

# Perform backup only
./configure_automated_backups_gcloud_restic.sh backup

# Run repository maintenance only
./configure_automated_backups_gcloud_restic.sh maintenance
```

## Script Tasks

1. **Pre-flight checks:** Validates that required files exist
2. **Install dependencies:** Installs Google Cloud SDK and Restic
3. **Configure services:** Authenticates with Google Cloud and initializes Restic repository
4. **Perform backup:** Backs up the specified directory to Google Cloud Storage
5. **Maintain repository:** Cleans up old snapshots and checks repository integrity

## Configuration Parameters

The script will prompt for the following parameters:

- **Google Cloud project ID:** Your GCP project ID
- **Google Cloud Storage bucket name:** Bucket for storing backups
- **Service account key file path:** Path to your GCP service account JSON key
- **Restic password file path:** Path to file containing restic password
- **Repository path within bucket:** Subdirectory in the bucket (default: "backups")
- **Path to backup:** Directory to backup (default: "~")

## Security Considerations

- Store service account keys securely with restricted permissions
- Use strong passwords for Restic repositories
- Regularly rotate service account keys
- Monitor backup logs for any issues

## Automation

To run this script automatically, you can set up a cron job:

```bash
# Edit crontab
crontab -e

# Add entry to run daily at 2 AM
0 2 * * * /path/to/configure_automated_backups_gcloud_restic.sh backup
```

For automated runs, ensure all environment variables are set properly in your shell profile or systemd environment.
