require_relative '../../test_helper'
require_relative 'flow_test_helper'

class CalculateStatePensionTopupV2Test < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'state-pension-topup-v2'
  end

  should "ask date of birth" do
    assert_current_node :dob_age?
  end

  context "older than limit" do
    setup do
      add_response Date.parse('1914-10-12')
    end
    should "bring you to age limit reached outcome" do
      assert_current_node :outcome_age_limit_reached_birth
    end
  end

  context "younger than age limit" do
    setup do
      add_response Date.parse('1980-02-02')
    end
    should "bring you to age limit not reached outcome" do
      assert_current_node :outcome_pension_age_not_reached
    end
  end

  context "correct age inserted" do
    setup do
      add_response Date.parse('1950-02-02')
    end
    should "bring you to how_much_per_week question" do
      assert_current_node :gender?
    end

    context "gender inserted" do
      setup do
        add_response "male"
      end
      should "ask you topup amount" do
        assert_current_node :how_much_extra_per_week?

      end
      context "correct top up amount inserted" do
        setup do
          add_response 10
        end
        should "bring you to results outcome" do
          assert_current_node :top_up_calculations_both_ages
          assert_state_variable :weekly_amount, "10"
          assert_state_variable :date_of_birth, "1950-02-02"
          assert_state_variable :upper_age, 67
          assert_state_variable :lower_age, 65
          assert_state_variable :lower_rate_cost, 8900.00
        end
      end
    end
  end
  context "Man turns 65 on 6 April 2016 = DOB 6/4/1951 = *just* old enough 65 rate only" do
    setup do
      add_response Date.parse('1951-04-06')
      add_response "male"
      add_response 1
    end
    should "show lower rate only" do
      assert_current_node :top_up_calculations_lower_age
    end
  end
  context "Woman turns 63 on 6 April 2016 = DOB 6/4/1953 = *just* old enough 63 rate only" do
    setup do
      add_response Date.parse('1953-04-06')
      add_response "female"
      add_response 1
    end
    should "show lower rate only" do
      assert_current_node :top_up_calculations_lower_age
    end
  end
  context "Anyone turns 101 on 2 April 2017 = DOB 2/4/1916 = Old limit for 2 - show rate for 99 & 100" do
    setup do
      add_response Date.parse('1916-04-02')
      add_response "male"
      add_response 1
    end
    should "show both rates" do
      assert_state_variable :upper_age, 100
      assert_state_variable :lower_age, 99
      assert_state_variable :gender, "male"
      assert_current_node :top_up_calculations_both_ages
    end
  end
  context "Anyone who is 100y11m21d on 12 Oct 2015 = DOB 13/10/1914 = just young enough for 100 rate" do
    setup do
      add_response Date.parse('1914-10-13')
      add_response "male"
      add_response 1
    end
    should "show upper rate" do
      assert_state_variable :upper_age, 102
      assert_state_variable :lower_age, 100
      assert_state_variable :gender, "male"
      assert_current_node :top_up_calculations_upper_age
    end
  end
  context "Woman who is 62 on 6 April 2016 = DOB 7/4/1953 = new rules (A2)" do
    setup do
      add_response Date.parse('1953-04-07')
    end
    should "show both rates" do
      assert_current_node :outcome_pension_age_not_reached
    end
  end
end