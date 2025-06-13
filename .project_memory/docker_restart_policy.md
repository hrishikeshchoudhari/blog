# Docker Restart Policy

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

# Package Management

- Always put the package name in the mix.exs file, and then run mix deps.get
- For frontend packages, always put the package name in the package.json file, and then run npm install