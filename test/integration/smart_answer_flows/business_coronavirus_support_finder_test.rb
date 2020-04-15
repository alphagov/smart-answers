require_relative "../../test_helper"
require_relative "flow_test_helper"

require "smart_answer_flows/business-coronavirus-support-finder.rb"

class BusinessCoronavirusSupportFinderFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::BusinessCoronavirusSupportFinderFlow
  end

  context "flow to a results outcome" do
    should "reach results node" do
      assert_current_node :business_based?
      add_response "england"
      assert_current_node :business_size?
      add_response "0_to_249"
      assert_current_node :annual_turnover?
      add_response "45m_to_500m"
      assert_current_node :paye_scheme?
      add_response "no"
      assert_current_node :non_domestic_property?
      add_response "over_15k"
      assert_current_node :self_assessment_july_2020?
      add_response "no"
      assert_current_node :sectors?
      add_response "retail"
      assert_current_node :results
    end
  end
end
