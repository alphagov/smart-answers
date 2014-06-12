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

  context "older than 100 years" do
    setup do
      add_response Date.parse('1900-02-02')
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
      assert_current_node :how_much_extra_per_week?
    end

    context "correct amount inserted" do
      setup do
        add_response 10
      end
      should "bring you to date_of_lump_sum_payment question" do
        assert_current_node :date_of_lump_sum_payment?

      end

      context "correct date of payment inserted" do
        setup do
          add_response Date.parse('2016-02-02')
        end
        should "bring you to gender question" do
          assert_current_node :gender?
        end

        context "gender inserted" do
          setup do
            add_response :female
          end
          should "bring you to final outcome and show result" do
            assert_current_node :outcome_qualified_for_top_up_calculations
            assert_state_variable :rate_at_time_of_paying, 8710.0
            assert_state_variable :age_at_date_of_payment, 66
            assert_state_variable :date_of_payment, Date.parse('2016-02-02')
            assert_state_variable :weekly_amount, "10"
          end
        end
      end

      context "incorrect date of payment inserted(outside of range)" do
        setup do
          add_response Date.parse('2015-02-02')
        end
        should "raise error_message" do
          assert_current_node_is_error
        end
      end
    end

    context "invalid amount (not integer) inserted" do
      setup do
        add_response 10.1
      end
      should "raise error_message" do
        assert_current_node_is_error
      end
    end

    context "invalid amount (outside of range) inserted" do
      setup do
        add_response 30
      end
      should "raise error_message" do
        assert_current_node_is_error
      end
    end
  end

  context "Female, dob 22/03/53 can reach outcome" do
    setup do
      add_response Date.parse('1953-03-22')
      add_response 25
      add_response Date.parse('2015-10-12')
      add_response :female
    end
    should "bring you to final result outcome" do
      assert_current_node :outcome_qualified_for_top_up_calculations
      assert_state_variable :rate_at_time_of_paying, 23350.0
      assert_state_variable :age_at_date_of_payment, 62
      assert_state_variable :weekly_amount, "25"
    end
  end

  context "Check if a 63 years WOMAN is allowed to use the tool" do
    setup do
      add_response Date.parse('1953-02-02')
      add_response 20
      add_response Date.parse('2016-02-02')
      add_response :female
    end
    should "bring you to final result outcome" do
      assert_current_node :outcome_qualified_for_top_up_calculations
      assert_state_variable :rate_at_time_of_paying, 18680.0
      assert_state_variable :age_at_date_of_payment, 63
      assert_state_variable :weekly_amount, "20"
    end
  end
  context "check if a 62 years old MAN is NOT allowed to use the tool" do
    setup do
      add_response Date.parse('1953-02-02')
      add_response 10
      add_response Date.parse('2016-02-02')
      add_response :male
    end
    should "bring you to age limit not reached outcome" do
      assert_current_node :outcome_pension_age_not_reached
      assert_state_variable :age_at_date_of_payment, 63
    end
  end

  context "check 13 October 1914 dob not allowed to use tool" do
    setup do
      add_response Date.parse('1914-10-13') # Young enough
      add_response 10
      add_response Date.parse('2015-10-14') # Too old at payment date
    end

    should "go to outcome" do
      assert_current_node :outcome_age_limit_reached_payment
    end
  end
end
