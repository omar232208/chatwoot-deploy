FROM ruby:3.4.4-alpine3.21

# Install Node.js 20
RUN apk add --no-cache nodejs npm

# Install system dependencies
RUN apk add --no-cache \
  build-base \
  openssl \
  tzdata \
  postgresql-client \
  imagemagick \
  git \
  vips \
  curl

WORKDIR /app

# Install bundler
RUN gem install bundler -v 2.5.16

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock ./
RUN bundle config set without 'development test' && \
  bundle install

# Copy package files and install
COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm && \
  pnpm install

# Copy application code
COPY . .

# Precompile assets
RUN SECRET_KEY_BASE=precompile_placeholder RAILS_LOG_TO_STDOUT=enabled \
  bundle exec rake assets:precompile

# Expose port
EXPOSE 3000

# Start command
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
