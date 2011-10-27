source 'http://rubygems.org'

# passenger compatability
group :passenger_compatibility do
  gem 'rack', '1.3.5'
  gem 'rake', '0.9.2'
end

gem 'rails', '3.1.1'
gem 'json'
gem 'jquery-rails'
gem 'compass', '~> 0.12.alpha.0'

if ENV['SLIMMER_DEV']
  gem 'slimmer', :path => '../slimmer'
else
  gem 'slimmer', :git => 'git@github.com:alphagov/slimmer.git'
end

group :test do
  gem 'factory_girl_rails'
  gem 'mocha', :require => false
  gem "shoulda", "~> 2.11.3"
  gem 'simplecov', '0.4.2'
  gem 'simplecov-rcov'
  gem 'webmock', :require => false
  gem 'ci_reporter'
  gem 'test-unit'
  # Pretty printed test output
  gem 'turn', :require => false
end

group :development do
  gem 'ruby-debug19', :require => 'ruby-debug'
end

group :assets do
  gem 'sass-rails', "  ~> 3.1.0"
  gem 'coffee-rails', "~> 3.1.0"
  gem "therubyracer", "~> 0.9.4"
  gem 'uglifier'
end