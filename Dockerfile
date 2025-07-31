# Dockerfile for custom Redmica build (with RAG tools and LDAP patch)
FROM ruby:3.1

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs yarn imagemagick git && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /redmica

# Copy Gemfiles and install gems (caching)
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

# Copy the rest of the Redmica app
COPY . .

# Precompile assets (if needed)
RUN bundle exec rake assets:precompile

# Expose default Redmica port
EXPOSE 3000

# Entrypoint for production
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
