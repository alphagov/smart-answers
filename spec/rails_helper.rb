# This file is copied to spec/ when you run 'rails generate rspec:install'
require "spec_helper"
ENV["RAILS_ENV"] ||= "test"

require "simplecov"

SimpleCov.start "rails" do
  add_group "Smart Answer Flows", "lib/smart_answer_flows"
end

require File.expand_path("../config/environment", __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"

Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

GovukTest.configure

require "webmock/rspec"
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  require "gds_api/test_helpers/content_store"
  include GdsApi::TestHelpers::ContentStore
  include ClickGovukStartButton
  include SmartAnswerFlowHelpers

  config.use_active_record = false # Remove this line to enable support for ActiveRecord
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
end

# Without this GovukContentSchemaTestHelpers configuration, get `NoMethodError: undefined method `<<' for nil:NilClass`
require "slimmer/test"
require "govuk-content-schema-test-helpers/test_unit"

GovukContentSchemaTestHelpers.configure do |config|
  config.schema_type = "publisher_v2"
  config.project_root = Rails.root
end
