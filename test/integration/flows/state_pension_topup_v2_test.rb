# encoding: UTF-8
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
          assert_current_node :outcome_topup_calculations
          assert_state_variable :weekly_amount, 10.0
          assert_state_variable :date_of_birth, "1950-02-02"
          assert_state_variable :amount_and_age, "- £8,900 when you're 65\n- £8,710 when you're 66\n- £8,470 when you're 67"
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
    should "show two rates" do
      assert_current_node :outcome_topup_calculations
      assert_state_variable :amount_and_age, "- £890 when you're 65\n- £871 when you're 66"
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
    should "show should two rates only" do
      assert_current_node :outcome_topup_calculations
      assert_state_variable :amount_and_age, "- £934 when you're 63\n- £913 when you're 64"
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
  context "Anyone turns 101 on 2 April 2017 = DOB 2/4/1916 = Old limit for 2 - show rates for 99 & 100" do
    setup do
      add_response Date.parse('1916-04-02')
      add_response "male"
      add_response 1
    end
    should "show two rates" do
      assert_current_node :outcome_topup_calculations
      assert_state_variable :amount_and_age, "- £137 when you're 99\n- £127 when you're 100"
      assert_state_variable :gender, "male"
    end
  end
  context "Anyone who is 100y11m21d on 12 Oct 2015 = DOB 13/10/1914 = just young enough for 100 rate" do
    setup do
      add_response Date.parse('1914-10-13')
      add_response "male"
      add_response 1
    end
    should "show one rate" do
      assert_current_node :outcome_topup_calculations
      assert_state_variable :amount_and_age, "- £127 when you're 100"
      assert_state_variable :gender, "male"
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
  context "Male born 13/10/1940 needs 3 rates" do
    setup do
      add_response Date.parse('1940-10-13')
      add_response "male"
      add_response 1
    end
    should "go to calculations outcome and show 3 rates" do
      assert_current_node :outcome_topup_calculations
      assert_state_variable :amount_and_age, "- £694 when you're 74\n- £674 when you're 75\n- £646 when you're 76"
    end
  end
end
