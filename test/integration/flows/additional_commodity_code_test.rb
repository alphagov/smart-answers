require_relative "../../test_helper"
require_relative "flow_test_helper"

class AdditionalCommodityCodeTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow "additional-commodity-code"
  end
end
