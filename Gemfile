source "https://rubygems.org"

gem "rails", "~> 7.1.3"
ruby "3.3.0"

gem 'activeadmin'
gem 'country_select', '~> 4.0'
gem 'devise'
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"

gem "haml-rails", "~> 2.0"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem "cssbundling-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
gem "redis", ">= 4.0.1"

gem "skylight"
# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ]
end

group :development do
  gem 'annotate'
  gem 'better_errors'
  gem "web-console"
end


group :development, :test do
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "capybara"
  gem "webdrivers"
  gem "faker"
  gem 'pry-rails'
  gem "pry-byebug"
end

group :development, :staging do
  gem "letter_opener_web"
end
