ENV["RAILS_ENV"] = "test"
ENV["GOVUK_APP_DOMAIN"] = "test.gov.uk"

require File.expand_path("../config/environment", __dir__)

require "simplecov"
require "simplecov-rcov"

require "rails/test_help"

require "mocha/minitest"
Mocha.configure { |c| c.stubbing_non_existent_method = :prevent }

require "webmock/minitest"
WebMock.disable_net_connect!(allow_localhost: true)

require "gds_api/test_helpers/json_client_helper"
require "gds_api/test_helpers/content_store"
require "gds_api/test_helpers/imminence"
require "gds_api/test_helpers/publishing_api"
require "gds_api/test_helpers/worldwide"
require_relative "support/fixture_methods"

class ActiveSupport::TestCase
  include FixtureMethods
  include GdsApi::TestHelpers::ContentStore
  include GdsApi::TestHelpers::Imminence
  include GdsApi::TestHelpers::PublishingApi
  include GdsApi::TestHelpers::Worldwide
  include ActionDispatch::Assertions
  parallelize workers: :number_of_processors

  teardown do
    WorldLocation.reset_cache
  end
end

require "slimmer/test"
require "govuk-content-schema-test-helpers/test_unit"

GovukContentSchemaTestHelpers.configure do |config|
  config.schema_type = "publisher_v2"
  config.project_root = Rails.root
end
