require_relative "../../test_helper"
require_relative "flow_test_helper"

class MinimumWageCalculatorEmployersTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow "minimum-wage-calculator-employers"
  end
  
  # Q1
  should "ask 'what would you like to check?'" do
    assert_current_node :what_would_you_like_to_check?
  end

  # This is the employer version of the shared minimum wage calculator.
  # The full flow is tested in the employee version.
end
