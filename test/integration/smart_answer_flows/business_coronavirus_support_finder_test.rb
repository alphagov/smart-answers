require_relative "../../test_helper"
require_relative "flow_test_helper"

require "smart_answer_flows/business-coronavirus-support-finder.rb"

class BusinessCoronavirusSupportFinderFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::BusinessCoronavirusSupportFinderFlow
  end

  context "flow with sectors" do
    should "reach results node" do
      assert_current_node :business_based?
      add_response "england"
      assert_current_node :business_size?
      add_response "0_to_249"
      assert_current_node :annual_turnover?
      add_response "500m_and_over"
      assert_current_node :paye_scheme?
      add_response "yes"
      assert_current_node :self_employed?
      add_response "yes"
      assert_current_node :non_domestic_property?
      add_response "51k_and_over"
      assert_current_node :sectors?
      add_response "retail_hospitality_or_leisure"
      assert_current_node :rate_relief_march_2020?
      add_response "yes"
      assert_current_node :results
    end
  end

  context "flow without sectors" do
    should "reach results node" do
      assert_current_node :business_based?
      add_response "scotland"
      assert_current_node :business_size?
      add_response "over_249"
      assert_current_node :annual_turnover?
      add_response "45m_to_500m"
      assert_current_node :paye_scheme?
      add_response "no"
      assert_current_node :self_employed?
      add_response "no"
      assert_current_node :non_domestic_property?
      add_response "none"
      assert_current_node :results
    end
  end
end
