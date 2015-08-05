require_relative '../../test_helper'
require_relative 'flow_test_helper'

require "smart_answer_flows/calculate-married-couples-allowance"

class CalculateMarriedCouplesAllowanceTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::CalculateMarriedCouplesAllowanceFlow
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

      should "ask for the husband's DOB" do
        assert_current_node :whats_the_husbands_date_of_birth?
      end

      should "ask for the husband's income" do
        add_response '1930-05-25'
        assert_current_node :whats_the_husbands_income?
      end

      should "reject an invalid income" do
        add_response '1930-05-25'
        add_response "-100.0"

        assert_current_node_is_error
      end

      should "reject an income of zero" do
        add_response '1930-05-25'

        add_response '0'
        assert_current_node_is_error
      end

      context "income > 25400" do
        setup do
          add_response '1930-05-25'
          add_response '30000'
        end

        should "ask if paying into a pension" do
          assert_current_node :paying_into_a_pension?
        end

        context "paying into a pension" do
          setup do
            add_response "yes"
          end

          should "ask amount of contributions before tax is taken away" do
            assert_current_node :how_much_expected_contributions_before_tax?
          end

          context "paying 1000 before tax" do
            setup do
              add_response "1000"
            end

            should "ask amount of contributions where pension provider claims tax relief" do
              assert_current_node :how_much_expected_contributions_with_tax_relief?
            end

            context "paying 500 with tax relief" do
              setup do
                add_response "500"
              end

              should "ask how much expected donation to charity through Gift Aid in tax year" do
                assert_current_node :how_much_expected_gift_aided_donations?
              end

              context "donating 100 with gift aid" do
                setup do
                  add_response "100.0"
                end

                should "end at husband_done" do
                  assert_current_node :husband_done
                end

                should "calculate allowance using calculators" do
                  SmartAnswer::Calculators::MarriedCouplesAllowanceCalculator.any_instance.
                    expects(:calculate_adjusted_net_income)
                    .with(30000.0, 1000.0, 500.0, 100.0)
                    .returns("Adjusted net income")

                  SmartAnswer::AgeRelatedAllowanceChooser.any_instance.
                    expects(:get_age_related_allowance).
                    with(Date.parse '1930-05-25').
                    returns("Age related allowance")
                  SmartAnswer::Calculators::MarriedCouplesAllowanceCalculator.any_instance.
                    expects(:calculate_allowance).
                    with("Age related allowance", 'Adjusted net income').
                    returns("Calculated allowance")

                  assert_state_variable :allowance, "Calculated allowance"
                end
              end # donating 100 with gift aid
            end # paying 500 with tax relief
          end # paying 1000 before tax

          context "paying 0 before tax" do
            setup do
              add_response "0"
            end

            should "ask amount of contributions where pension provider claims tax relief" do
              assert_current_node :how_much_expected_contributions_with_tax_relief?
            end
          end # paying 0 before tax

          context "paying a greater amount into a pension than income" do
            setup do
              add_response "40000"
              add_response "0"
            end

            should "end at husband_done" do
              add_response "0"
              assert_current_node :husband_done
            end

            should "calculate allowance using calculators" do
              SmartAnswer::Calculators::MarriedCouplesAllowanceCalculator.any_instance.
                expects(:calculate_adjusted_net_income)
                .with(30000.0, 40000.0, 0, 0)
                .returns("Adjusted net income")

              SmartAnswer::AgeRelatedAllowanceChooser.any_instance.
                expects(:get_age_related_allowance).
                with(Date.parse '1930-05-25').
                returns("Age related allowance")
              SmartAnswer::Calculators::MarriedCouplesAllowanceCalculator.any_instance.
                expects(:calculate_allowance).
                with("Age related allowance", 'Adjusted net income').
                returns("Calculated allowance")

              add_response "0"
              assert_state_variable :allowance, "Calculated allowance"
            end
          end
        end # paying into a pension

        context "not paying into a pension" do
          setup do
            add_response "no"
          end

          should "ask how much expected donation to charity through Gift Aid in tax year" do
            assert_current_node :how_much_expected_gift_aided_donations?
          end

          context "donating 100 with gift aid" do
            setup do
              add_response "100.0"
            end

            should "end at husband_done" do
              assert_current_node :husband_done
            end

            should "calculate allowance using calculators" do
              SmartAnswer::Calculators::MarriedCouplesAllowanceCalculator.any_instance.
                expects(:calculate_adjusted_net_income)
                .with(30000.0, 0, 0, 100.0)
                .returns("Adjusted net income")

              SmartAnswer::AgeRelatedAllowanceChooser.any_instance.
                expects(:get_age_related_allowance).
                with(Date.parse '1930-05-25').
                returns("Age related allowance")
              SmartAnswer::Calculators::MarriedCouplesAllowanceCalculator.any_instance.
                expects(:calculate_allowance).
                with("Age related allowance", 'Adjusted net income').
                returns("Calculated allowance")

              assert_state_variable :allowance, "Calculated allowance"
            end
          end # donating 100 with gift aid

          context "donating 0 with gift aid" do
            setup do
              add_response "0.0"
            end

            should "end at husband_done" do
              assert_current_node :husband_done
            end

            should "calculate allowance using calculators" do
              SmartAnswer::Calculators::MarriedCouplesAllowanceCalculator.any_instance.
                expects(:calculate_adjusted_net_income)
                .with(30000.0, 0, 0, 0)
                .returns("Adjusted net income")

              SmartAnswer::AgeRelatedAllowanceChooser.any_instance.
                expects(:get_age_related_allowance).
                with(Date.parse '1930-05-25').
                returns("Age related allowance")
              SmartAnswer::Calculators::MarriedCouplesAllowanceCalculator.any_instance.
                expects(:calculate_allowance).
                with("Age related allowance", 'Adjusted net income').
                returns("Calculated allowance")

              assert_state_variable :allowance, "Calculated allowance"
            end
          end # donating 0 with gift aid
        end # not paying into a pension
      end # income > 25400

      context "income < 25400" do
        setup do
          add_response '1930-05-25'
          add_response '14500.0'
        end

        should "end at husband_done" do
          assert_current_node :husband_done
        end

        should "calculate allowance using calculators" do
          SmartAnswer::AgeRelatedAllowanceChooser.any_instance.
            expects(:get_age_related_allowance).
            with(Date.parse '1930-05-25').
            returns("Age related allowance")
          SmartAnswer::Calculators::MarriedCouplesAllowanceCalculator.any_instance.
            expects(:calculate_allowance).
            with("Age related allowance", 14500.0).
            returns("Calculated allowance")

          assert_state_variable :allowance, "Calculated allowance"
        end
      end # income < 25400
    end # before 2005

    context "married after 2005" do
      setup do
        add_response :no
      end

      should "ask for the highest earner's DOB" do
        assert_current_node :whats_the_highest_earners_date_of_birth?
      end

      should "ask for the highest earner's income" do
        add_response '1930-05-14'
        assert_current_node :whats_the_highest_earners_income?
      end

      context "income > 25400" do
        setup do
          add_response '1930-05-14'
          add_response '30000'
        end

        should "ask if paying into a pension" do
          assert_current_node :paying_into_a_pension?
        end

        context "paying into a pension" do
          setup do
            add_response "yes"
          end

          should "ask amount of contributions before tax is taken away" do
            assert_current_node :how_much_expected_contributions_before_tax?
          end

          context "paying 1000 before tax" do
            setup do
              add_response "1000"
            end

            should "ask amount of contributions where pension provider claims tax relief" do
              assert_current_node :how_much_expected_contributions_with_tax_relief?
            end

            context "paying 500 with tax relief" do
              setup do
                add_response "500"
              end

              should "ask how much expected donation to charity through Gift Aid in tax year" do
                assert_current_node :how_much_expected_gift_aided_donations?
              end

              context "donating 100 with gift aid" do
                setup do
                  add_response "100.0"
                end

                should "end at highest_earner_done" do
                  assert_current_node :highest_earner_done
                end

                should "calculate allowance using calculators" do
                  SmartAnswer::Calculators::MarriedCouplesAllowanceCalculator.any_instance.
                    expects(:calculate_adjusted_net_income)
                    .with(30000.0, 1000.0, 500.0, 100.0)
                    .returns("Adjusted net income")

                  SmartAnswer::AgeRelatedAllowanceChooser.any_instance.
                    expects(:get_age_related_allowance).
                    with(Date.parse '1930-05-14').
                    returns("Age related allowance")
                  SmartAnswer::Calculators::MarriedCouplesAllowanceCalculator.any_instance.
                    expects(:calculate_allowance).
                    with("Age related allowance", 'Adjusted net income').
                    returns("Calculated allowance")

                  assert_state_variable :allowance, "Calculated allowance"
                end
              end # donating 100 with gift aid
            end # paying 500 with tax relief
          end # paying 1000 before tax

          context "paying 0 before tax" do
            setup do
              add_response "0"
            end

            should "ask amount of contributions where pension provider claims tax relief" do
              assert_current_node :how_much_expected_contributions_with_tax_relief?
            end
          end # paying 0 before tax
        end # paying into a pension

        context "not paying into a pension" do
          setup do
            add_response "no"
          end

          should "ask how much expected donation to charity through Gift Aid in tax year" do
            assert_current_node :how_much_expected_gift_aided_donations?
          end

          context "donating 100 with gift aid" do
            setup do
              add_response "100.0"
            end

            should "end at highest_earner_done" do
              assert_current_node :highest_earner_done
            end

            should "calculate allowance using calculators" do
              SmartAnswer::Calculators::MarriedCouplesAllowanceCalculator.any_instance.
                expects(:calculate_adjusted_net_income)
                .with(30000.0, 0, 0, 100.0)
                .returns("Adjusted net income")

              SmartAnswer::AgeRelatedAllowanceChooser.any_instance.
                expects(:get_age_related_allowance).
                with(Date.parse '1930-05-14').
                returns("Age related allowance")
              SmartAnswer::Calculators::MarriedCouplesAllowanceCalculator.any_instance.
                expects(:calculate_allowance).
                with("Age related allowance", 'Adjusted net income').
                returns("Calculated allowance")

              assert_state_variable :allowance, "Calculated allowance"
            end
          end # donating 100 with gift aid

          context "donating 0 with gift aid" do
            setup do
              add_response "0.0"
            end

            should "end at highest_earner_done" do
              assert_current_node :highest_earner_done
            end

            should "calculate allowance using calculators" do
              SmartAnswer::Calculators::MarriedCouplesAllowanceCalculator.any_instance.
                expects(:calculate_adjusted_net_income)
                .with(30000.0, 0, 0, 0)
                .returns("Adjusted net income")

              SmartAnswer::AgeRelatedAllowanceChooser.any_instance.
                expects(:get_age_related_allowance).
                with(Date.parse '1930-05-14').
                returns("Age related allowance")
              SmartAnswer::Calculators::MarriedCouplesAllowanceCalculator.any_instance.
                expects(:calculate_allowance).
                with("Age related allowance", 'Adjusted net income').
                returns("Calculated allowance")

              assert_state_variable :allowance, "Calculated allowance"
            end
          end # donating 0 with gift aid
        end # not paying into a pension
      end # income > 25400

      context "income < 25400" do
        should "end at highest_earner_done" do
          add_response '1930-05-14'
          add_response '13850.50'

          assert_current_node :highest_earner_done
        end

        should "calculate allowance using calculators" do
          SmartAnswer::AgeRelatedAllowanceChooser.any_instance.
            expects(:get_age_related_allowance).
            with(Date.parse '1930-05-14').
            returns("Age related allowance")
          SmartAnswer::Calculators::MarriedCouplesAllowanceCalculator.any_instance.
            expects(:calculate_allowance).
            with("Age related allowance", 13850.5).
            returns("Calculated allowance")

          add_response '1930-05-14'
          add_response '13850.50'
          assert_state_variable :allowance, "Calculated allowance"
        end
      end # income < 25400
    end # after 2005
  end
end
