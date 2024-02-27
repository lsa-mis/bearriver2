source "https://rubygems.org"

gem "rails", "~> 7.1.3"
ruby "3.3.0"

gem 'activeadmin'
gem "bootsnap", require: false
gem 'country_select', '~> 4.0'
gem "cssbundling-rails"
gem 'devise'
gem "jsbundling-rails"
gem "jbuilder"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "redis", ">= 4.0.1"
gem 'sassc-rails'
gem "skylight"
gem "sprockets-rails"
gem "stimulus-rails"
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[ windows jruby ]

group :development, :test do
  gem "debug", platforms: %i[ mri windows ]
end

group :development do
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
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
