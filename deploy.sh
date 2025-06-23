#!/bin/bash
# Deployment script for Hetzner server

set -e

# Configuration
SERVER_USER=${SERVER_USER:-root}
SERVER_HOST=${SERVER_HOST}
APP_NAME="blog"
DEPLOY_PATH="/opt/${APP_NAME}"
BACKUP_PATH="${DEPLOY_PATH}/backups"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if SERVER_HOST is set
if [ -z "$SERVER_HOST" ]; then
    echo -e "${RED}Error: SERVER_HOST environment variable is not set${NC}"
    echo "Usage: SERVER_HOST=your.server.com ./deploy.sh"
    exit 1
fi

echo -e "${GREEN}Starting deployment to ${SERVER_HOST}...${NC}"

# Build the production image locally
echo -e "${YELLOW}Building production Docker image...${NC}"
docker build -f Dockerfile.prod -t ${APP_NAME}:latest .

# Save the image
echo -e "${YELLOW}Saving Docker image...${NC}"
docker save ${APP_NAME}:latest | gzip > ${APP_NAME}.tar.gz

# Transfer files to server
echo -e "${YELLOW}Transferring files to server...${NC}"
scp ${APP_NAME}.tar.gz ${SERVER_USER}@${SERVER_HOST}:/tmp/
scp docker-compose.prod.yml ${SERVER_USER}@${SERVER_HOST}:${DEPLOY_PATH}/docker-compose.yml
scp .env.production ${SERVER_USER}@${SERVER_HOST}:${DEPLOY_PATH}/.env

# Clean up local image archive
rm ${APP_NAME}.tar.gz

# Execute deployment on server
echo -e "${YELLOW}Deploying on server...${NC}"
ssh ${SERVER_USER}@${SERVER_HOST} << 'ENDSSH'
set -e

# Navigate to app directory
cd /opt/blog

# Load the Docker image
echo "Loading Docker image..."
docker load < /tmp/blog.tar.gz
rm /tmp/blog.tar.gz

# Stop existing containers (if any)
echo "Stopping existing containers..."
docker-compose down || true

# Start new containers
echo "Starting new containers..."
docker-compose up -d

# Wait for services to be healthy
echo "Waiting for services to be healthy..."
sleep 10

# Check if services are running
docker-compose ps

echo "Deployment complete!"
ENDSSH

echo -e "${GREEN}Deployment successful!${NC}"
echo -e "${GREEN}Your blog should be available at https://${SERVER_HOST}${NC}"