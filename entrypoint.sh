#!/bin/bash
set -e

# Funtion to put secrets on environment variables

# Remove a potentially pre-existing server.pid for Rails.
rm -f /tmp/pids/*.pid

# bundle exec rails db:migrate

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"