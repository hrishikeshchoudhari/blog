#!/bin/bash

# Script to set up cron job for daily backups

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SCRIPT="$SCRIPT_DIR/run_backup.sh"

echo "Setting up cron job for daily backups..."

# Create a temporary file with the cron job
CRON_TMP=$(mktemp)

# Get existing crontab (ignore error if empty)
crontab -l 2>/dev/null > "$CRON_TMP" || true

# Check if backup job already exists
if grep -q "run_backup.sh" "$CRON_TMP"; then
    echo "Cron job already exists. Updating..."
    # Remove existing backup job
    grep -v "run_backup.sh" "$CRON_TMP" > "$CRON_TMP.new"
    mv "$CRON_TMP.new" "$CRON_TMP"
fi

# Add new cron job (2 AM daily)
echo "0 2 * * * $BACKUP_SCRIPT" >> "$CRON_TMP"

# Install the new crontab
crontab "$CRON_TMP"
rm "$CRON_TMP"

echo "Cron job installed successfully!"
echo "Backups will run daily at 2:00 AM"
echo ""
echo "To view your crontab: crontab -l"
echo "To remove the cron job: crontab -e (and delete the line)"
echo ""
echo "Manual backup command: $BACKUP_SCRIPT"