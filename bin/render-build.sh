#!/usr/bin/env bash
# exit on error
set -o errexit

apt update && apt install -y imagemagick

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rake db:migrate
