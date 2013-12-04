source 'http://rubygems.org'
source 'https://BnrJb6FZyzspBboNJzYZ@gem.fury.io/govuk/'

gem 'unicorn', '4.3.1'

gem 'rails', '3.2.16'

gem 'rails-i18n'
gem 'json'
gem 'plek', '1.1.0'
gem 'govuk_frontend_toolkit', '0.32.2'
gem 'aws-ses', :require => 'aws/ses' # Needed by exception_notification
gem 'exception_notification', '2.6.1'
gem 'lograge', '~> 0.1.0'
if ENV['API_DEV']
  gem 'gds-api-adapters', :path => '../gds-api-adapters'
else
  gem 'gds-api-adapters', '7.2.0'
end
gem 'htmlentities', '~> 4'

gem 'extlib', '0.9.16'

if ENV['SLIMMER_DEV']
  gem 'slimmer', :path => '../slimmer'
else
  gem 'slimmer', '3.20.0'
end

if ENV['GOVSPEAK_DEV']
  gem 'govspeak', :path => '../govspeak'
else
  gem 'govspeak', '1.2.3'
end

gem 'lrucache', '0.1.4'

group :test do
  gem 'capybara', '2.1.0'
  gem 'ci_reporter'
  gem 'mocha', '0.13.3', :require => false
  gem 'shoulda', '~> 2.11.3'
  gem 'webmock', '1.11.0', :require => false
  gem 'simplecov', '~> 0.6.4', :require => false
  gem 'simplecov-rcov', '~> 0.2.3', :require => false
  gem 'poltergeist', '1.3.0'
  gem 'timecop'
end

group :assets do
  gem 'sass-rails', '3.2.3'
  gem 'therubyracer', '~> 0.9.4'
  gem 'uglifier'
end

if ENV['RUBY_DEBUG']
  gem 'debugger', :require => "ruby-debug"
end

group :analytics do
  gem 'google-api-client', :require => 'google/api_client'
end
