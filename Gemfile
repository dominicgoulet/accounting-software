# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'

# Core
gem 'rails', '~> 7.0.4'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Web Server
gem 'puma', '~> 5.0'

# Drivers
gem 'pg', '~> 1.1'
gem 'redis', '~> 4.0'

# Assets
gem 'importmap-rails'
gem 'jbuilder'
gem 'sprockets-rails'
gem 'stimulus-rails'
gem 'tailwindcss-rails', '~> 2.0'
gem 'turbo-rails'
gem 'view_component', '2.79.0'

# Security
gem 'bcrypt', '~> 3.1.7'
gem 'blind_index'
gem 'lockbox'

# Others
gem 'aws-sdk-s3', require: false
gem 'bootsnap', require: false
gem 'enumerize', '2.5.0'
gem 'inline_svg'
gem 'kaminari'
gem 'plaid'
gem 'rails-pg-extras'
gem 'ransack'
gem 'rtesseract'
gem "roo", "~> 2.10.0"
gem 'rubyzip'

group :development, :test do
  gem 'annotate'
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'figaro'

  gem 'factory_bot_rails'
  gem 'json_spec'
  gem 'rspec-rails', '~> 6.0.0'
  gem 'shoulda-callback-matchers'
end

group :development do
  gem 'hotwire-livereload', '~> 1.2'
  gem 'lookbook'
  gem 'web-console'
end

group :test do
  gem 'database_cleaner-active_record'
  gem 'shoulda-matchers', '~> 5.0'
  gem 'simplecov'
end

gem 'bugsnag', '~> 6.25'
