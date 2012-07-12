# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class ChildBenefitTaxCalculatorTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'child-benefit-tax-calculator'
  end

  should "ask what your estimated income for the year" do
    assert_current_node :what_is_your_estimated_income_for_the_year?
  end

  context "income less than/equal to £50,000" do
    setup do
      add_response "30000"
    end

    should "store your income" do
      assert_state_variable :income, 30000
    end

    should "say you don't need to pay income tax on child benefit" do
      assert_current_node :dont_need_to_pay
    end
  end

  context "income rounded to £100 less than/equal to £50,000" do
    setup do
      add_response "50040"
    end

    should "store your income" do
      assert_state_variable :income, 50000
    end
    
    should "say you don't need to pay income tax on child benefit" do
      assert_current_node :dont_need_to_pay
      assert_state_variable :income, 50000
    end
  end

  context "income rounded to £100 greater than £50,000" do
    setup do
      add_response "70000"
    end

    should "store your income" do
      assert_state_variable :income, 70000
    end

    should "ask how many children you're claiming child benefit for" do
      assert_current_node :how_many_children_claiming_for?
    end

    context "non-numeric values" do
      setup do
        add_response "foobarbaz"
      end

      should "reject non-numeric values" do
        assert_current_node :how_many_children_claiming_for?
      end
    end

    context "non-integral values" do
      setup do
        add_response "4.3"
      end

      should "reject non-integral values" do
        assert_current_node :how_many_children_claiming_for?
      end
    end

    context "values =1" do
      setup do
        add_response "1"
      end

      should "reject values of 1" do
        assert_current_node :how_many_children_claiming_for?
      end
    end

    context "values <1" do
      setup do
        add_response "-1"
      end

      should "reject values <1" do
        assert_current_node :how_many_children_claiming_for?
      end
    end

    context "values >1" do
      setup do
        add_response "2"
      end

      should "store the number of children you're claiming child benefit for" do
        assert_state_variable :children_claiming, 2
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

          should "store 5 April 2013 as the child benefit end date" do
            assert_state_variable :child_benefit_end_date, Date.new(2013, 4, 5)
          end

          should "tell you your estimated child benefit tax charge" do
            assert_current_node :estimated_tax_charge

            # TODO Check vars are right
          end
        end # context - don't plan to stop claiming by 5 April 2013

        context "plan to stop claiming by 5 April 2013" do
          setup do
            add_response "yes"
          end

          should "ask you when you plan to stop claiming child benefit" do
            assert_current_node :when_do_you_expect_to_stop_claiming?
          end

          context "date = 5 April 2013" do
            setup do
              add_response "2013-04-05"
            end

            should "store input as child_benefit_end_date" do
              assert_state_variable :child_benefit_end_date, Date.new(2013, 4, 5)
            end

            should "tell you your estimated child benefit tax charge" do
              assert_current_node :estimated_tax_charge

              # TODO check vars are right
            end          
          end # context - stop claiming date = 5 April 2013

          context "date > 5 April 2013" do
            setup do
              add_response "2013-08-08"
            end

            should "reject your child benefit end date" do
              assert_current_node :when_do_you_expect_to_stop_claiming?
            end
          end # context - stop claiming date > 5 April 2013

          context "date = child benefit start date" do
            setup do
              add_response "2012-04-06"
            end

            should "store input as child_benefit_end_date" do
              assert_state_variable :child_benefit_end_date,  Date.new(2012, 4, 6)
            end

            should "tell you your estimated child benefit tax charge" do
              assert_current_node :estimated_tax_charge

              # TODO check vars are right
            end
          end # context - date = child benefit start date

          context "date > start date and < 5 April 2013" do
            setup do
              add_response "2012-08-08"
            end

            should "store input as child_benefit_end_date" do
              assert_state_variable :child_benefit_end_date,  Date.new(2012, 8, 8)
            end

            should "tell you your estimated child benefit tax charge" do
              assert_current_node :estimated_tax_charge

              # TODO check vars are right
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

        context "before 6 April 2012" do
          setup do
            add_response "2012-01-01"
          end

          should "reject the input" do
            assert_current_node :what_date_did_you_start_claiming?
          end
        end # context - before 6 April 2012 (yes, contradiction)

        context "on 6 April 2012" do
          setup do
            add_response "2012-04-06"
          end

          should "reject the input" do
            assert_current_node :what_date_did_you_start_claiming?
          end
        end # context - on 6 April 2012 (yes, contradiction)

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
  
            should "store 5 April 2013 as the child benefit end date" do
              assert_state_variable :child_benefit_end_date, Date.new(2013, 4, 5)
            end
  
            should "tell you your estimated child benefit tax charge" do
              assert_current_node :estimated_tax_charge
  
              # TODO Check vars are right
            end
          end # context - don't plan to stop claiming by 5 April 2013
  
          context "plan to stop claiming by 5 April 2013" do
            setup do
              add_response "yes"
            end
  
            should "ask you when you plan to stop claiming child benefit" do
              assert_current_node :when_do_you_expect_to_stop_claiming?
            end
  
            context "date = 5 April 2013" do
              setup do
                add_response "2013-04-05"
              end
  
              should "store input as child_benefit_end_date" do
                assert_state_variable :child_benefit_end_date, Date.new(2013, 4, 5)
              end
  
              should "tell you your estimated child benefit tax charge" do
                assert_current_node :estimated_tax_charge
  
                # TODO check vars are right
              end          
            end # context - stop claiming date = 5 April 2013
  
            context "date > 5 April 2013" do
              setup do
                add_response "2013-08-08"
              end
  
              should "reject your child benefit end date" do
                assert_current_node :when_do_you_expect_to_stop_claiming?
              end
            end # context - stop claiming date > 5 April 2013
  
            context "date = child benefit start date" do
              setup do
                add_response "2012-08-08"
              end
  
              should "store input as child_benefit_end_date" do
                assert_state_variable :child_benefit_end_date,  Date.new(2012, 8, 8)
              end
  
              should "tell you your estimated child benefit tax charge" do
                assert_current_node :estimated_tax_charge
  
                # TODO check vars are right
              end
            end # context - date = child benefit start date
  
            context "date > start date and < 5 April 2013" do
              setup do
                add_response "2012-09-09"
              end
  
              should "store input as child_benefit_end_date" do
                assert_state_variable :child_benefit_end_date,  Date.new(2012, 9, 9)
              end
  
              should "tell you your estimated child benefit tax charge" do
                assert_current_node :estimated_tax_charge
  
                # TODO check vars are right
              end
            end # context - date > start date and < 5 April 2013
          end # context - plan to stop claiming by 5 April 2013
        end # context - after 6 April 2012 (user entered date)
      end # context - after 6 April 2012
    end # context - no. children > 1
  end # context - income > 50,000
end
