# Dockerfile for custom Redmica build (with RAG tools and LDAP patch)
FROM ruby:3.2-slim

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs npm imagemagick git curl && \
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

# Set environment variables for asset compilation
ENV RAILS_ENV=production \
    DATABASE_URL=postgresql://dummy:dummy@dummy:5432/dummy \
    SECRET_KEY_BASE=dummy_key_for_build_only

# Precompile assets
RUN bundle exec rake assets:precompile

# Remove the dummy secret key after asset compilation
ENV SECRET_KEY_BASE=

# Create non-root user
RUN useradd -m -u 1000 redmica && \
    chown -R redmica:redmica /redmica
USER redmica

# Expose default Redmica port
EXPOSE 3000

# Entrypoint for production
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
