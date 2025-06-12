#!/bin/bash
set -e

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to start..."
while ! pg_isready -h localhost -p 5432 -U blog; do
  sleep 1
done

echo "PostgreSQL is ready!"

# Always get dependencies to ensure they're up to date
echo "Installing dependencies..."
mix deps.get
mix deps.compile

# Use the docker config
export MIX_ENV=dev
export DATABASE_URL="postgres://blog:blog_dev_password@localhost/blog_dev"

# Create and migrate database
echo "Setting up database..."
mix ecto.create || true
mix ecto.migrate || true

# Install Node.js dependencies
echo "Installing assets..."
if [ -d "assets" ]; then
  cd assets && npm install && cd ..
fi

# Ensure we're in the app directory
cd /app

# Start Phoenix server
echo "Starting Phoenix server..."
exec mix phx.server