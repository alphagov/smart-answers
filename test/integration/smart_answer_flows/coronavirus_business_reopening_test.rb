require_relative "../../test_helper"
require_relative "flow_test_helper"

require "smart_answer_flows/coronavirus-business-reopening.rb"

class CoronavirusBusinessReopeningFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::CoronavirusBusinessReopeningFlow
  end

  context "answered all questions" do
    should "reach results node" do
      assert_current_node :sectors?
      add_response "construction"
      assert_current_node :number_of_employees?
      add_response "over_4"
      assert_current_node :visitors?
      add_response "yes"
      assert_current_node :staff_meetings?
      add_response "yes"
      assert_current_node :staff_travel?
      add_response "yes"
      assert_current_node :send_or_receive_goods?
      add_response "yes"
      assert_current_node :results
    end
  end
end
