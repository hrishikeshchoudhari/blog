# Hetzner Deployment Guide

This guide covers deploying the Phoenix blog application to a Hetzner server.

## Prerequisites

1. A Hetzner server (Ubuntu 22.04 recommended)
2. Domain name pointed to your server's IP
3. SSH access to the server
4. Docker and Docker Compose installed on your local machine

## Initial Server Setup

1. **SSH into your server:**
   ```bash
   ssh root@your.server.com
   ```

2. **Update the system:**
   ```bash
   apt update && apt upgrade -y
   ```

3. **Install required packages:**
   ```bash
   apt install -y docker.io docker-compose git
   systemctl enable docker
   systemctl start docker
   ```

4. **Install Caddy (if not already installed):**
   ```bash
   apt install -y debian-keyring debian-archive-keyring apt-transport-https
   curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
   curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
   apt update
   apt install caddy
   ```

5. **Create application directory:**
   ```bash
   mkdir -p /opt/blog
   cd /opt/blog
   ```

## Caddy Configuration

Caddy automatically handles SSL certificates from Let's Encrypt, so no manual SSL setup is needed!

## Environment Configuration

1. **Copy the example environment file:**
   ```bash
   cp .env.production.example .env.production
   ```

2. **Generate a secret key base:**
   ```bash
   mix phx.gen.secret
   # Or if mix is not available:
   openssl rand -base64 64 | tr -d '\n'
   ```

3. **Edit `.env.production` with your values:**
   ```bash
   nano .env.production
   ```

   Required values:
   - `DB_PASSWORD`: Strong database password
   - `SECRET_KEY_BASE`: Generated secret (64 characters)
   - `PHX_HOST`: Your domain name
   - `POSTMARK_API_KEY`: Your Postmark API key for emails

## Caddy Setup

1. **Copy Caddyfile to server:**
   ```bash
   # On your local machine
   scp Caddyfile root@your.server.com:/etc/caddy/Caddyfile
   ```

2. **Edit the Caddyfile on server:**
   ```bash
   nano /etc/caddy/Caddyfile
   # Replace 'your.domain.com' with your actual domain
   ```

3. **Reload Caddy:**
   ```bash
   systemctl reload caddy
   ```

## Deployment

### First-time deployment:

1. **On your local machine, create `.env.production`:**
   ```bash
   cp .env.production.example .env.production
   # Edit with your production values
   ```

2. **Run the deployment script:**
   ```bash
   SERVER_HOST=your.server.com ./deploy.sh
   ```

   This script will:
   - Build the production Docker image
   - Transfer it to your server
   - Start the containers
   - Run database migrations

### Manual deployment steps (alternative):

1. **Build and transfer manually:**
   ```bash
   # Build production image
   docker build -f Dockerfile.prod -t blog:latest .
   
   # Save and transfer
   docker save blog:latest | gzip | ssh root@your.server.com "docker load"
   
   # Copy files
   scp docker-compose.prod.yml root@your.server.com:/opt/blog/docker-compose.yml
   scp .env.production root@your.server.com:/opt/blog/.env
   ```

2. **On the server:**
   ```bash
   cd /opt/blog
   docker-compose up -d
   ```

## Post-Deployment

1. **Check logs:**
   ```bash
   docker-compose logs -f blog
   ```

2. **Verify services are running:**
   ```bash
   docker-compose ps
   ```

3. **Create admin user (if needed):**
   ```bash
   docker-compose exec blog bin/blog remote
   # In IEx:
   Blog.Accounts.register_user(%{email: "admin@example.com", password: "securepassword"})
   ```

## Backup Setup

1. **Configure backup settings in `.env.production`:**
   - Set `GOOGLE_DRIVE_FOLDER_ID` if using Google Drive
   - Configure `GOOGLE_SERVICE_ACCOUNT_KEY`

2. **Set up backup cron job:**
   ```bash
   crontab -e
   # Add:
   0 2 * * * cd /opt/blog && docker-compose exec -T blog /app/backups/scripts/backup.sh
   ```

## Maintenance

### Update deployment:
```bash
# On local machine
git pull origin master
SERVER_HOST=your.server.com ./deploy.sh
```

### View logs:
```bash
ssh root@your.server.com
cd /opt/blog
docker-compose logs -f
```

### Database backup:
```bash
docker-compose exec postgres pg_dump -U blog blog_prod > backup.sql
```

### Scale resources:
Edit `/opt/blog/docker-compose.yml` and adjust:
- `POOL_SIZE` for database connections
- Container resource limits if needed

## Troubleshooting

1. **Container won't start:**
   - Check logs: `docker-compose logs blog`
   - Verify environment variables in `.env`
   - Ensure database is running: `docker-compose ps postgres`

2. **502 Bad Gateway:**
   - Check if app is running: `docker-compose ps`
   - Check app logs: `docker-compose logs blog`
   - Verify Caddy is running: `systemctl status caddy`
   - Check Caddy logs: `journalctl -u caddy -f`

3. **Database connection issues:**
   - Verify DATABASE_URL format
   - Check postgres is healthy: `docker-compose ps postgres`
   - Test connection: `docker-compose exec postgres psql -U blog blog_prod`

4. **Asset loading issues:**
   - Rebuild assets: `docker-compose exec blog mix assets.deploy`
   - Check Caddy reverse_proxy configuration
   - Verify PHX_HOST is set correctly
   - Check browser console for specific asset errors

## Security Considerations

1. **Firewall setup:**
   ```bash
   ufw allow 22/tcp    # SSH
   ufw allow 80/tcp    # HTTP
   ufw allow 443/tcp   # HTTPS
   ufw enable
   ```

2. **Regular updates:**
   ```bash
   apt update && apt upgrade -y
   docker system prune -a  # Clean up old images
   ```

3. **Monitor logs:**
   - Set up log rotation for Docker logs
   - Monitor Caddy logs: `journalctl -u caddy -f`
   - Check Caddy access logs in `/var/log/caddy/`
   - Consider setting up fail2ban for additional security