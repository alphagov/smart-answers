require "test_helper"
require "support/flow_test_helper"

class CheckBenefitsSupportFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    testing_flow CheckBenefitsSupportFlow
  end

  should "render a start page" do
    assert_rendered_start_page
  end
  end
end
