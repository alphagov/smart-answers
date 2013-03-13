source 'http://rubygems.org'
source 'https://BnrJb6FZyzspBboNJzYZ@gem.fury.io/govuk/'

gem 'unicorn', '4.3.1'
gem 'rails', '3.2.12'
gem 'rails-i18n'
gem 'json'
gem 'plek', '1.1.0'
gem 'govuk_frontend_toolkit', '0.3.3'
gem 'rummageable'
gem 'aws-ses', :require => 'aws/ses' # Needed by exception_notification
gem 'exception_notification'
gem 'lograge', '~> 0.1.0'
if ENV['API_DEV']
  gem 'gds-api-adapters', :path => '../gds-api-adapters'
else
  gem 'gds-api-adapters', '4.1.3'
end
gem 'htmlentities', '~> 4'

if ENV['SLIMMER_DEV']
  gem 'slimmer', :path => '../slimmer'
else
  gem 'slimmer', '3.9.5'
end

if ENV['GOVSPEAK_DEV']
  gem 'govspeak', :path => '../govspeak'
else
  gem 'govspeak', '~> 0.8.15'
end

gem 'uk_postcode', '1.0.0'

group :test do
  gem 'capybara', '~> 1.1.2'
  gem 'ci_reporter'
  gem 'mocha', :require => false
  gem 'shoulda', '~> 2.11.3'
  gem 'webmock', '1.8.0', :require => false
  gem 'simplecov', '~> 0.6.4', :require => false
  gem 'simplecov-rcov', '~> 0.2.3', :require => false
  gem 'capybara-webkit', '~> 0.12.1'
  gem 'timecop'
end

group :assets do
  gem 'sass-rails', '3.2.3'
  gem 'therubyracer', '~> 0.9.4'
  gem 'uglifier'
end

if ENV['RUBY_DEBUG']
  gem 'ruby-debug19'
end

group :analytics do
  gem 'google-api-client', :require => 'google/api_client'
end
