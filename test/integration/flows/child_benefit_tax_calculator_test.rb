# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class ChildBenefitTaxCalculatorTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'child-benefit-tax-calculator'
    @stubbed_calculator = SmartAnswer::Calculators::ChildBenefitTaxCalculator.new
  end

  should "ask what your estimated income for the year" do
    assert_current_node :what_is_your_estimated_income_for_the_year?
  end

  should "not be require to pay tax if income less than/equal £50k pa" do
    add_response "30000"
    assert_current_node :dont_need_to_pay
    assert_state_variable :income, 30000
  end

  should "not be require to pay tax if income rounded to nearest £100 less than/equal £50k pa" do
    add_response "50040"
    assert_current_node :dont_need_to_pay
    assert_state_variable :income, 50000
  end

  context "income rounded to £100 greater than £50,000" do
    setup do
      add_response "50060"
    end

    should "store your income" do
      assert_state_variable :income, 50100
    end

    should "ask how many children you're claiming child benefit for" do
      assert_current_node :how_many_children_claiming_for?
    end

    should "reject non-numeric values" do
      add_response "foobarbaz"
      assert_current_node :how_many_children_claiming_for?
      assert_current_node_is_error
    end

    should "reject non-integer values" do
      add_response "4.3"
      assert_current_node :how_many_children_claiming_for?
      assert_current_node_is_error
    end

    should "reject values <1" do
      add_response "0"
      assert_current_node :how_many_children_claiming_for?
      assert_current_node_is_error
    end

    context "values >=1" do
      setup do
        add_response "1"
      end

      should "store the number of children you're claiming child benefit for" do
        assert_state_variable :children_claiming, 1
      end
      
      should "ask when you started claiming child benefit" do
        assert_current_node :when_did_you_start_claiming?
      end

      context "on or before 6 April 2012" do
        setup do
          add_response "on_or_before"
        end

        should "store 6 April 2012 as the child benefit start date" do
          assert_state_variable :child_benefit_start_date, Date.new(2012, 4, 6)
        end

        should "ask if you plan to stop claiming child benefit before 5 April 2013" do
          assert_current_node :do_you_expect_to_stop_claiming_by_5_april_2013?
        end

        context "don't plan to stop claiming by 5 April 2013" do
          setup do
            add_response "no"
          end

          should "tell you your estimated child benefit tax charge" do
            SmartAnswer::Calculators::ChildBenefitTaxCalculator.
              expects(:new).
              with(
                :child_benefit_start_date => Date.new(2012, 4, 6),
                :child_benefit_end_date => Date.new(2013, 4, 5),
                :children_claiming => 1,
                :income => 50100
              ).returns(@stubbed_calculator)
            @stubbed_calculator.expects(:formatted_benefit_tax).returns("formatted benefit tax")
            @stubbed_calculator.expects(:formatted_benefit_taxable_amount).returns("formatted benefit taxable amount")
            @stubbed_calculator.expects(:benefit_taxable_weeks).returns("benefit taxable weeks")
            @stubbed_calculator.expects(:percent_tax_charge).returns("percent tax charge")
            @stubbed_calculator.expects(:formatted_benefit_claimed_amount).returns("formatted benefit claimed amount")
            @stubbed_calculator.expects(:benefit_claimed_weeks).returns("benefit claimed weeks")

            assert_current_node :estimated_tax_charge

            assert_state_variable :formatted_benefit_tax, "formatted benefit tax"
            assert_state_variable :formatted_benefit_taxable_amount, "formatted benefit taxable amount"
            assert_state_variable :benefit_taxable_weeks, "benefit taxable weeks"
            assert_state_variable :percent_tax_charge, "percent tax charge"
            assert_state_variable :formatted_benefit_claimed_amount, "formatted benefit claimed amount"
            assert_state_variable :benefit_claimed_weeks, "benefit claimed weeks"
            assert_state_variable :child_benefit_start_date, Date.new(2012, 4, 6)
            assert_state_variable :child_benefit_end_date, Date.new(2013, 4, 5)
          end
        end # context - don't plan to stop claiming by 5 April 2013

        context "plan to stop claiming by 5 April 2013" do
          setup do
            add_response "yes"
          end

          should "ask you when you plan to stop claiming child benefit" do
            assert_current_node :when_do_you_expect_to_stop_claiming?
          end

          should "be invalid if the date is after 5 April 2013" do
            add_response "2013-04-06"
            assert_current_node_is_error
            assert_current_node :when_do_you_expect_to_stop_claiming?
          end

          should "be invalid if the date is before the child benefit start date" do
            add_response "2012-04-05"
            assert_current_node_is_error
            assert_current_node :when_do_you_expect_to_stop_claiming?
          end

          context "date > start date and < 5 April 2013" do
            setup do
              add_response "2012-08-08"
            end

            should "store input as child_benefit_end_date" do
              assert_state_variable :child_benefit_end_date,  Date.new(2012, 8, 8)
            end

            should "tell you your estimated child benefit tax charge" do
              SmartAnswer::Calculators::ChildBenefitTaxCalculator.
                expects(:new).
                with(
                  :child_benefit_start_date => Date.new(2012, 4, 6),
                  :child_benefit_end_date => Date.new(2012, 8, 8),
                  :children_claiming => 1,
                  :income => 50100
                ).returns(@stubbed_calculator)
              @stubbed_calculator.expects(:formatted_benefit_tax).returns("formatted benefit tax")
              @stubbed_calculator.expects(:formatted_benefit_taxable_amount).returns("formatted benefit taxable amount")
              @stubbed_calculator.expects(:benefit_taxable_weeks).returns("benefit taxable weeks")
              @stubbed_calculator.expects(:percent_tax_charge).returns("percent tax charge")
              @stubbed_calculator.expects(:formatted_benefit_claimed_amount).returns("formatted benefit claimed amount")
              @stubbed_calculator.expects(:benefit_claimed_weeks).returns("benefit claimed weeks")

              assert_current_node :estimated_tax_charge

              assert_state_variable :formatted_benefit_tax, "formatted benefit tax"
              assert_state_variable :formatted_benefit_taxable_amount, "formatted benefit taxable amount"
              assert_state_variable :benefit_taxable_weeks, "benefit taxable weeks"
              assert_state_variable :percent_tax_charge, "percent tax charge"
              assert_state_variable :formatted_benefit_claimed_amount, "formatted benefit claimed amount"
              assert_state_variable :benefit_claimed_weeks, "benefit claimed weeks"
              assert_state_variable :child_benefit_start_date, Date.new(2012, 4, 6)
              assert_state_variable :child_benefit_end_date, Date.new(2012, 8, 8)
            end
          end # context - date > start date and < 5 April 2013
        end # context - plan to stop claiming by 5 April 2013
      end # context - on or before 6 April 2012

      context "after 6 April 2012" do
        setup do
          add_response "after"
        end

        should "ask what date you started claiming child benefit" do
          assert_current_node :what_date_did_you_start_claiming?
        end

        should "be invalid if started before 6 April 2012" do
          add_response "2012-01-01"
          assert_current_node_is_error
          assert_current_node :what_date_did_you_start_claiming?
        end

        should "be invalid if started on 6 April 2012" do
          add_response "2012-04-06"
          assert_current_node_is_error
          assert_current_node :what_date_did_you_start_claiming?
        end

        context "after 6 April 2012" do
          setup do
            add_response "2012-08-08"
          end

          should "store input as child_benefit_start_date" do
            assert_state_variable :child_benefit_start_date, Date.new(2012, 8, 8)
          end

          should "ask if you plan to stop claiming child benefit before 5 April 2013" do
            assert_current_node :do_you_expect_to_stop_claiming_by_5_april_2013?
          end
  
          context "don't plan to stop claiming by 5 April 2013" do
            setup do
              add_response "no"
            end
  
            should "tell you your estimated child benefit tax charge" do
              SmartAnswer::Calculators::ChildBenefitTaxCalculator.
                expects(:new).
                with(
                  :child_benefit_start_date => Date.new(2012, 8, 8),
                  :child_benefit_end_date => Date.new(2013, 4, 5),
                  :children_claiming => 1,
                  :income => 50100
                ).returns(@stubbed_calculator)
              @stubbed_calculator.expects(:formatted_benefit_tax).returns("formatted benefit tax")
              @stubbed_calculator.expects(:formatted_benefit_taxable_amount).returns("formatted benefit taxable amount")
              @stubbed_calculator.expects(:benefit_taxable_weeks).returns("benefit taxable weeks")
              @stubbed_calculator.expects(:percent_tax_charge).returns("percent tax charge")
              @stubbed_calculator.expects(:formatted_benefit_claimed_amount).returns("formatted benefit claimed amount")
              @stubbed_calculator.expects(:benefit_claimed_weeks).returns("benefit claimed weeks")

              assert_current_node :estimated_tax_charge

              assert_state_variable :formatted_benefit_tax, "formatted benefit tax"
              assert_state_variable :formatted_benefit_taxable_amount, "formatted benefit taxable amount"
              assert_state_variable :benefit_taxable_weeks, "benefit taxable weeks"
              assert_state_variable :percent_tax_charge, "percent tax charge"
              assert_state_variable :formatted_benefit_claimed_amount, "formatted benefit claimed amount"
              assert_state_variable :benefit_claimed_weeks, "benefit claimed weeks"
              assert_state_variable :child_benefit_start_date, Date.new(2012, 8, 8)
              assert_state_variable :child_benefit_end_date, Date.new(2013, 4, 5)
            end
          end # context - don't plan to stop claiming by 5 April 2013
  
          context "plan to stop claiming by 5 April 2013" do
            setup do
              add_response "yes"
            end
  
            should "ask you when you plan to stop claiming child benefit" do
              assert_current_node :when_do_you_expect_to_stop_claiming?
            end

            should "be invalid if the date is after 5 April 2013" do
              add_response "2013-04-06"
              assert_current_node_is_error
              assert_current_node :when_do_you_expect_to_stop_claiming?
            end

            should "be invalid if the date is before the child benefit start date" do
              add_response "2012-08-07"
              assert_current_node_is_error
              assert_current_node :when_do_you_expect_to_stop_claiming?
            end

            context "date > start date and < 5 April 2013" do
              setup do
                add_response "2012-09-09"
              end
  
              should "store input as child_benefit_end_date" do
                assert_state_variable :child_benefit_end_date,  Date.new(2012, 9, 9)
              end
  
              should "tell you your estimated child benefit tax charge" do
                SmartAnswer::Calculators::ChildBenefitTaxCalculator.
                  expects(:new).
                  with(
                    :child_benefit_start_date => Date.new(2012, 8, 8),
                    :child_benefit_end_date => Date.new(2012, 9, 9),
                    :children_claiming => 1,
                    :income => 50100
                  ).returns(@stubbed_calculator)
                @stubbed_calculator.expects(:formatted_benefit_tax).returns("formatted benefit tax")
                @stubbed_calculator.expects(:formatted_benefit_taxable_amount).returns("formatted benefit taxable amount")
                @stubbed_calculator.expects(:benefit_taxable_weeks).returns("benefit taxable weeks")
                @stubbed_calculator.expects(:percent_tax_charge).returns("percent tax charge")
                @stubbed_calculator.expects(:formatted_benefit_claimed_amount).returns("formatted benefit claimed amount")
                @stubbed_calculator.expects(:benefit_claimed_weeks).returns("benefit claimed weeks")

                assert_current_node :estimated_tax_charge

                assert_state_variable :formatted_benefit_tax, "formatted benefit tax"
                assert_state_variable :formatted_benefit_taxable_amount, "formatted benefit taxable amount"
                assert_state_variable :benefit_taxable_weeks, "benefit taxable weeks"
                assert_state_variable :percent_tax_charge, "percent tax charge"
                assert_state_variable :formatted_benefit_claimed_amount, "formatted benefit claimed amount"
                assert_state_variable :benefit_claimed_weeks, "benefit claimed weeks"
                assert_state_variable :child_benefit_start_date, Date.new(2012, 8, 8)
                assert_state_variable :child_benefit_end_date, Date.new(2012, 9, 9)
              end
            end # context - date > start date and < 5 April 2013
          end # context - plan to stop claiming by 5 April 2013
        end # context - after 6 April 2012 (user entered date)
      end # context - after 6 April 2012
    end # context - no. children > 1
  end # context - income > 50,000
end
