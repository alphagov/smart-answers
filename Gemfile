source 'https://rubygems.org'

gem 'unicorn', '4.8.3'

gem 'rails', '4.0.0'

gem 'rails-i18n'
gem 'json'
gem 'plek', '1.7.0'
gem 'govuk_frontend_toolkit', '3.1.0'
gem 'airbrake', '3.1.15'
gem 'logstasher', '0.4.8'
gem 'rack_strip_client_ip', '0.0.1'
gem 'diffy', '3.0.6'
gem 'filesize'
gem 'tilt', '1.4.1'
gem 'syck', '1.0.5'

gem 'sass-rails', '~> 4.0.0'
gem 'therubyracer', '~> 0.12.1'
gem 'uglifier'

if ENV['SMARTDOWN_DEV']
  gem 'smartdown', :path => '../smartdown'
else
  gem 'smartdown', '0.14.0'
end

if ENV['API_DEV']
  gem 'gds-api-adapters', :path => '../gds-api-adapters'
else
  gem 'gds-api-adapters', '10.16.0'
end
gem 'htmlentities', '~> 4'

gem 'extlib', '0.9.16'

if ENV['SLIMMER_DEV']
  gem 'slimmer', :path => '../slimmer'
else
  gem 'slimmer', '8.1.0'
end

if ENV['GOVSPEAK_DEV']
  gem 'govspeak', :path => '../govspeak'
else
  gem 'govspeak', '~> 3.2.0'
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
  gem 'poltergeist', '1.5.1'
  gem 'timecop'
  gem 'minitest', '4.7.5'
  gem 'minitest-reporters'
end

group :development do
  gem 'parser'
  gem 'pry'
  gem 'rubocop'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'nokogiri', '1.5.11'
end

if ENV['RUBY_DEBUG']
  gem 'debugger', :require => "ruby-debug"
end

group :analytics do
  gem 'google-api-client', :require => 'google/api_client'
end
