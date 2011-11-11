source 'http://rubygems.org'

# passenger compatability
group :passenger_compatibility do
  gem 'rack', '1.3.5'
  gem 'rake', '0.9.2'
end

gem 'rails', '3.1.1'
gem 'rails-i18n'
gem 'json'
gem 'jquery-rails'
gem 'plek', '0.1.7'

if ENV['SLIMMER_DEV']
  gem 'slimmer', :path => '../slimmer'
else
  gem 'slimmer', :git => 'git@github.com:alphagov/slimmer.git'
end

if ENV['GOVSPEAK_DEV']
  gem 'govspeak', :path => '../govspeak'
else
  gem 'govspeak', :git => 'git@github.com:alphagov/govspeak.git'
end

group :test do
  gem 'capybara', '~> 1.1.0'
  gem 'ci_reporter'
  gem 'factory_girl_rails'
  gem 'minitest', '2.7.0'
  gem 'mocha', :require => false
  gem 'selenium-webdriver'
  gem "shoulda", "~> 2.11.3"
  gem 'webmock', :require => false
end

group :assets do
  gem 'sass-rails', "  ~> 3.1.0"
  gem 'coffee-rails', "~> 3.1.0"
  gem "therubyracer", "~> 0.9.4"
  gem 'uglifier'
end
