require_relative "../../test_helper"
require_relative "flow_test_helper"

class BecomeAMotorcycleInstructorTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow "become-a-motorcycle-instructor"
  end

  should "ask if you are already qualified" do
    assert_current_node :qualified_motorcycle_instructor?
  end
end