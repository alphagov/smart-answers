require_relative "../../test_helper"
require_relative "flow_test_helper"

require "smart_answer_flows/coronavirus-find-support.rb"

class CoronavirusFindSupportFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::CoronavirusFindSupportFlow
  end

  context "specific outcomes" do
    should "show no specific information results for the minimal flow" do
      assert_current_node :need_help_with?
      add_response "none"
      assert_current_node :nation?
      add_response "england"
      assert_current_node :results
    end

    should "show results for a user that can get food and is self-employed" do
      assert_current_node :need_help_with?
      add_response "being_unemployed,feeling_unsafe,getting_food,going_to_work,mental_health,paying_bills,somewhere_to_live"
      assert_current_node :feel_safe?
      add_response "no"
      assert_current_node :afford_rent_mortgage_bills?
      add_response "no"
      assert_current_node :afford_food?
      add_response "no"

      assert_current_node :get_food?
      add_response "yes"
      assert_current_node :self_employed?
      add_response "yes"

      assert_current_node :worried_about_work?
      add_response "yes"
      assert_current_node :have_somewhere_to_live?
      add_response "no"
      assert_current_node :have_you_been_evicted?
      add_response "yes"
      assert_current_node :mental_health_worries?
      add_response "yes"
      assert_current_node :nation?
      add_response "england,scotland,wales,northern_ireland"
      assert_current_node :results
    end

    should "show results for a user that cannot get food, is not self-employed, and has been made unemployed" do
      assert_current_node :need_help_with?
      add_response "being_unemployed,feeling_unsafe,getting_food,going_to_work,mental_health,paying_bills,somewhere_to_live"
      assert_current_node :feel_safe?
      add_response "no"
      assert_current_node :afford_rent_mortgage_bills?
      add_response "no"
      assert_current_node :afford_food?
      add_response "no"

      assert_current_node :get_food?
      add_response "no"
      assert_current_node :able_to_go_out?
      add_response "yes"
      assert_current_node :self_employed?
      add_response "no"
      assert_current_node :have_you_been_made_unemployed?
      add_response "yes_i_have_been_made_unemployed"

      assert_current_node :worried_about_work?
      add_response "yes"
      assert_current_node :have_somewhere_to_live?
      add_response "no"
      assert_current_node :have_you_been_evicted?
      add_response "yes"
      assert_current_node :mental_health_worries?
      add_response "yes"
      assert_current_node :nation?
      add_response "england,scotland,wales,northern_ireland"
      assert_current_node :results
    end

    should "show results for a user that can get food, is not self-employed, and has not been made unemployed" do
      assert_current_node :need_help_with?
      add_response "being_unemployed,feeling_unsafe,getting_food,going_to_work,mental_health,paying_bills,somewhere_to_live"
      assert_current_node :feel_safe?
      add_response "no"
      assert_current_node :afford_rent_mortgage_bills?
      add_response "no"
      assert_current_node :afford_food?
      add_response "no"

      assert_current_node :get_food?
      add_response "yes"
      assert_current_node :self_employed?
      add_response "no"
      assert_current_node :have_you_been_made_unemployed?
      add_response "no"
      assert_current_node :are_you_off_work_ill?
      add_response "no"

      assert_current_node :worried_about_work?
      add_response "yes"
      assert_current_node :have_somewhere_to_live?
      add_response "no"
      assert_current_node :have_you_been_evicted?
      add_response "yes"
      assert_current_node :mental_health_worries?
      add_response "yes"
      assert_current_node :nation?
      add_response "england,scotland,wales,northern_ireland"
      assert_current_node :results
    end
  end
end
