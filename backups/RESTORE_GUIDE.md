# Database Restore Guide

## Quick Restore (Most Recent Backup)

```bash
# 1. Find the latest backup
ls -la backups/daily/

# 2. Restore from backup (replace date with actual backup date)
docker-compose exec blog bash -c "gunzip -c /app/backups/daily/blog_backup_2025-06-14.sql.gz | psql -U blog -d blog_dev"
```

## Restore from Google Drive

```bash
# 1. List available backups
rclone ls gdrive:BlogBackups/daily/

# 2. Download backup
rclone copy gdrive:BlogBackups/daily/blog_backup_2025-06-14.sql.gz backups/restore/

# 3. Restore
docker-compose exec blog bash -c "gunzip -c /app/backups/restore/blog_backup_2025-06-14.sql.gz | psql -U blog -d blog_dev"
```

## Full Restore Process

### 1. Stop the application
```bash
docker-compose stop
```

### 2. Drop and recreate database
```bash
docker-compose exec blog mix ecto.drop
docker-compose exec blog mix ecto.create
```

### 3. Restore from backup
```bash
docker-compose exec blog bash -c "gunzip -c /app/backups/daily/blog_backup_2025-06-14.sql.gz | psql -U blog -d blog_dev"
```

### 4. Restart application
```bash
docker-compose up -d
```

## Test Restore (Recommended Monthly)

1. Create a test database:
```bash
docker-compose exec blog createdb -U blog blog_test_restore
```

2. Restore to test database:
```bash
docker-compose exec blog bash -c "gunzip -c /app/backups/daily/blog_backup_2025-06-14.sql.gz | psql -U blog -d blog_test_restore"
```

3. Verify restore worked:
```bash
docker-compose exec blog psql -U blog -d blog_test_restore -c "SELECT COUNT(*) FROM posts;"
```

4. Drop test database:
```bash
docker-compose exec blog dropdb -U blog blog_test_restore
```

## Important Notes

- Always test restores regularly!
- Keep this guide updated
- In production, stop the application before restoring
- Backups contain all data including users, posts, drafts, etc.