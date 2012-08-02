# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class ChildcareCostsForTaxCreditsTest < ActiveSupport::TestCase
  include FlowTestHelper
  
  setup do
    setup_for_testing_flow 'childcare-costs-for-tax-credits'
  end
  
  # Q1
  context "ask 'is the the first time you have claimed?'" do
    should "be true" do
      assert_current_node :first_time_claim?
    end
    
    context "answer 'yes'" do
      setup do
        add_response :yes
      end
      # Q2
      should "ask 'about your childcare...'" do
        assert_current_node :frequency_of_childcare?
      end
      
      context "answer 'regularly for less than a year'" do
        setup do
          add_response :regularly_less_than_a_year
        end
        # Q4
        should "ask 'how often do you pay your providers?'" do
          assert_current_node :how_often_do_you_pay?
        end
        context "answer 'same amount weekly'" do
          # A1
          should "say 'round up the total'" do
            add_response :same_amount_weekly
            assert_current_node :round_up_total
          end
        end
        context "answer 'varying amount weekly'" do
          setup do
            add_response :varying_amount_weekly
          end
          # C1
          should "ask 'what is the total for 52 weeks?'" do
            assert_current_node :costs_for_year_in_weeks?
          end
        end
        context "answer 'same amount monthly" do
          setup do
            add_response :same_monthly
          end
          # C3
          should "ask 'how much do you pay each month?'" do
            assert_current_node :how_much_do_you_pay_each_month?
          end
        end
        context "answer 'varying amount monthly'" do
          setup do
            add_response :varying_amount_monthly
          end
          # C2
          should "ask 'what is the total cost over 12 months?'" do
            assert_current_node :costs_for_year_in_months?
          end
        end
        context "answer 'other'" do
          setup do
            add_response :other
          end
          # C4
          should "ask 'what is the total cost for 12 months?'" do
            assert_current_node :costs_for_year_in_months?
          end
        end
      end
      
      context "answer 'regularly for more than a year'" do
        setup do
          add_response :regularly_more_than_a_year
        end
        # Q5
        should "ask 'do you pay the same every time?'" do
          assert_current_node :do_you_pay_the_same_every_time?
        end
        context "answer 'yes'" do
          setup do
            add_response :yes
          end
          # Q6
          should "ask 'how often do you pay your providers?'" do
            assert_current_node :how_often_do_you_pay_your_providers?
          end
          context "answer 'weekly'" do
            should "say 'round up the total cost'" do
              add_response :weekly
              assert_current_node :round_up_total
            end
          end
          context "answer 'fortnightly'" do
            setup do
              add_response :fornightly
            end
            # C5
            should "ask 'how much do you pay each fortnight?'" do
              assert_current_node :how_much_do_you_pay_each_fortnight?
            end
          end
          context "answer 'every 4 weeks'" do
            setup do
              add_response :every_four_weeks
            end
            # C6
            should "ask 'how much do you pay every 4 weeks?'" do
              assert_current_node :how_much_do_you_pay_every_four_weeks?
            end
          end
          context "answer 'monthly'" do
            setup do
              add_response :monthly
            end
            # C7
            should "ask 'how much do you pay each month?'" do
              assert_current_node :how_much_do_you_pay_each_month?
            end
          end
          context "answer 'termly'" do
            # A10
            should "say 'contact the tax credit office'" do
              add_response :termly
              assert_current_node :contact_the_tax_credit_office
            end
          end
          context "answer 'yearly'" do
            setup do
              add_response :yearly
            end
            # C8
            should "ask 'how much do you pay annually?'" do
              assert_current_node :how_much_do_you_pay_anually?
            end
          end
          context "answer 'other'" do
            # A12
            should "say 'contact the tax credit office'" do
              add_response :other
              assert_current_node :contact_the_tax_credit_office
            end
          end
        end
      end
      context "answer 'intermittently'" do
        # A19
        should "say 'call the helpline'" do
          add_response :intermittently
          assert_current_node :call_the_helpline
        end
      end
      
    end
    
    context "answer 'no'" do
      setup do
        add_response :no
      end
      # Q3
      should "ask 'have the costs changed?'" do
        assert_current_node :have_the_costs_changed?
      end
      context "answer 'yes'" do
        setup do
          add_response :yes
        end
        # Q7
        should "ask 'how often and what do you pay providers?'" do
          assert_current_node :how_often_and_what_do_you_pay_your_providers?
        end
        context "answer 'same amount weekly'" do
          setup do
            add_response :same_amount_weekly # => :old_weekly_costs? # C10
          end
          # C10
          should "ask 'what was your previous weekly costs?'" do
            assert_current_node :old_weekly_costs?
          end
        end
        context "answer 'varying amount weekly'" do
          setup do
            add_response :varying_amount_weekly # => :old_annual_costs? # C11
          end
          # C11
          should "ask 'what were your previous annual costs?'" do
            assert_current_node :old_annual_costs?
          end
        end
        context "answer 'same amount monthly'" do
          setup do
            add_response :same_monthly # => :old_average_weekly_costs? # C13
          end
          # C13
          should "ask 'what were your previous average weekly costs?'" do
            assert_current_node :old_average_weekly_costs?
          end
        end
        context "answer 'varying amount monthly'" do
          setup do
            add_response :varying_amount_monthly # => :old_annual_costs? # C14
          end
          # C14
          should "ask 'what were your previous annual costs?'" do
            assert_current_node :old_annual_costs? # C12
          end
        end
        context "answer 'other'" do
          setup do
            add_response :other # => :old_annual_costs? # C12
          end
          # C12
          should "ask 'what were your previous annual costs?'" do
            assert_current_node :old_annual_costs?
          end
        end
      end
      context "answer 'no'" do
        # A20
        should "say 'no change to tax credits" do
          add_response :no
          assert_current_node :no_change_to_credits
        end
      end
    end
  end
end
