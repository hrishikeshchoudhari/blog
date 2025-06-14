# Production Backup Setup on Hetzner

## Quick Setup (After configuring Google Drive in dev)

### 1. Copy files to production server

```bash
# From your local machine
scp -r backups/scripts your-server:/path/to/blog/backups/
scp backups/rclone.conf your-server:/path/to/blog/backups/
```

### 2. On production server

```bash
# SSH into server
ssh your-server
cd /path/to/blog

# Create backup directories
mkdir -p backups/{daily,weekly,monthly,logs,restore}

# Set permissions
chmod +x backups/scripts/*.sh

# Copy rclone config into Docker
docker-compose exec blog mkdir -p /root/.config/rclone
docker cp backups/rclone.conf blog_blog_1:/root/.config/rclone/rclone.conf

# Test rclone
docker-compose exec blog rclone ls gdrive:BlogBackups/

# Update database credentials in backup script for production
# Edit backups/scripts/backup_database.sh if needed

# Set up cron
./backups/scripts/setup_cron.sh

# Test backup
./backups/scripts/run_backup.sh
```

## Environment Variables for Production

Make sure your production .env has:
```
POSTMARK_API_KEY=your-production-key
```

## Monitoring

- Check daily emails for backup status
- Review logs: `tail -f backups/logs/*.log`
- Verify Google Drive: `docker-compose exec blog rclone ls gdrive:BlogBackups/`

## Restore Process

Same as development - see RESTORE_GUIDE.md

## Important Notes

1. The rclone.conf file contains your Google OAuth tokens - keep it secure!
2. Backups will use the same Google Drive account as development
3. Consider using a separate folder for production backups if desired
4. Test restore process before going live!