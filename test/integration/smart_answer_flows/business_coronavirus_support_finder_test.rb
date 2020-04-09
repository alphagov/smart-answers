require_relative "../../test_helper"
require_relative "flow_test_helper"

require "smart_answer_flows/business-coronavirus-support-finder.rb"

class BusinessCoronavirusSupportFinderFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::BusinessCoronavirusSupportFinderFlow
  end

  context "business based in England" do
    setup do
      assert_current_node :business_based?
      add_response "england"
      assert_current_node :business_size?
      add_response "small_medium_enterprise"
    end

    context "not self-employed" do
      setup do
        assert_current_node :self_employed?
        add_response "no"
        assert_current_node :annual_turnover?
        add_response "over_45m"
        assert_current_node :business_rates?
        add_response "yes"
        assert_current_node :non_domestic_property?
        add_response "over_15k"
        assert_current_node :self_assessment_july_2020?
        add_response "no"
        assert_current_node :sectors?
        add_response "retail"
      end

      should "reach results" do
        assert_current_node :results
      end
    end
  end
end
