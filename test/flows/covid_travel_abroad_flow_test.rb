require "test_helper"
require "support/flow_test_helper"

class CovidTravelAbroadFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    testing_flow CovidTravelAbroadFlow
  end

  should "render start page" do
    assert_rendered_start_page
  end
end
