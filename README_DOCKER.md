# Docker Setup for Blog Application

This setup provides an all-in-one Docker container with Elixir, Phoenix, and PostgreSQL 17.

## Claude Code Compatibility

Yes, Claude Code works perfectly with Docker containers! You can:
- Edit files in your local directory (they're mounted as volumes)
- Run commands inside the container
- The development server auto-reloads on file changes

## Quick Start

1. **Build and start the development container:**
   ```bash
   docker-compose up --build
   ```

2. **Access the application:**
   - Phoenix app: http://localhost:4000
   - PostgreSQL: localhost:5432 (username: blog, password: blog_dev_password)

3. **Run commands inside the container:**
   ```bash
   # Open a shell in the running container
   docker-compose exec blog bash
   
   # Run mix commands
   docker-compose exec blog mix ecto.migrate
   docker-compose exec blog mix test
   ```

## Docker Configuration

### Development Setup
- Uses Ubuntu 22.04 base image
- PostgreSQL 17 running inside the container
- Elixir and Erlang via Erlang Solutions repository
- Supervisor manages both PostgreSQL and Phoenix processes
- Volumes for code hot-reloading

### Database Configuration
- Database name: `blog_dev`
- Username: `blog`
- Password: `blog_dev_password`
- The database is automatically created and migrated on container start

### Volumes
The docker-compose.yml mounts several volumes:
- `.:/app` - Your code directory (for hot-reloading)
- `deps:/app/deps` - Elixir dependencies
- `build:/app/_build` - Build artifacts
- `node_modules:/app/assets/node_modules` - Frontend dependencies
- `postgres_data:/var/lib/postgresql/17/main` - PostgreSQL data

## Production/Staging

To run a production-like environment:

1. Create `Dockerfile.prod` (based on the current Dockerfile but with MIX_ENV=prod)
2. Run: `docker-compose --profile production up blog_prod`

This will start a separate container on ports 4001 (Phoenix) and 5433 (PostgreSQL).

## Deployment to Hetzner

Since everything runs in a container, deployment is straightforward:

1. Copy your code to the Hetzner server
2. Install Docker and Docker Compose
3. Run `docker-compose up -d` for production
4. Use a reverse proxy (nginx/caddy) to handle SSL and route to port 4000

## Troubleshooting

- If PostgreSQL fails to start, check the logs: `docker-compose logs blog`
- To reset the database: `docker-compose down -v` (this removes all volumes)
- For permission issues, ensure the mounted directories are accessible

## Notes

- The old Fly.io deployment files (fly.toml) are no longer needed
- PostgreSQL 17 is included in the container (not using the macOS system PostgreSQL)
- The container uses supervisor to manage multiple processes