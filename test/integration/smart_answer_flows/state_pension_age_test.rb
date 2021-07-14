require_relative "../../test_helper"
require_relative "flow_integration_test_helper"

class StatePensionAgeTest < ActiveSupport::TestCase
  include FlowIntegrationTestHelper

  setup do
    setup_for_testing_flow StatePensionAgeFlow
  end

  should "ask which calculation to perform" do
    assert_current_node :which_calculation?
  end

  # Calculating State Pension Age
  context "state pension age calculation" do
    setup do
      add_response :age
    end

    should "ask for date of birth" do
      assert_current_node :dob_age?
    end

    should "prevent from providing future dates" do
      add_response(Time.zone.today + 1).to_s
      assert_current_node_is_error
    end

    should "prevent from providing dates too far in the past" do
      add_response(200.years.ago).to_s
      assert_current_node_is_error
    end
  end

  # Calculating State Pension Age
  context "gender question" do
    context "when born before 6th December 1953" do
      setup do
        add_response :age
        add_response Date.parse("5th Dec 1953")
      end

      should "ask for your gender" do
        assert_current_node :gender?
      end
    end

    context "when born after 6th December 1953" do
      setup do
        add_response :age
        add_response Date.parse("6th December 1953")
      end

      should "display the outcome" do
        assert_current_node :has_reached_sp_age
      end
    end

    context "when gender is prefer not to say" do
      setup do
        add_response :age
        add_response Date.parse("5th December 1953")
        add_response :prefer_not_to_say
      end

      should "display the outcome" do
        assert_current_node :has_reached_sp_age_non_binary
      end
    end
  end

  # Calculating State Pension Age
  context "when you have not reach your state pension yet" do
    setup do
      add_response :age
      add_response Date.parse("5th December 1975")
    end

    should "show you have not yet reached state pension age" do
      assert_current_node :not_yet_reached_sp_age
    end
  end

  context "when you have reached state pension age" do
    setup do
      add_response :age
      add_response Date.parse("5th December 1945")
      add_response :male
    end

    should "show you have reached state pension age" do
      assert_current_node :has_reached_sp_age
    end
  end

  context "bus pass age calculation" do
    setup do
      add_response :bus_pass
    end

    should "ask for date of birth" do
      assert_current_node :dob_age?
    end

    should "prevent from providing future dates" do
      add_response(Time.zone.today + 1).to_s
      assert_current_node_is_error
    end

    should "prevent from providing dates too far in the past" do
      add_response(200.years.ago).to_s
      assert_current_node_is_error
    end
  end

  context "showing bus page result" do
    setup do
      add_response :bus_pass
      add_response Date.parse("5th December 1975")
    end

    should "show you a bus pass result" do
      assert_current_node :bus_pass_result
    end

    should "show you the date you reach your bus pass qualification result" do
      assert_match(/5 December 2042/, outcome_body)
    end
  end
end
