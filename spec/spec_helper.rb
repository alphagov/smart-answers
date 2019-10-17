ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"

RSpec.configure do |config|
  config.infer_spec_type_from_file_location! # https://relishapp.com/rspec/rspec-rails/v/3-8/docs/directory-structure

  config.expose_dsl_globally = false # https://relishapp.com/rspec/rspec-core/v/3-0/docs/configuration/global-namespace-dsl

  config.use_transactional_fixtures = true # https://relishapp.com/rspec/rspec-rails/docs/transactions

  config.filter_rails_from_backtrace! # https://relishapp.com/rspec/rspec-rails/v/3-8/docs/backtrace-filtering

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true # https://relishapp.com/rspec/rspec-expectations/docs/custom-matchers/define-matcher-with-fluent-interface
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true # https://relishapp.com/rspec/rspec-mocks/docs/verifying-doubles/partial-doubles
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups # https://relishapp.com/rspec/rspec-core/docs/example-groups/shared-context
end
