# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Phoenix LiveView blog application built with Elixir. It features:
- User authentication system
- Blog post creation with drafts and publishing workflow
- Tag system for categorizing posts
- Markdown editor with live preview (Monaco editor)
- Admin interface for content management

## Development Commands

### Docker Setup (Recommended)
- `docker-compose up -d` - Start development environment
- `docker-compose down` - Stop containers
- `docker-compose logs -f` - View logs
- `docker-compose exec blog bash` - Access container shell
- `docker-compose exec blog mix deps.get` - Run mix commands in container

### Traditional Setup (if not using Docker)
- `mix setup` - Install dependencies, create database, run migrations, and build assets
- `mix phx.server` - Start Phoenix server (visit http://localhost:4000)
- `iex -S mix phx.server` - Start server with interactive shell

### Database (via Docker)
- `docker-compose exec blog mix ecto.create` - Create database
- `docker-compose exec blog mix ecto.migrate` - Run migrations
- `docker-compose exec blog mix ecto.reset` - Drop and recreate database
- `docker-compose exec blog mix ecto.gen.migration migration_name` - Generate migration

### Testing
- `docker-compose exec blog mix test` - Run all tests
- `docker-compose exec blog mix test path/to/test.exs` - Run specific test file

### Assets
- Assets are automatically built when container starts
- `docker-compose exec blog mix assets.build` - Manually build assets

## Architecture

### Core Models
- **Users** - Authentication via `Blog.Accounts` context
- **Draft** (`Blog.Admin.Draft`) - Unpublished blog posts with title, body, slug, publishedDate
- **Post** (`Blog.Post`) - Published blog posts with same fields as Draft
- **Tag** (`Blog.Admin.Tag`) - Content categorization with name, slug, description

### Key Contexts
- `Blog.Accounts` - User management and authentication
- `Blog.Admin` - Draft and tag management
- `Blog.Landing` - Public-facing content queries

### LiveView Structure
The app uses three layout types:
- `:app` - Public pages (home, about, post viewing)
- `:auth` - Authentication pages (login, register, password reset)
- `:admin` - Admin pages (draft writing, tag management)

### Current Development Status
- Tags CRUD is partially complete (Create/Read done, Update/Delete pending)
- Many-to-many relationships between tags and posts/drafts are FULLY IMPLEMENTED ✓
- Draft editor has working tag selection ✓
- Tags are displayed on posts and link to tag pages ✓
- Admin home still needs clickable draft list that loads drafts in editor

### Recent Tech Debt Resolved
- Added unique slug constraints to drafts and posts tables
- Created join tables for many-to-many tag relationships
- Updated all schemas with proper associations
- Implemented tag selection in draft/post creation
- Added tag display on home page with links

## Important Notes

- Uses PostgreSQL 17 running inside Docker container
- PostgreSQL accessible on localhost:5433 (username: blog, password: blog_dev_password)
- Phoenix app runs on localhost:4000
- All development dependencies (Elixir, PostgreSQL, Node.js) are containerized
- Volume mounts enable hot-reloading - edit files locally, see changes immediately
- Authentication uses Phoenix's built-in auth generators
- Markdown rendering via the `md` library
- Monaco editor for draft writing with auto-save functionality
- Tailwind CSS with custom Calistoga and SNPro fonts

## Docker Environment

The project now uses Docker for consistent development:
- `Dockerfile` - All-in-one container with Elixir 1.16.3, PostgreSQL 17, and Node.js
- `docker-compose.yml` - Development configuration with volume mounts
- `docker-entrypoint.sh` - Handles startup, dependency installation, and database setup
- `.dockerignore` - Excludes unnecessary files from Docker context
- `README_DOCKER.md` - Detailed Docker setup instructions

### Key Docker Features
- Hot-reloading enabled for both Elixir and assets
- PostgreSQL data persisted via Docker volumes
- Automatic database creation and migration on startup
- Works seamlessly with any IDE - edit locally, run in container
- Ready for deployment to Hetzner server

## When Docker Restart is Required

**Docker restart IS required for:**
- Configuration changes (config/*.exs files)
- Mix dependency changes (mix.exs, mix.lock)
- Router changes (router.ex)
- Database schema changes (migrations)
- Dockerfile or docker-compose.yml changes

**Docker restart is NOT required for:**
- Template changes (.heex files)
- LiveView module changes
- CSS/Tailwind changes
- JavaScript changes
- Most Elixir code changes (contexts, schemas, etc.)

Phoenix's hot-reloading handles most code changes automatically without needing to restart the container.