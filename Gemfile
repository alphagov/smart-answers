source 'http://rubygems.org'
source 'https://BnrJb6FZyzspBboNJzYZ@gem.fury.io/govuk/'

gem 'unicorn', '4.3.1'

# Keeping Rails at 3.2.12 due to a regression involving PUT requests
# over HTTPS that have a body size larger than 16K.
#
# The security patches from 3.2.13 have been applied directly and can
# be found in config/initializers/3-2-*-patch.rb. Please remove these
# patches when incrementing the Rails version.
gem 'rails', '3.2.12'

gem 'rails-i18n'
gem 'json'
gem 'plek', '1.1.0'
gem 'govuk_frontend_toolkit', '0.3.3'
gem 'aws-ses', :require => 'aws/ses' # Needed by exception_notification
gem 'exception_notification'
gem 'lograge', '~> 0.1.0'
if ENV['API_DEV']
  gem 'gds-api-adapters', :path => '../gds-api-adapters'
else
  gem 'gds-api-adapters', '6.0.0'
end
gem 'htmlentities', '~> 4'

gem 'extlib', '0.9.16'

if ENV['SLIMMER_DEV']
  gem 'slimmer', :path => '../slimmer'
else
  gem 'slimmer', '3.16.0'
end

if ENV['GOVSPEAK_DEV']
  gem 'govspeak', :path => '../govspeak'
else
  gem 'govspeak', '~> 0.8.15'
end

gem 'lrucache', '0.1.4'

group :test do
  gem 'capybara', '~> 1.1.2'
  gem 'ci_reporter'
  gem 'mocha', '0.13.3', :require => false
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
