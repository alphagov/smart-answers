# This file is copied to spec/ when you run 'rails generate rspec:install'
require "spec_helper"
ENV["RAILS_ENV"] ||= "test"

require "simplecov"

SimpleCov.start "rails" do
  add_group "Smart Answer Flows", "app/flows"
end

require File.expand_path("../config/environment", __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "gds_api/test_helpers/content_store"
require "rspec/rails"
require "slimmer/test"
require "webmock/rspec"

Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

GovukTest.configure

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  include GdsApi::TestHelpers::ContentStore
  include SmartAnswerFlowHelpers

  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4.
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # This option will default to `:apply_to_host_groups` in RSpec 4
  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.disable_monkey_patching!

  config.use_active_record = false # Remove this line to enable support for ActiveRecord
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!

  # Allow more verbose output when running an individual spec file.
  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random
  Kernel.srand config.seed

  # This following hooks enable using the fixture folder to define flows for testing
  # the core functionality of Smart Answers, rather than using existing flows to prevent
  # fragile dependencies.
  config.before(:example, flow_dir: :fixture) do
    stub_content_store_has_item("/session-based")
    stub_content_store_has_item("/query-parameters-based")
  end

  config.before(:context, flow_dir: :fixture) do
    fixture_load_path = Rails.root.join("spec/fixtures/flows")

    Dir[fixture_load_path.join("*.rb")].map { |path| require path }

    SmartAnswer::FlowRegistry.reset_instance(
      smart_answer_load_path: fixture_load_path,
    )
  end

  config.after(:context, flow_dir: :fixture) do
    SmartAnswer::FlowRegistry.reset_instance
  end
end
