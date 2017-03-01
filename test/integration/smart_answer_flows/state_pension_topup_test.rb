require_relative '../../test_helper'
require_relative 'flow_test_helper'

require "smart_answer_flows/state-pension-topup"

class CalculateStatePensionTopupTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::StatePensionTopupFlow
  end

  should "ask date of birth" do
    assert_current_node :dob_age?
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
        Timecop.freeze('2016-12-01')
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
          assert_current_node :outcome_topup_calculations
          assert_equal 10.0, current_state.calculator.weekly_amount
          assert_equal Date.parse("1950-02-02"), current_state.calculator.date_of_birth
          assert_equal [
            { amount: SmartAnswer::Money.new(8710), age: 66 },
            { amount: SmartAnswer::Money.new(8470), age: 67 }
          ], current_state.calculator.lump_sum_and_age
        end
      end
    end
  end
  context "Man turns 65 on 5 April 2016 = DOB 5/4/1951 = *just old enough*" do
    setup do
      add_response Date.parse('1951-04-05')
      add_response "male"
      add_response 1
    end
    should "qualify for top up" do
      assert_current_node :outcome_topup_calculations
      assert current_state.calculator.lump_sum_and_age.present?
    end
  end
  context "Man turns 65 on 6 April 2016 = DOB 6/4/1951 = not old enough" do
    setup do
      add_response Date.parse('1951-04-06')
      add_response "male"
    end
    should "show age not reached outcome" do
      assert_current_node :outcome_pension_age_not_reached
    end
  end
  context "Woman turns 63 on 5 April 2016 = DOB 5/4/1953 = *just* old enough" do
    setup do
      add_response Date.parse('1953-04-05')
      add_response "female"
      add_response 1
    end
    should "qualify for top up" do
      assert_current_node :outcome_topup_calculations
      assert current_state.calculator.lump_sum_and_age.present?
    end
  end
  context "Woman turns 63 on 6 April 2016 = DOB 6/4/1953 = not old enough" do
    setup do
      add_response Date.parse('1953-04-06')
    end
    should "show age not reached outcome" do
      assert_current_node :outcome_pension_age_not_reached
    end
  end
  context "Anyone turns 101 on 2 April 2017 = DOB 2/4/1916 with a top up of £1 a week" do
    setup do
      Timecop.freeze('2016-12-01')
      add_response Date.parse('1916-04-02')
      add_response "male"
      add_response 1
    end
    should "show two rates, both of them being for the max age rate (100 years old) and a lump sum of £127)" do
      assert_current_node :outcome_topup_calculations
      assert_equal [
        { amount: SmartAnswer::Money.new(127), age: 100 },
        { amount: SmartAnswer::Money.new(127), age: 101 }
      ], current_state.calculator.lump_sum_and_age
      assert_equal "male", current_state.calculator.gender
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
  context "Male born 13/10/1940 needs one rate" do
    setup do
      add_response Date.parse('1940-10-14')
      add_response "male"
      add_response 1
    end
    should "go to calculations outcome and show one rate" do
      assert_current_node :outcome_topup_calculations
      assert_equal [
        { amount: SmartAnswer::Money.new(646), age: 76 }
      ], current_state.calculator.lump_sum_and_age
    end
  end
end
