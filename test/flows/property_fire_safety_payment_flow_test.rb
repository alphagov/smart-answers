require "test_helper"
require "support/flow_test_helper"

class PropertyFireSafetyPaymentFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    testing_flow PropertyFireSafetyPaymentFlow
  end
end