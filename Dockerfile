# Based on official Redmica Docker approach
FROM ruby:3.2-slim-bookworm

# Create redmine user (matching official approach)
RUN groupadd -r -g 999 redmine && useradd -r -g redmine -u 999 redmine

# Install runtime and build dependencies
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        imagemagick \
        tini \
        wget \
        # Build dependencies
        gcc \
        postgresql-server-dev-all \
        libyaml-dev \
        make \
        patch \
        pkgconf \
    ; \
    rm -rf /var/lib/apt/lists/*

ENV RAILS_ENV=production
WORKDIR /usr/src/redmine

# Set up home directory for redmine user
ENV HOME=/home/redmine
RUN set -eux; \
    mkdir -p "$HOME"; \
    chown redmine:redmine "$HOME"; \
    chmod 1777 "$HOME"

# Copy application code
COPY . .

# Install gems and set permissions
RUN set -eux; \
    mkdir -p log public/plugin_assets tmp/pdf tmp/pids; \
    chown -R redmine:redmine ./; \
    chmod -R ugo=rwX config db; \
    find log tmp -type d -exec chmod 1777 '{}' +; \
    \
    # Install gems as redmine user
    su redmine -c "bundle config --local without 'development test'"; \
    su redmine -c "bundle install --jobs $(nproc)"; \
    \
    # Clean up build dependencies
    apt-get purge -y --auto-remove gcc make patch pkgconf

VOLUME /usr/src/redmine/files

# Simple entrypoint
RUN echo '#!/bin/bash\nset -e\nexec "$@"' > /docker-entrypoint.sh && \
    chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
