# All-in-one Dockerfile for Blog application
# Based on official Elixir image with PostgreSQL 17 added

FROM elixir:1.16.3

# Install PostgreSQL 17, Node.js and other dependencies
RUN apt-get update && \
    apt-get install -y \
    curl \
    wget \
    gnupg \
    lsb-release \
    supervisor \
    inotify-tools \
    nodejs \
    npm \
    imagemagick \
    && rm -rf /var/lib/apt/lists/*

# Add PostgreSQL 17 repository
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update && \
    apt-get install -y postgresql-17 postgresql-client-17 postgresql-contrib-17 && \
    rm -rf /var/lib/apt/lists/*

# Configure PostgreSQL
USER postgres
RUN /etc/init.d/postgresql start && \
    psql --command "CREATE USER blog WITH SUPERUSER PASSWORD 'blog_dev_password';" && \
    createdb -O blog blog_dev && \
    createdb -O blog blog_test

USER root

# PostgreSQL configuration to allow connections
RUN echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql/17/main/pg_hba.conf && \
    echo "listen_addresses='*'" >> /etc/postgresql/17/main/postgresql.conf

# Create app directory
WORKDIR /app

# Install Hex and Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set mix env
ENV MIX_ENV=dev

# Create supervisord configuration
RUN mkdir -p /var/log/supervisor
COPY <<EOF /etc/supervisor/conf.d/supervisord.conf
[supervisord]
nodaemon=true
logfile=/var/log/supervisor/supervisord.log
pidfile=/var/run/supervisord.pid

[program:postgresql]
command=/usr/lib/postgresql/17/bin/postgres -D /var/lib/postgresql/17/main -c config_file=/etc/postgresql/17/main/postgresql.conf
user=postgres
autostart=true
autorestart=true
stdout_logfile=/var/log/supervisor/postgresql.log
stderr_logfile=/var/log/supervisor/postgresql_err.log

[program:phoenix]
command=/app/docker-entrypoint.sh
directory=/app
autostart=true
autorestart=true
stdout_logfile=/var/log/supervisor/phoenix.log
stderr_logfile=/var/log/supervisor/phoenix_err.log
environment=MIX_ENV="dev",DATABASE_URL="postgres://blog:blog_dev_password@localhost/blog_dev",PHX_SERVER="true"
EOF

# Copy entrypoint script
COPY docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh

# Expose ports
EXPOSE 4000 5432

# Start supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]