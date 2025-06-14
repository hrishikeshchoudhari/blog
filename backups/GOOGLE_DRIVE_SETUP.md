# Google Drive Backup Setup

## Phase 1 is complete! ✅

Daily backups are now running automatically at 2 AM.

## Phase 2: Google Drive Setup

### 1. Rebuild Docker to include rclone

```bash
docker-compose down
docker-compose build
docker-compose up -d
```

### 2. Configure Google Drive (ONE TIME ONLY)

This configuration is portable - you only need to do this once, and it will work in both dev and production!

```bash
# Enter the Docker container
docker-compose exec blog bash

# Configure rclone
rclone config
```

Steps:
1. Choose `n` for new remote
2. Name it: `gdrive`
3. Choose `drive` (Google Drive)
4. Leave client_id and client_secret blank (press Enter)
5. Choose scope: `1` (Full access)
6. Leave root_folder_id blank (press Enter)
7. Leave service_account_file blank (press Enter)
8. Choose `n` for advanced config
9. Choose `n` for auto config (since we're in Docker)
10. It will give you a URL - copy and open it in your browser
11. Log in to Google and authorize
12. Copy the verification code and paste it back
13. Choose `n` for team drive
14. Confirm with `y`

### 3. Test the connection (inside Docker)

```bash
# Still inside Docker container
# List your Google Drive root
rclone ls gdrive:

# Create BlogBackups folder
rclone mkdir gdrive:BlogBackups
rclone mkdir gdrive:BlogBackups/daily
rclone mkdir gdrive:BlogBackups/weekly
rclone mkdir gdrive:BlogBackups/monthly

# Exit Docker container
exit
```

### 4. Copy rclone config for reuse

The rclone config is stored in the container. Let's copy it out so you can use it in production:

```bash
# Copy config from container to host
docker-compose exec blog cat /root/.config/rclone/rclone.conf > backups/rclone.conf

# This file contains your Google Drive credentials - keep it secure!
echo "backups/rclone.conf" >> .gitignore
```

### 5. Enable Google Drive sync

Once rclone is configured, run:

```bash
./backups/scripts/enable_gdrive_sync.sh
```

## Using the config in Production

When you deploy to production on Hetzner:

1. Copy the `rclone.conf` file to your production server
2. Place it in the Docker container at `/root/.config/rclone/rclone.conf`
3. Your backups will automatically sync to the same Google Drive!

## Current Status

- ✅ Phase 1: Local backups running daily at 2 AM
- ⏳ Phase 2: Google Drive sync (waiting for rclone setup)
- ⏳ Phase 3: Automatic with retention in backup script
- ⏳ Phase 4: Email notifications already working

## Manual Commands

- Run backup now: `./backups/scripts/run_backup.sh`
- Check cron job: `crontab -l`
- View logs: `ls -la backups/logs/`
- Test rclone: `docker-compose exec blog rclone ls gdrive:`