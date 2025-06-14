#!/bin/bash

# Simple PostgreSQL backup script for blog
# Runs inside Docker container

set -e  # Exit on error

# Configuration
BACKUP_DIR="/app/backups"
DB_NAME="blog_dev"
DB_USER="blog"
DB_PASS="blog_dev_password"
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)

# For production, these will be different
if [ "$MIX_ENV" = "prod" ]; then
    DB_NAME="blog_prod"
    DB_PASS="blog_prod_password"
fi

# Create backup
echo "[$TIMESTAMP] Starting backup of $DB_NAME..."

# Create daily backup
BACKUP_FILE="$BACKUP_DIR/daily/blog_backup_$DATE.sql.gz"
PGPASSWORD=$DB_PASS pg_dump -U $DB_USER -h localhost $DB_NAME | gzip > $BACKUP_FILE

# Get file size for logging
SIZE=$(ls -lh $BACKUP_FILE | awk '{print $5}')
echo "[$TIMESTAMP] Backup completed: $BACKUP_FILE (Size: $SIZE)"

# Clean up old daily backups (keep last 7 days)
echo "[$TIMESTAMP] Cleaning up old daily backups..."
find $BACKUP_DIR/daily -name "blog_backup_*.sql.gz" -mtime +7 -delete

# Copy to weekly on Sundays
if [ $(date +%w) -eq 0 ]; then
    echo "[$TIMESTAMP] Creating weekly backup..."
    cp $BACKUP_FILE "$BACKUP_DIR/weekly/blog_backup_weekly_$DATE.sql.gz"
    
    # Keep only last 4 weekly backups
    ls -t $BACKUP_DIR/weekly/blog_backup_weekly_*.sql.gz | tail -n +5 | xargs -r rm
fi

# Copy to monthly on 1st of month
if [ $(date +%d) -eq "01" ]; then
    echo "[$TIMESTAMP] Creating monthly backup..."
    cp $BACKUP_FILE "$BACKUP_DIR/monthly/blog_backup_monthly_$DATE.sql.gz"
    
    # Keep only last 12 monthly backups
    ls -t $BACKUP_DIR/monthly/blog_backup_monthly_*.sql.gz | tail -n +13 | xargs -r rm
fi

echo "[$TIMESTAMP] Backup process completed successfully!"