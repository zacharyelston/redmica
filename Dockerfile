# Dockerfile for custom Redmica build (with RAG tools and LDAP patch)
FROM ruby:3.2-slim

# Install system dependencies including libyaml-dev for psych gem
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs npm imagemagick git curl \
                       libyaml-dev libffi-dev libssl-dev && \
    npm install -g yarn && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /redmica

# Copy Gemfiles and install gems (caching)
COPY Gemfile* ./
RUN bundle config set --local without 'development test' && \
    bundle install

# Copy the rest of the Redmica app
COPY . .

# Set environment variables for production
ENV RAILS_ENV=production

# Create entrypoint script for asset precompilation at runtime
RUN echo '#!/bin/bash\n\
set -e\n\
echo "Precompiling assets..."\n\
RAILS_ENV=production SECRET_KEY_BASE=${SECRET_KEY_BASE:-$(bundle exec rails secret)} bundle exec rake assets:precompile\n\
echo "Starting Redmica..."\n\
exec bundle exec rails server -b 0.0.0.0' > /usr/local/bin/docker-entrypoint.sh && \
    chmod +x /usr/local/bin/docker-entrypoint.sh

# Create non-root user and set ownership
RUN useradd -m -u 1000 redmica && \
    chown -R redmica:redmica /redmica
USER redmica

# Expose default Redmica port
EXPOSE 3000

# Entrypoint for production
CMD ["/usr/local/bin/docker-entrypoint.sh"]
