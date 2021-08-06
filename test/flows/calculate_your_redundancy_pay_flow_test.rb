require "test_helper"
require "support/flow_test_helper"
require "support/shared_flows/redundancy_pay_flow_test_helper"

class CalculateYourRedundancyPayFlowTest < ActiveSupport::TestCase
  include FlowTestHelper
  extend RedundancyPayFlowTestHelper

  setup do
    testing_flow CalculateYourRedundancyPayFlow
  end

  should "render a start page" do
    assert_rendered_start_page
  end

  context "test shared questions" do
    test_shared_redundancy_pay_flow_questions
  end
end
