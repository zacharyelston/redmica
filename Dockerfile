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

# Set environment variables for asset compilation
ENV RAILS_ENV=production \
    DATABASE_URL=postgresql://dummy:dummy@dummy:5432/dummy

# Precompile assets with temporary secret key
RUN SECRET_KEY_BASE=dummy_key_for_build_only bundle exec rake assets:precompile

# Create non-root user
RUN useradd -m -u 1000 redmica && \
    chown -R redmica:redmica /redmica
USER redmica

# Expose default Redmica port
EXPOSE 3000

# Entrypoint for production
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
