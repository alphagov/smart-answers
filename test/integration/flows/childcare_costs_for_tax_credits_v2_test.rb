# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class ChildcareCostsForTaxCreditsV2Test < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'childcare-costs-for-tax-credits-v2'
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
            assert_current_node :how_much_12_months_2?
          end

          should "take you to the new_monthly_cost if you say monthly_same_amount" do
            add_response :monthly_same_amount
            assert_current_node :new_monthly_cost?
          end

          should "take you to 52 weeks question if you answer with monthly diff" do
            add_response :monthly_diff_amount
            assert_current_node :how_much_52_weeks_2?
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
          assert_current_node :call_helpline
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

          context "answering Q6" do
            setup do
              add_response :other
            end
            should "take you to weekly costs outcome" do
              assert_current_node :weekly_costs_are_x
            end

          end #Q6

        end #Q4

      end #Q2

    end
  end #Q1
end
