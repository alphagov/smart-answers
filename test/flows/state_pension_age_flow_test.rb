require "test_helper"
require "support/flow_test_helper"

class StatePensionAgeFlowTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup { testing_flow StatePensionAgeFlow }

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: which_calculation?" do
    setup { testing_node :which_calculation? }

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of dob_age? for any response" do
        assert_next_node :dob_age?, for_response: "age"
      end
    end
  end

  context "question: dob_age?" do
    setup do
      testing_node :dob_age?
      add_responses which_calculation?: "age"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid for date of birth after the current time" do
        assert_invalid_response (Time.zone.today + 1.day).to_s
      end

      should "be valid for date of birth before or equal to the current time" do
        assert_valid_response Time.zone.yesterday.to_s
      end
    end

    context "next_node" do
      should "have a next node of gender? when dob is before 6 December 1953" do
        assert_next_node :gender?, for_response: "05-12-1953"
      end

      should "have a next node of not_yet_reached_sp_age when state pension age has not been reached" do
        assert_next_node :not_yet_reached_sp_age, for_response: Time.zone.today.to_s
      end

      should "have a next node of has_reached_sp_age when state pension age has been reached and is not based on gender" do
        assert_next_node :has_reached_sp_age, for_response: "06-12-1953"
      end

      should "have a next node of bus_pass_result for a bus_pass calculation" do
        add_responses which_calculation?: "bus_pass"
        assert_next_node :bus_pass_result, for_response: "01-01-2000"
      end
    end
  end

  context "question: gender?" do
    setup do
      testing_node :gender?
      add_responses which_calculation?: "age",
                    dob_age?: "05-12-1953"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of has_reached_sp_age_non_binary for non-binary gender identity" do
        assert_next_node :has_reached_sp_age_non_binary, for_response: "prefer_not_to_say"
      end

      should "have a next node of has_reached_sp_age when state pension age has been reached" do
        assert_next_node :has_reached_sp_age, for_response: "female"
      end
    end
  end

  context "outcome: not_yet_reached_sp_age" do
    setup do
      testing_node :not_yet_reached_sp_age
      add_responses which_calculation?: "age"
    end

    should "render that the pension age may increase" do
      add_responses dob_age?: "04-04-1988"
      assert_rendered_outcome text: "This may change"
    end

    should "render that you can apply for your state pension 2 months before state pension date" do
      add_responses dob_age?: Time.zone.today.to_s

      travel(68.years - 1.month)

      assert_rendered_outcome text: "You can claim your State Pension now"

      travel_back
    end

    should "render that you can get a forecast of your state pension over 30 days before state pension date" do
      add_responses dob_age?: Time.zone.today.to_s

      travel(68.years - 35.days)

      assert_rendered_outcome text: "You can get a forecast or statement of how much State Pension you may get"

      travel_back
    end
  end
end
