source 'https://rubygems.org'

gem 'rails', '~> 7.2.2'
ruby '3.4.9'

gem 'activeadmin', '~> 3.5'
gem 'bootsnap', require: false
gem 'country_select', '~> 8.0'
gem 'cssbundling-rails'
gem 'devise', '~> 5.0', '>= 5.0.3'
gem 'jbuilder'
gem 'jsbundling-rails'
gem 'ostruct', '~> 0.6.3'
gem 'pg', '~> 1.1'
gem 'puma', '>= 5.0'
gem 'redis', '>= 4.0.1'
gem 'sassc-rails'
gem "sentry-ruby"
gem "sentry-rails"
# Required when Sentry profiles_sample_rate is set (see config/initializers/sentry.rb)
gem 'stackprof'
gem 'skylight'
gem 'stimulus-rails'
gem 'turbo-rails'
gem 'tzinfo-data', platforms: %i[windows jruby]

group :development, :test do
  gem 'debug', platforms: %i[mri windows]
end

group :development do
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'web-console'
end

group :development, :test do
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem "rubocop", "~> 1.86"
  gem "rubocop-rails"
  gem 'simplecov'
  gem 'webdrivers'
end

group :development, :staging do
  gem 'letter_opener_web'
end

group :development, :staging, :test do
  gem 'faker'
end
