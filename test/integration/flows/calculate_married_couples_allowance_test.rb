# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class CalculateMarriedCouplesAllowanceTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'calculate-married-couples-allowance'
  end

  should "ask if you or partner were born before April 1935" do
    assert_current_node :were_you_or_your_partner_born_on_or_before_6_april_1935?
  end

  should "be sorry if neither born before 1935" do
    add_response :no
    assert_current_node :sorry
  end

  context "When eligible" do
    setup do
      add_response :yes
    end

    should "ask if married before 2005" do
      assert_current_node :did_you_marry_or_civil_partner_before_5_december_2005?
    end

    context "married before 2005" do
      setup do
        add_response :yes
      end

      should "save this answer" do
        assert_state_variable :married_before_05_12_2005, 'yes'
      end

      should "ask for the husband's DOB" do
        assert_current_node :whats_the_husbands_date_of_birth?
      end

      context "born in 1930" do
        setup do
          add_response '1930-05-25'
        end
        should "ask for the husband's income" do
          assert_current_node :whats_the_husbands_income?
        end
        should "end at husband_done" do
          add_response '2000.0'
          assert_current_node :husband_done
        end

        should "calculate allowance using calculators" do
          SmartAnswer::Calculators::AgeRelatedAllowanceChooser.any_instance.
            expects(:get_age_related_allowance).
            with(Date.parse '1930-05-25').
            returns("Age related allowance")
          SmartAnswer::Calculators::MarriedCouplesAllowanceCalculator.any_instance.
            expects(:calculate_allowance).
            with("Age related allowance", 14500.0).
            returns("Calculated allowance")

          add_response '14500.0'
          assert_state_variable :allowance, "Calculated allowance"
        end

        context "where the husband's income is greater than threshold" do
          setup do
            add_response '24500.01'
          end
          should "ask about pension payments" do
            assert_current_node :are_you_paying_a_pension?
          end
          context "answer yes" do
            setup do
              add_response 'yes'
            end
            should "ask about pensions and annuities" do
              assert_current_node :total_pension_and_annuities?
            end
            context "give an invalid answer" do
              should "raise an error" do
                add_response '-2'
                assert_current_node_is_error
              end
            end
            context "answer 5000" do
              setup do
                add_response '5000.0'
              end
              should "ask about tax relief pension contributions" do
                assert_current_node :tax_relief_pension_payments?
              end
              context "answer 6000" do
                setup do
                  add_response '6000.0'
                end
                should "ask about gift aid contributions" do
                  assert_current_node :gift_aid_payments?
                end
              end
            end
          end
          context "answer no" do
            setup do
              add_response 'no'
            end
            should "ask about gift aid payments" do
              assert_current_node :gift_aid_payments?
            end
            context "answer 1000" do
              setup do
                add_response '1000.0'
              end
              should "calculate the adjusted net income and be done" do
                assert_current_node :husband_done
              end
            end
          end
        end
      end
    end # before 2005

    context "married after 2005" do
      setup do
        add_response :no
      end

      should "ask for the highest earner's DOB" do
        assert_current_node :whats_the_highest_earners_date_of_birth?
      end

      context "born in 1930" do
        setup do
          add_response '1930-05-14'
        end
        should "ask for the highest earner's income" do
          assert_current_node :whats_the_highest_earners_income?
        end
        

        context "answer below the high earner threshold" do
          setup do
            add_response '13850.50'
          end
        
          should "calculate allowance using calculators" do
            SmartAnswer::Calculators::AgeRelatedAllowanceChooser.any_instance.
              expects(:get_age_related_allowance).
                with(Date.parse '1930-05-14').
                  returns("Age related allowance")
            SmartAnswer::Calculators::MarriedCouplesAllowanceCalculator.any_instance.
              expects(:calculate_allowance).
                with("Age related allowance", 13850.5).
                  returns("Calculated allowance")

            assert_state_variable :allowance, "Calculated allowance"
          end
          should "end at highest_earner_done" do
            assert_current_node :highest_earner_done
          end
        end # Below high earner threshold

        context "where the highest earner's income is greater than threshold" do
          setup do
            add_response '24500.01'
          end
          should "ask about pension payments" do
            assert_current_node :are_you_paying_a_pension?
          end
          context "answer yes" do
            setup do
              add_response 'yes'
            end
            should "ask about pensions and annuities" do
              assert_current_node :total_pension_and_annuities?
            end
            context "give an invalid answer" do
              should "raise an error" do
                add_response '-2'
                assert_current_node_is_error
              end
            end
            context "answer 5000" do
              setup do
                add_response '5000.0'
              end
              should "save the response as gross_pension_contributions" do
                assert_state_variable :gross_pension_contributions, 5000.0
              end
              should "ask about tax relief pension contributions" do
                assert_current_node :tax_relief_pension_payments?
              end
              context "answer 6000" do
                setup do
                  add_response '6000.0'
                end
                should "save the response as net_pension_contributions" do
                  assert_state_variable :net_pension_contributions, 6000.0
                end
                should "ask about gift aid contributions" do
                  assert_current_node :gift_aid_payments?
                end
              end
            end
          end
          context "answer no" do
            setup do
              add_response 'no'
            end
            should "ask about gift aid payments" do
              assert_current_node :gift_aid_payments?
            end
            context "answer 1000" do
              setup do
                add_response '1000.0'
              end
              should "calculate allowance using calculators" do
                SmartAnswer::Calculators::AgeRelatedAllowanceChooser.any_instance.
                  expects(:get_age_related_allowance).
                    with(Date.parse '1930-05-14').
                      returns("Age related allowance")               
                SmartAnswer::Calculators::MarriedCouplesAllowanceCalculator.any_instance.
                  expects(:calculate_high_earner_income).
                  with(income: 24500.01, gross_pension_contributions: nil,
                      net_pension_contributions: nil, gift_aid_contributions: 1000.0).
                  returns("Calculated income")
                SmartAnswer::Calculators::MarriedCouplesAllowanceCalculator.any_instance.
                  expects(:calculate_allowance).
                  with("Age related allowance", "Calculated income").
                  returns("Calculated allowance")

                assert_state_variable :allowance, "Calculated allowance"
              end
              should "calculate the adjusted net income and be done" do
                assert_current_node :highest_earner_done
              end
            end
          end
        end # Above high earner threshold
      end
    end # after 2005
  end
end
