#!/bin/bash

# Sync backups to Google Drive using rclone (runs inside Docker)
# This script is called after successful backups

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
LOG_FILE="$PROJECT_ROOT/backups/logs/gdrive_sync_$(date +%Y-%m-%d).log"

echo "[$(date)] Starting Google Drive sync..." | tee -a "$LOG_FILE"

# Change to project directory
cd "$PROJECT_ROOT"

# Check if rclone is configured in Docker
if ! docker-compose exec -T blog rclone listremotes | grep -q "gdrive:"; then
    echo "[$(date)] ERROR: rclone 'gdrive' remote not configured!" | tee -a "$LOG_FILE"
    echo "Please run: docker-compose exec blog rclone config" | tee -a "$LOG_FILE"
    exit 1
fi

# Sync daily backups
echo "[$(date)] Syncing daily backups..." | tee -a "$LOG_FILE"
if docker-compose exec -T blog rclone sync "/app/backups/daily/" "gdrive:BlogBackups/daily/" --progress 2>&1 | tee -a "$LOG_FILE"; then
    echo "[$(date)] Daily sync completed" | tee -a "$LOG_FILE"
else
    echo "[$(date)] Daily sync FAILED" | tee -a "$LOG_FILE"
    exit 1
fi

# Sync weekly backups
echo "[$(date)] Syncing weekly backups..." | tee -a "$LOG_FILE"
if docker-compose exec -T blog rclone sync "/app/backups/weekly/" "gdrive:BlogBackups/weekly/" --progress 2>&1 | tee -a "$LOG_FILE"; then
    echo "[$(date)] Weekly sync completed" | tee -a "$LOG_FILE"
else
    echo "[$(date)] Weekly sync FAILED" | tee -a "$LOG_FILE"
    exit 1
fi

# Sync monthly backups
echo "[$(date)] Syncing monthly backups..." | tee -a "$LOG_FILE"
if docker-compose exec -T blog rclone sync "/app/backups/monthly/" "gdrive:BlogBackups/monthly/" --progress 2>&1 | tee -a "$LOG_FILE"; then
    echo "[$(date)] Monthly sync completed" | tee -a "$LOG_FILE"
else
    echo "[$(date)] Monthly sync FAILED" | tee -a "$LOG_FILE"
    exit 1
fi

echo "[$(date)] Google Drive sync completed successfully!" | tee -a "$LOG_FILE"

# List current files in Google Drive
echo "[$(date)] Current backups in Google Drive:" | tee -a "$LOG_FILE"
docker-compose exec -T blog rclone ls "gdrive:BlogBackups/" 2>&1 | tee -a "$LOG_FILE"