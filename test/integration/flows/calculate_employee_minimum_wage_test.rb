require_relative "../../test_helper"
require_relative "flow_test_helper"

class CalculateEmployeeMinimumWageTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow "calculate-employee-minimum-wage"
  end
  
  # Q1
  should "ask 'what would you like to check?'" do
    assert_current_node :what_would_you_like_to_check?
  end
end
