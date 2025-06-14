#!/bin/bash

# Enable Google Drive sync after rclone is configured

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Checking rclone configuration..."

# Check if rclone is installed in Docker
if ! docker-compose exec -T blog which rclone &> /dev/null; then
    echo "ERROR: rclone is not installed in Docker!"
    echo "Please rebuild Docker: docker-compose build"
    exit 1
fi

# Check if gdrive remote is configured
if ! docker-compose exec -T blog rclone listremotes | grep -q "gdrive:"; then
    echo "ERROR: rclone 'gdrive' remote not configured!"
    echo "Please run: docker-compose exec blog rclone config"
    exit 1
fi

# Test Google Drive connection
echo "Testing Google Drive connection..."
if ! docker-compose exec -T blog rclone lsd gdrive: &> /dev/null; then
    echo "ERROR: Cannot connect to Google Drive!"
    echo "Please check your rclone configuration"
    exit 1
fi

# Create BlogBackups folders
echo "Creating BlogBackups folders in Google Drive..."
docker-compose exec -T blog rclone mkdir gdrive:BlogBackups
docker-compose exec -T blog rclone mkdir gdrive:BlogBackups/daily
docker-compose exec -T blog rclone mkdir gdrive:BlogBackups/weekly
docker-compose exec -T blog rclone mkdir gdrive:BlogBackups/monthly

# Update the run_backup.sh script to include Google Drive sync
echo "Updating backup script to include Google Drive sync..."

# Create updated backup script
cat > "$SCRIPT_DIR/run_backup_with_gdrive.sh" << 'EOF'
#!/bin/bash

# Host script to run backup inside Docker container with Google Drive sync
# This runs on your Mac and executes the backup in the container

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
LOG_FILE="$PROJECT_ROOT/backups/logs/backup_$(date +%Y-%m-%d).log"

# Create log directory if it doesn't exist
mkdir -p "$PROJECT_ROOT/backups/logs"

echo "Starting database backup at $(date)" | tee -a "$LOG_FILE"

# Change to project directory
cd "$PROJECT_ROOT"

# Run backup script inside Docker container
if docker-compose exec -T blog bash /app/backups/scripts/backup_database.sh 2>&1 | tee -a "$LOG_FILE"; then
    echo "Backup completed successfully at $(date)" | tee -a "$LOG_FILE"
    
    # Sync to Google Drive
    echo "Starting Google Drive sync..." | tee -a "$LOG_FILE"
    if "$SCRIPT_DIR/sync_to_gdrive.sh" 2>&1 | tee -a "$LOG_FILE"; then
        # Send success email notification
        docker-compose exec -T blog mix run -e '
        import Swoosh.Email
        
        email = 
          Swoosh.Email.new()
          |> Swoosh.Email.to("me@rishi.xyz")
          |> Swoosh.Email.from({"Blog Backup", "me@rishi.xyz"})
          |> Swoosh.Email.subject("✅ Blog Backup & Sync Successful")
          |> Swoosh.Email.text_body("Daily backup completed and synced to Google Drive at #{DateTime.utc_now()}")
        
        Blog.Mailer.deliver(email)
        ' >> "$LOG_FILE" 2>&1
    else
        # Send sync failure notification
        docker-compose exec -T blog mix run -e '
        import Swoosh.Email
        
        email = 
          Swoosh.Email.new()
          |> Swoosh.Email.to("me@rishi.xyz")
          |> Swoosh.Email.from({"Blog Backup", "me@rishi.xyz"})
          |> Swoosh.Email.subject("⚠️ Blog Backup OK but Sync Failed")
          |> Swoosh.Email.text_body("Backup completed but Google Drive sync FAILED at #{DateTime.utc_now()}. Check logs.")
        
        Blog.Mailer.deliver(email)
        ' >> "$LOG_FILE" 2>&1
    fi
else
    echo "Backup FAILED at $(date)" | tee -a "$LOG_FILE"
    
    # Send failure email notification
    docker-compose exec -T blog mix run -e '
    import Swoosh.Email
    
    email = 
      Swoosh.Email.new()
      |> Swoosh.Email.to("me@rishi.xyz")
      |> Swoosh.Email.from({"Blog Backup", "me@rishi.xyz"})
      |> Swoosh.Email.subject("❌ Blog Backup Failed")
      |> Swoosh.Email.text_body("Daily backup FAILED at #{DateTime.utc_now()}. Please check the logs.")
    
    Blog.Mailer.deliver(email)
    ' >> "$LOG_FILE" 2>&1
fi
EOF

chmod +x "$SCRIPT_DIR/run_backup_with_gdrive.sh"

# Replace the old script
mv "$SCRIPT_DIR/run_backup.sh" "$SCRIPT_DIR/run_backup_no_gdrive.sh"
mv "$SCRIPT_DIR/run_backup_with_gdrive.sh" "$SCRIPT_DIR/run_backup.sh"

# Update cron job
./setup_cron.sh

echo ""
echo "✅ Google Drive sync enabled!"
echo ""
echo "Testing sync with existing backup..."
"$SCRIPT_DIR/sync_to_gdrive.sh"

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Your backups will now:"
echo "1. Run daily at 2 AM"
echo "2. Automatically sync to Google Drive"
echo "3. Send email notifications"
echo ""
echo "To run a backup manually: ./backups/scripts/run_backup.sh"