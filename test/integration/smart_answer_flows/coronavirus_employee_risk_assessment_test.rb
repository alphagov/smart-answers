require_relative "../../test_helper"
require_relative "flow_test_helper"

require "smart_answer_flows/coronavirus-employee-risk-assessment.rb"

class CoronavirusEmployeeRiskAssessmentFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::CoronavirusEmployeeRiskAssessmentFlow
  end

  context "outcomes" do
    should "show you should not be going to work outcome" do
      assert_current_node :where_do_you_work?
      add_response "food_and_drink"
      assert_current_node :is_your_workplace_an_exception?
      add_response "no"
      assert_current_node :is_your_employer_asking_you_to_work?
      add_response "no"
      assert_current_node :you_should_not_be_going_to_work
    end

    should "show work from home outcome" do
      assert_current_node :where_do_you_work?
      add_response "food_and_drink"
      assert_current_node :is_your_workplace_an_exception?
      add_response "no"
      assert_current_node :is_your_employer_asking_you_to_work?
      add_response "yes"
      assert_current_node :can_work_from_home?
      add_response "yes"
      assert_current_node :work_from_home
    end

    should "show get help to work from home outcome" do
      assert_current_node :where_do_you_work?
      add_response "food_and_drink"
      assert_current_node :is_your_workplace_an_exception?
      add_response "no"
      assert_current_node :is_your_employer_asking_you_to_work?
      add_response "yes"
      assert_current_node :can_work_from_home?
      add_response "maybe"
      assert_current_node :work_from_home_help
    end

    should "show shielding workplace arrangements outcome" do
      assert_current_node :where_do_you_work?
      add_response "food_and_drink"
      assert_current_node :is_your_workplace_an_exception?
      add_response "no"
      assert_current_node :is_your_employer_asking_you_to_work?
      add_response "yes"
      assert_current_node :can_work_from_home?
      add_response "no"
      assert_current_node :are_you_shielding?
      add_response "yes"
      assert_current_node :shielding_work_arrangements
    end

    should "show go back to work outcome" do
      assert_current_node :where_do_you_work?
      add_response "food_and_drink"
      assert_current_node :is_your_workplace_an_exception?
      add_response "no"
      assert_current_node :is_your_employer_asking_you_to_work?
      add_response "yes"
      assert_current_node :can_work_from_home?
      add_response "no"
      assert_current_node :are_you_shielding?
      add_response "no"
      assert_current_node :are_you_vulnerable?
      add_response "no"
      assert_current_node :do_you_live_with_someone_vulnerable?
      add_response "no"
      assert_current_node :have_childcare_responsibility?
      add_response "no"
      assert_current_node :go_back_to_work
    end
  end

  context "specific question flows" do
    should "show retail exception flow" do
      assert_current_node :where_do_you_work?
      add_response "retail"
      assert_current_node :is_your_workplace_an_exception?
      add_response "yes"
      assert_current_node :is_your_employer_asking_you_to_work?
    end

    should "show retail non exception flow" do
      assert_current_node :where_do_you_work?
      add_response "retail"
      assert_current_node :is_your_workplace_an_exception?
      add_response "no"
      assert_current_node :can_work_from_home?
    end

    should "show other flow" do
      assert_current_node :where_do_you_work?
      add_response "other"
      assert_current_node :can_work_from_home?
    end
  end
end
