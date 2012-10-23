# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class ChildBenefitTaxCalculatorTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'child-benefit-tax-calculator'
    @stubbed_calculator = SmartAnswer::Calculators::ChildBenefitTaxCalculator.new
  end

  should "ask what you want to do" do
    assert_current_node :work_out_income?
  end

  context "just wanting to know how much" do
    setup do
      add_response :just_how_much
    end
    
    should "ask which tax year you want an estimate for" do
      assert_current_node :which_tax_year?
    end
    
    context "enter 2013-14" do
      setup do
        add_response "2013-14"
      end

      should "ask how many children" do
        assert_current_node :how_many_children_claiming_for?
      end

      context "3 children" do
        setup do
          add_response "3"
        end

        should "ask how many children" do
          assert_current_node :do_you_expect_to_start_or_stop_claiming?
        end

        context "no" do
          setup do
            add_response :no
          end

          should "give estimated_tax_charge" do
            assert_current_node :estimated_tax_charge
            assert_state_variable :benefit_taxable_amount, "2449.20"
            assert_state_variable :benefit_claimed_amount, "2449.20"
            assert_state_variable :percentage_tax_charge, 100.0
            assert_state_variable :benefit_tax, "2449"
          end
        end
      end
    end

    context "enter 2012-13" do
      setup do
        add_response "2012-13"
        add_response "3"
        add_response :no
      end

      should "give estimated_tax_charge" do
        assert_current_node :estimated_tax_charge
        assert_state_variable :benefit_taxable_amount, "612.30"
        assert_state_variable :benefit_claimed_amount, "2449.20"
        assert_state_variable :percentage_tax_charge, 100.0
        assert_state_variable :benefit_tax, "612"
      end
    end
  end # just_how_much

  context "looking to work out income" do
    setup do
      add_response :income_work_out
    end

    should "ask which tax year you want an estimate for" do
      assert_current_node :which_tax_year?
    end

    context "for the 2012-13 tax year" do
      setup do
        add_response "2012-13"
      end

      should "ask what your estimated income for the year before tax is taken off" do
        assert_current_node :what_is_your_estimated_income_for_the_year_before_tax?
      end

      should "not be require to pay tax if income less than/equal £50k pa" do
        add_response "30000"
        assert_current_node :dont_need_to_pay
        assert_state_variable :total_income, 30000
      end

      should "not be require to pay tax if income less than/equal £50099 pa" do
        add_response "50040"
        assert_current_node :dont_need_to_pay
        assert_state_variable :total_income, 50040
      end

      context "income greater than £50,099" do
        setup do
          add_response "52460"
        end

        should "store your income" do
          assert_state_variable :total_income, 52460
        end

        should "ask if you expect to pay into a workplace or personal pension this tax year" do
          assert_current_node :do_you_expect_to_pay_into_a_pension_this_year?
        end


        context "paying into a pension this year" do
          setup do
            add_response :yes
          end

          should "ask for your gross pension contributions" do
            assert_current_node :how_much_pension_contributions_before_tax?
          end

          should "reject non-numeric values" do
            add_response "foobar"
            assert_current_node :how_much_pension_contributions_before_tax?
            assert_current_node_is_error
          end

          context "valid values" do
            setup do
              add_response "100.23"
            end

            should "store your gross pension contributions" do
              assert_state_variable :gross_pension_contributions, 100.23
            end

            should "ask for your net pension contributions" do
              assert_current_node :how_much_pension_contributions_claimed_back_by_provider?
            end

            should "reject non-numeric values" do
              add_response "foobar"
              assert_current_node :how_much_pension_contributions_claimed_back_by_provider?
              assert_current_node_is_error
            end

            should "store your net pension contributions" do
              add_response "2000.50"
              assert_state_variable :net_pension_contributions, 2000.50
            end

            should "ask for your net savings interest" do
              add_response "2012.50"
              assert_current_node :how_much_interest_from_savings_and_investments?
            end
          end
        end

        context "not paying into a pension this year" do
          setup do
            add_response :no
          end

          should "store your gross and net pension contributions as zero" do
            assert_state_variable :gross_pension_contributions, 0
            assert_state_variable :net_pension_contributions, 0
          end

          should "ask for your net savings interest" do
            assert_current_node :how_much_interest_from_savings_and_investments?
          end

          should "reject non-numeric values" do
            add_response "foobar"
            assert_current_node :how_much_interest_from_savings_and_investments?
            assert_current_node_is_error
          end

          context "valid net savings interest" do
            setup do
              add_response "1800"
            end

            should "store your net savings interest" do
              assert_state_variable :trading_losses, 1800
            end

            should "ask how much you expect to give to charity this year" do
              assert_current_node :how_much_do_you_expect_to_give_to_charity_this_year?
            end

            context "adjusted net income < 50000" do
              setup do
                add_response "25000"
              end

              should "calculate adjusted net income" do
                assert_state_variable :adjusted_net_income, 19410 
              end

              should "not require to pay tax when adjusted net income less than £50,000" do
                assert_current_node :dont_need_to_pay
              end
            end

            context "adjusted net income >= 50000" do
              setup do
                add_response "40"
              end

              should "calculate adjusted net income" do
                assert_state_variable :adjusted_net_income, 50610
              end

              should "ask how many children you are getting child benefit for" do
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

              context "values = 0" do
                setup do
                  add_response "0"
                end

                should "ask if you expect to start or stop claiming during this tax year" do
                  assert_current_node :do_you_expect_to_start_or_stop_claiming?
                end

                should "reject 0 children when not starting or stopping this tax year" do
                  add_response :no

                  assert_current_node :do_you_expect_to_start_or_stop_claiming?
                  assert_current_node_is_error
                end

                should "reject 0 children with 0 children starting this year" do
                  add_response :yes
                  add_response "0"

                  assert_current_node :how_many_children_to_start_claiming?
                  assert_current_node_is_error
                end
              end

              context "values >= 1" do
                setup do
                  add_response "1"
                end

                should "store the number of children you're claiming child benefit for" do
                  assert_state_variable :number_of_children, 1
                end

                should "ask if you expect to start or stop claiming during this tax year" do
                  assert_current_node :do_you_expect_to_start_or_stop_claiming?
                end

                context "not starting or stopping this tax year" do
                  setup do
                    add_response :no
                  end

                  should "tell you your estimated tax charge" do
                    SmartAnswer::Calculators::ChildBenefitTaxCalculator.
                      expects(:new).with(
                        :start_of_tax_year => Date.new(2012, 4, 6),
                        :end_of_tax_year => Date.new(2013, 4, 5),
                        :children_claiming => 1,
                        :claim_periods => [Date.new(2012,4,6)..Date.new(2013,4,5)],
                        :income => 50610.0
                      ).returns(@stubbed_calculator)
                    @stubbed_calculator.expects(:formatted_benefit_tax).returns("formatted benefit tax")
                    @stubbed_calculator.expects(:formatted_benefit_taxable_amount).returns("formatted benefit taxable amount")
                    @stubbed_calculator.expects(:formatted_benefit_claimed_amount).returns("formatted benefit claimed amount")
                    @stubbed_calculator.expects(:benefit_taxable_weeks).returns("benefit taxable weeks")
                    @stubbed_calculator.expects(:percent_tax_charge).returns("percent tax charge")

                    assert_current_node :estimated_tax_charge
                    assert_state_variable :benefit_taxable_amount, "formatted benefit taxable amount"
                    assert_state_variable :benefit_claimed_amount, "formatted benefit claimed amount"
                    assert_state_variable :percentage_tax_charge, "percent tax charge"
                    assert_state_variable :benefit_taxable_weeks, "benefit taxable weeks"
                    assert_state_variable :benefit_tax, "formatted benefit tax"
                  end
                end # context - not starting or stopping this tax year

                context "starting or stopping this tax year" do
                  setup do
                    add_response :yes
                  end

                  should "ask how many children you expect to start claiming for" do
                    assert_current_node :how_many_children_to_start_claiming?
                  end

                  should "reject non-numeric values" do
                    add_response "foobarbaz"
                    assert_current_node :how_many_children_to_start_claiming?
                    assert_current_node_is_error
                  end

                  should "reject < 0" do
                    add_response "-1"
                    assert_current_node :how_many_children_to_start_claiming?
                    assert_current_node_is_error
                  end

                  should "reject > 3" do
                    add_response "4"
                    assert_current_node :how_many_children_to_start_claiming?
                    assert_current_node_is_error
                  end

                  context "2 children starting" do
                    setup do
                      add_response "2"
                    end

                    should "ask the starting date of the first child" do
                      assert_current_node :when_will_the_1st_child_enter_the_household?
                    end

                    should "reject a date outside of the current tax year" do
                      add_response "2013-11-05" do
                        assert_current_node :when_do_you_expect_to_stop_claiming_for_the_1st_child?
                        assert_current_node_is_error
                      end
                    end

                    context "valid first child date" do
                      setup do
                        add_response "2012-12-22"
                      end

                      should "ask the starting date of the second child, given the first child start date" do
                        assert_current_node :when_will_the_2nd_child_enter_the_household?
                      end

                      context "valid second child date" do
                        setup do
                          add_response "2013-02-14"
                        end

                        should "ask how many children you expect to stop claiming for" do
                          assert_current_node :how_many_children_to_stop_claiming?
                        end

                        should "reject > number of children" do
                          add_response "6"
                          assert_current_node :how_many_children_to_stop_claiming?
                          assert_current_node_is_error
                        end

                        context "no children stopping" do
                          setup do
                            add_response "0"
                          end

                          should "tell you your estimated tax charge" do
                            SmartAnswer::Calculators::ChildBenefitTaxCalculator.
                              expects(:new).with(
                                :start_of_tax_year => Date.new(2012, 4, 6),
                                :end_of_tax_year => Date.new(2013, 4, 5),
                                :children_claiming => 1,
                                :claim_periods => [Date.new(2012,12,22)..Date.new(2013,4,5), Date.new(2013,2,14)..Date.new(2013,4,5), Date.new(2012,4,6)..Date.new(2013,4,5)],
                                :income => 50610.0
                              ).returns(@stubbed_calculator)
                            @stubbed_calculator.expects(:formatted_benefit_tax).returns("formatted benefit tax")
                            @stubbed_calculator.expects(:formatted_benefit_taxable_amount).returns("formatted benefit taxable amount")
                            @stubbed_calculator.expects(:formatted_benefit_claimed_amount).returns("formatted benefit claimed amount")
                            @stubbed_calculator.expects(:benefit_taxable_weeks).returns("benefit taxable weeks")
                            @stubbed_calculator.expects(:percent_tax_charge).returns("percent tax charge")

                            assert_current_node :estimated_tax_charge
                            assert_state_variable :benefit_taxable_amount, "formatted benefit taxable amount"
                            assert_state_variable :benefit_claimed_amount, "formatted benefit claimed amount"
                            assert_state_variable :percentage_tax_charge, "percent tax charge"
                            assert_state_variable :benefit_taxable_weeks, "benefit taxable weeks"
                            assert_state_variable :benefit_tax, "formatted benefit tax"
                          end
                        end # context - no children stopping

                        context "1 child stopping" do
                          setup do
                            add_response "1"
                          end

                          should "ask the stopping date of the first child" do
                            assert_current_node :when_do_you_expect_to_stop_claiming_for_the_1st_child?
                          end

                          should "reject a date outside of the current tax year" do
                            add_response "2014-01-10" do
                              assert_current_node :when_do_you_expect_to_stop_claiming_for_the_1st_child?
                              assert_current_node_is_error
                            end
                          end

                          context "valid first child date" do
                            setup do
                              add_response "2013-01-15"
                            end

                            should "tell you your estimated tax charge" do
                              SmartAnswer::Calculators::ChildBenefitTaxCalculator.
                                expects(:new).with(
                                  :start_of_tax_year => Date.new(2012, 4, 6),
                                  :end_of_tax_year => Date.new(2013, 4, 5),
                                  :children_claiming => 1,
                                  :claim_periods => [Date.new(2012,12,22)..Date.new(2013,4,5), Date.new(2013,2,14)..Date.new(2013,4,5), Date.new(2012,4,6)..Date.new(2013,1,15)],
                                  :income => 50610.0
                                ).returns(@stubbed_calculator)
                              @stubbed_calculator.expects(:formatted_benefit_tax).returns("formatted benefit tax")
                              @stubbed_calculator.expects(:formatted_benefit_taxable_amount).returns("formatted benefit taxable amount")
                              @stubbed_calculator.expects(:formatted_benefit_claimed_amount).returns("formatted benefit claimed amount")
                              @stubbed_calculator.expects(:benefit_taxable_weeks).returns("benefit taxable weeks")
                              @stubbed_calculator.expects(:percent_tax_charge).returns("percent tax charge")

                              assert_current_node :estimated_tax_charge
                              assert_state_variable :benefit_taxable_amount, "formatted benefit taxable amount"
                              assert_state_variable :benefit_claimed_amount, "formatted benefit claimed amount"
                              assert_state_variable :percentage_tax_charge, "percent tax charge"
                              assert_state_variable :benefit_taxable_weeks, "benefit taxable weeks"
                              assert_state_variable :benefit_tax, "formatted benefit tax"
                            end
                          end # context - valid first child date
                        end # context - 1 child stopping
                      end # context - valid second child date
                    end # context - valid first child date
                  end # context - 2 children starting
                end # context - starting or stopping this tax year
              end # context - values >= 1
            end # context - adjusted net income >= 50000
          end # context - valid net savings interest
        end # context - not paying into pension this year
      end # context - income rounded to £100 greater than £50,000
    end # context - 2012-13 tax year 
  end
  context "additional calculation tests" do
    setup do
      add_response :income_work_out
      add_response "2012-13"
    end
    should "ask what is your income" do
      assert_current_node :what_is_your_estimated_income_for_the_year_before_tax?
    end

    context "adjusted income tests" do
      context "income at 60k" do
        setup do
          add_response "60000"
          add_response :yes    
        end

        should "ask about pension" do
          assert_current_node :how_much_pension_contributions_before_tax?
        end

        context "test 01" do
          setup do
            add_response "5000"    # Q3A Gross Pension
            add_response "1600"    # Q4 net pension 
            add_response "1000"    # Q5 trading losses 
          end

          should "ask about charity donations" do
            assert_current_node :how_much_do_you_expect_to_give_to_charity_this_year?
            assert_state_variable :total_income, 60000
            assert_state_variable :gross_pension_contributions, 5000
            assert_state_variable :net_pension_contributions, 1600
            assert_state_variable :trading_losses, 1000
            assert_state_variable :total_deductions, 8000
            assert_state_variable :adjusted_net_income, 52000 
          end

          should "ask about children claiming for" do 
            add_response "800"
            assert_current_node :how_many_children_claiming_for?
            assert_state_variable :adjusted_net_income, 51000
          end
        end

        context "test 02" do
          setup do
            add_response "5000"    # Q3A Gross Pension
            add_response "0"    # Q4 net pension 
            add_response "0"    # Q5 trading losses 
            add_response "0"		# Q6 Gift Aided 
          end

          should "ask about children claiming for" do 
            assert_current_node :how_many_children_claiming_for?
            assert_state_variable :total_deductions, 5000
            assert_state_variable :adjusted_net_income, 55000 
          end
        end

        context "test 03" do
          setup do
            add_response "0"    # Q3A Gross Pension
            add_response "1600"    # Q4 net pension 
            add_response "0"    # Q5 trading losses 
            add_response "0"		# Q6 Gift Aided 
          end

          should "ask about children claiming for" do 
            assert_current_node :how_many_children_claiming_for?
            assert_state_variable :total_deductions, 2000
            assert_state_variable :adjusted_net_income, 58000 
          end
        end
        
        context "test 04" do
          setup do
            add_response "0"    # Q3A Gross Pension
            add_response "0"    # Q4 net pension 
            add_response "3000"    # Q5 trading losses 
            add_response "0"		# Q6 Gift Aided 
          end

          should "ask about children claiming for" do 
            assert_current_node :how_many_children_claiming_for?
            assert_state_variable :total_deductions, 3000
            assert_state_variable :adjusted_net_income, 57000 
          end
        end

        context "test 05" do
          setup do
            add_response "0"    # Q3A Gross Pension
            add_response "0"    # Q4 net pension 
            add_response "0"    # Q5 trading losses 
            add_response "1600"		# Q6 Gift Aided 
          end

          should "ask about children claiming for" do 
            assert_current_node :how_many_children_claiming_for?
            assert_state_variable :total_deductions, 0
            assert_state_variable :adjusted_net_income, 58000 
          end
        end
      end
    end
  end
end
