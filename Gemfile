source "https://rubygems.org"

ruby File.read(".ruby-version").chomp

gem "rails", "6.1.4"

gem "ast"
gem "gds-api-adapters"
gem "gds_zendesk"
gem "govspeak"
gem "govuk_app_config"
gem "govuk-content-schema-test-helpers"
gem "govuk_publishing_components"
gem "htmlentities"
gem "httparty"
gem "json"
gem "method_source"
gem "parser"
gem "plek"
gem "rack_strip_client_ip"
gem "rails-i18n"
gem "railties"
gem "sassc-rails"
gem "slimmer"
gem "sprockets-rails"
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
  gem "govuk_test"
  gem "jasmine"
  gem "jasmine_selenium_runner"
  gem "pry"
  gem "rubocop-govuk", require: false
end

group :test do
  gem "launchy"
  gem "minitest"
  gem "minitest-focus"
  gem "mocha", require: false
  gem "rails-controller-testing"
  gem "shoulda"
  gem "simplecov", require: false
  gem "simplecov-rcov", require: false
  gem "webmock", require: false
end
