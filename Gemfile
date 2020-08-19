source "https://rubygems.org"

ruby File.read(".ruby-version").chomp

gem "rails", "6.0.3.2"

gem "railties"
gem "sprockets-rails"

gem "govuk_app_config"

gem "ast"
gem "gds-api-adapters"
gem "govspeak"
gem "govuk-content-schema-test-helpers"
gem "govuk_publishing_components"
gem "htmlentities"
gem "json"
gem "method_source"
gem "parser"
gem "plek"
gem "rack_strip_client_ip"
gem "rails-i18n"
gem "sass-rails"
gem "slimmer"
gem "tilt"
gem "uglifier"
gem "uk_postcode"

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem "listen"
  gem "nokogiri"
end

group :development, :test do
  gem "byebug"
  gem "pry"
  gem "rubocop-govuk"
end

group :test do
  gem "ci_reporter"
  gem "govuk_test"
  gem "minitest"
  gem "minitest-focus"
  gem "mocha", require: false
  gem "rails-controller-testing"
  gem "shoulda"
  gem "simplecov", require: false
  gem "simplecov-rcov", require: false
  gem "timecop"
  gem "webmock", require: false
end
