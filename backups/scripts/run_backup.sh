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
