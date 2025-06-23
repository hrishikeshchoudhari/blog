#!/bin/bash
# Simple deployment script for existing Hetzner server with Caddy

set -e

# Configuration
SERVER_USER=${SERVER_USER:-root}
SERVER_HOST=${SERVER_HOST}
APP_NAME="blog"
DEPLOY_PATH="/opt/${APP_NAME}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if SERVER_HOST is set
if [ -z "$SERVER_HOST" ]; then
    echo -e "${RED}Error: SERVER_HOST environment variable is not set${NC}"
    echo "Usage: SERVER_HOST=your.server.com ./deploy-simple.sh"
    exit 1
fi

echo -e "${GREEN}Deploying to ${SERVER_HOST}...${NC}"

# Ensure .env.production exists
if [ ! -f ".env.production" ]; then
    echo -e "${RED}Error: .env.production file not found${NC}"
    echo "Please create .env.production from .env.production.example"
    exit 1
fi

# Deploy using docker-compose on the server
ssh ${SERVER_USER}@${SERVER_HOST} << 'ENDSSH'
set -e

cd /opt/blog

# Pull latest code
echo "Pulling latest code..."
git pull origin master

# Copy production files
cp docker-compose.prod.yml docker-compose.yml

# Pull/build images and restart
echo "Updating containers..."
docker-compose pull
docker-compose build
docker-compose down
docker-compose up -d

# Run migrations
echo "Running database migrations..."
docker-compose exec -T blog bin/blog eval 'Blog.Release.migrate()'

# Check status
docker-compose ps

echo "Deployment complete!"
ENDSSH

# Copy .env.production to server
echo -e "${YELLOW}Copying environment file...${NC}"
scp .env.production ${SERVER_USER}@${SERVER_HOST}:${DEPLOY_PATH}/.env

# Copy Caddyfile if it exists locally
if [ -f "Caddyfile" ]; then
    echo -e "${YELLOW}Copying Caddyfile...${NC}"
    scp Caddyfile ${SERVER_USER}@${SERVER_HOST}:/tmp/Caddyfile.new
    ssh ${SERVER_USER}@${SERVER_HOST} << 'ENDSSH'
    # Backup existing Caddyfile
    cp /etc/caddy/Caddyfile /etc/caddy/Caddyfile.backup
    # Check if domain needs to be updated
    echo "Remember to update your domain in /tmp/Caddyfile.new"
    echo "Then run: sudo mv /tmp/Caddyfile.new /etc/caddy/Caddyfile && sudo systemctl reload caddy"
ENDSSH
fi

echo -e "${GREEN}Deployment successful!${NC}"
echo -e "${GREEN}Your blog should be available at https://${SERVER_HOST}${NC}"