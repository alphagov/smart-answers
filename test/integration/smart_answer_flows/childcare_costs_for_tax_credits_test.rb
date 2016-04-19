require_relative '../../test_helper'
require_relative 'flow_test_helper'

require "smart_answer_flows/childcare-costs-for-tax-credits"

class ChildcareCostsForTaxCreditsTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::ChildcareCostsForTaxCreditsFlow
  end

  context "answering Q1" do
    context "answering with yes" do
      setup do
        add_response :yes
      end

      should "take you to Q3 if you answer yes" do
        assert_current_node :have_costs_changed?
      end

      context "answering Q3" do
        should "take you to outcome if you answer no" do
          add_response :no
          assert_current_node :no_change
        end

        should "take you to how_often_pay_2 if you answer yes" do
          add_response :yes
          assert_current_node :how_often_pay_2?
        end

        context "answering Q5" do
          setup do
            add_response :yes
          end

          should "be Q5" do
            assert_current_node :how_often_pay_2?
          end

          should "take you to weekly costs for weekly answer" do
            add_response :weekly_same_amount
            assert_current_node :new_weekly_costs?
          end

          should "take you to how_much_12_months_2 if you answer with weekly diff amount" do
            add_response :weekly_diff_amount
            assert_current_node :how_much_52_weeks_2?
          end

          should "take you to the new_monthly_cost if you say monthly_same_amount" do
            add_response :monthly_same_amount
            assert_current_node :new_monthly_cost?
          end

          should "take you to 52 weeks question if you answer with monthly diff" do
            add_response :monthly_diff_amount
            assert_current_node :how_much_12_months_2?
          end
        end #Q5
      end #Q3
    end

    context "answering with no" do
      setup do
        add_response :no
      end

      should "take you to Q2 if you answer no" do
        assert_current_node :how_often_use_childcare?
      end

      context "answering Q2" do
        should "take you to how_often_pay_1 if you answer less than year" do
          add_response :regularly_less_than_year
          assert_current_node :how_often_pay_1?
        end

        should "take you to pay_same_each_time if you answer more than year" do
          add_response :regularly_more_than_year
          assert_current_node :pay_same_each_time?
        end

        should "take you to outcome if you answer only_short_while" do
          add_response :only_short_while
          assert_current_node :call_helpline_detailed
        end

        context "answering Q11" do
          setup do
            add_response :regularly_more_than_year #Q2
            add_response :yes #Q11
          end

          should "be on Q12 if you answer yes to Q11" do
            assert_current_node :how_often_pay_providers?
          end

          context "answering Q12" do
            setup do
              add_response :other
            end

            should "take user to helpline outcome" do
              assert_current_node :call_helpline_plain
            end
          end
        end

        context "answering Q4" do
          setup do
            add_response :regularly_less_than_year
          end

          should "take you to round_up_weekly outcome if you answer weekly_same_amount" do
            add_response :weekly_same_amount
            assert_current_node :round_up_weekly
          end

          should "take you to how_much_12_months if you answer with other" do
            add_response :other
            assert_current_node :how_much_12_months_1?
          end

          context "answering Q7" do
            setup do
              add_response :weekly_diff_amount
            end
            should "calculate the weekly cost and take user to outcome" do
              add_response 52
              assert_current_node :weekly_costs_are_x
              assert_state_variable :weekly_cost, 1
            end
          end #Q7

          context "answering Q6" do
            setup do
              add_response :other # answer Q4
              add_response 52 # answer Q6
            end
            should "take you to weekly costs outcome" do
              assert_current_node :weekly_costs_are_x
            end

            should "calculate the weekly cost" do
              assert_state_variable :weekly_cost, 1
            end
          end #Q6
        end #Q4
      end #Q2
    end
  end #Q1

  context "calculating weekly costs" do
    context "through Question 10" do
      setup do
        add_response :no #Q1
        add_response :regularly_more_than_year #Q2
        add_response :yes #Q11
        add_response :every_month #Q12
      end

      should "calculate the weekly cost" do
        add_response 4 #Q10
        assert_state_variable :weekly_cost, 1
        assert_current_node :weekly_costs_are_x
      end
    end
    context "through Question 13" do
      setup do
        add_response :no #Q1
        add_response :regularly_more_than_year #Q2
        add_response :yes #Q11
        add_response :fortnightly #Q12
      end

      should "ask you how much you pay fortnightly" do
        add_response 10 # Answer Q13
        assert_state_variable :weekly_cost, 5
        assert_current_node :weekly_costs_are_x
      end
    end # Q13

    context "through Question 14" do
      setup do
        add_response :no #Q1
        add_response :regularly_more_than_year #Q2
        add_response :yes #Q11
        add_response :every_4_weeks #Q12
      end

      should "calculate the weekly cost" do
        add_response 20 #Q14
        assert_state_variable :weekly_cost, 5
        assert_current_node :weekly_costs_are_x
      end
    end # Q14

    context "through Question 15" do
      setup do
        add_response :no #Q1
        add_response :regularly_more_than_year #Q2
        add_response :yes #Q11
        add_response :yearly #Q12
      end

      should "calculate the weekly cost" do
        add_response 52 #Q14
        assert_state_variable :weekly_cost, 1
        assert_current_node :weekly_costs_are_x
      end
    end # Q15
  end # questions that lead to weekly-costs outcome

  context "questions that calculate the difference in costs" do
    context "Through Question 18" do
      setup do
        add_response :yes #Q1
        add_response :yes #Q3
        add_response :weekly_diff_amount #Q5
      end

      should "be at Q8" do
        assert_current_node :how_much_52_weeks_2?
      end

      should "be at Q18" do
        add_response 52 #Q8
        assert_current_node :old_weekly_amount_1?
      end

      should "calculate weekly_cost from Q8" do
        add_response 52 #Q8
        assert_state_variable :weekly_cost, 1
      end

      should "calculate diff after answering Q18" do
        add_response 52 # Q8
        add_response 2 # Q18
        assert_state_variable :old_weekly_cost, 2
        assert_state_variable :weekly_difference, -1
        assert_state_variable :weekly_difference_abs, 1
        assert_state_variable :cost_change_4_weeks, false
        assert_current_node :cost_changed
      end
    end # Q18
  end # questions that calculate cost difference

  context "going through Question 17" do
    setup do
      add_response :yes #Q1
      add_response :yes #Q3
      add_response :weekly_same_amount #Q5
    end

    should "be at Q17" do
      assert_current_node :new_weekly_costs?
    end

    should "take user to not paying output if they answer 0" do
      add_response 0
      assert_current_node :no_longer_paying
    end

    should "take user to Q20 if they give an answer" do
      add_response 1
      assert_state_variable :new_weekly_costs, 1
      assert_current_node :old_weekly_amount_2?
    end

    context "answering Q20" do
      setup do
        add_response 1 # Q17
        add_response 11 # Q20
      end

      should "calculate the old costs based on user answer" do
        assert_state_variable :old_weekly_costs, 11
        assert_state_variable :weekly_difference, -10
        assert_state_variable :weekly_difference_abs, 10
        assert_state_variable :ten_or_more, true
        assert_state_variable :cost_change_4_weeks, true
        assert_current_node :cost_changed
      end

      should "show correct phrases" do
        assert_state_variable :title_change_text, "decreased"
      end
    end # Q20
  end # Q17

  context "going through Q19" do
    setup do
      add_response :yes #Q1
      add_response :yes #Q3
      add_response :monthly_same_amount #Q5
    end

    should "be at Q19" do
      assert_current_node :new_monthly_cost?
    end

    should "take user to not paying output if they answer 0" do
      add_response 0
      assert_current_node :no_longer_paying
    end

    should "take the user to Q21 if they give an answer" do
      add_response 4
      assert_state_variable :new_weekly_costs, 1
      assert_current_node :old_weekly_amount_3?
    end

    context "answering Q21" do
      setup do
        add_response 4 # Q19
        add_response 10
      end

      should "calculate old costs and difference" do
        assert_state_variable :old_weekly_costs, 10
        assert_state_variable :weekly_difference, -9
        assert_state_variable :ten_or_more, false
        assert_state_variable :title_change_text, "decreased"
        assert_state_variable :cost_change_4_weeks, false
        assert_current_node :cost_changed
      end
    end
  end

  context "answering Q16" do
    setup do
      add_response :no #Q1
      add_response :regularly_more_than_year #Q2
      add_response :no #Q11
    end

    should "be on Q16" do
      assert_current_node :how_much_spent_last_12_months?
    end

    should "take user to weekly outcome" do
      add_response 52
      assert_state_variable :weekly_cost, 1
      assert_current_node :weekly_costs_are_x
    end
  end
end
