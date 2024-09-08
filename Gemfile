# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'active_link_to'
gem 'importmap-rails'
gem 'pg'
gem 'puma'
gem 'rails', '~> 7.0.3'
gem 'redis', '~> 4.0'
gem 'sassc-rails'
gem 'sprockets-rails'
gem 'stimulus-rails'
gem 'turbo-rails'

# Use Sidekiq for create JOBs
gem 'sidekiq'

# Use Devise
gem 'devise'

# Use for group by dates
gem 'groupdate'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'faker'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
end

group :development do
  gem 'listen', '~> 3.3'
end

gem 'dockerfile-rails', '>= 1.6', :group => :development
