require_relative '../../test_helper'
require_relative 'flow_test_helper'

require "smart_answer_flows/calculate-your-redundancy-pay"

class CalculateYourRedundancyPayTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::CalculateYourRedundancyPayFlow
  end

  should "ask when you were made redundant" do
    assert_current_node :date_of_redundancy?
  end

  context "answer before 1 Feb 2013" do
    setup do
      add_response '2013-01-31'
    end

    should "be in employee flow for age" do
      assert_current_node :age_of_employee?
      assert_state_variable :rate, 430
      assert_state_variable :ni_rate, 430
    end

    context "42 years old" do
      setup do
        add_response "42"
      end

      should "ask how long the employee has been employed" do
        assert_current_node :years_employed?
      end

      context "under 2 years" do
        setup do
          add_response "1.8"
        end

        should "bypass the salary question" do
          assert_current_node :done_no_statutory
        end
      end

      context "over 2 years" do
        setup do
          add_response "4.5"
        end

        should "ask for salary" do
          assert_current_node :weekly_pay_before_tax?
        end

        context "weekly salary of over 430 before tax" do
          setup do
            add_response "1500"
          end

          should "give me statutory redundancy" do
            assert_current_node :done
          end

          should "give me a figure no higher than 430 per week" do
            assert_state_variable :statutory_redundancy_pay, "1,935"
            assert_state_variable :statutory_redundancy_pay_ni, "1,935"
          end

          should "give me 2 weeks total entitlement" do
            assert_state_variable :number_of_weeks_entitlement, 4.5
          end
        end
      end
    end

    context "between 22 and 41" do
      setup do
        add_response "22-40"
      end

      should "ask how long the employee has been employed" do
        assert_current_node :years_employed?
      end

      context "under 2 years" do
        setup do
          add_response "1"
        end

        should "bypass the salary question" do
          assert_current_node :done_no_statutory
        end
      end

      context "over 2 years" do
        setup do
          add_response "4"
        end

        should "ask for salary" do
          assert_current_node :weekly_pay_before_tax?
        end

        context "weekly salary of over 430 before tax" do
          setup do
            add_response "1500"
          end

          should "give me statutory redundancy" do
            assert_current_node :done
          end

          should "give me a figure no higher than 430 per week" do
            assert_state_variable :statutory_redundancy_pay, "860"
            assert_state_variable :statutory_redundancy_pay_ni, "860"
          end
        end

        context "weekly salary of under 430 before tax" do
          setup do
            add_response "300"
          end

          should "give me a figure below 430" do
            assert_state_variable :statutory_redundancy_pay, "600"
            assert_state_variable :statutory_redundancy_pay_ni, "600"
          end
        end
      end
    end

    context "catches years_employed greater than age_of_employee" do
      context "be 18 years old and worked 20" do
        setup do
          add_response 18
        end
        should "fail on 4 years" do
          add_response 4
          assert_current_node_is_error
        end
        should "fail on 20 years" do
          add_response 20
          assert_current_node_is_error
        end
        should "succeed on 3" do
          add_response 3
          assert_current_node :weekly_pay_before_tax?
        end
        should "succeed on 2" do
          add_response 2
          assert_current_node :weekly_pay_before_tax?
        end
      end
    end

    context "21 years of age" do
      setup do
        add_response "21"
      end

      should "ask how long the employee has been employed" do
        assert_current_node :years_employed?
      end

      context "under 2 years" do
        setup do
          add_response "1"
        end

        should "bypass the salary question" do
          assert_current_node :done_no_statutory
        end
      end

      context "over 2 years" do
        setup do
          add_response "6"
        end

        should "ask for salary" do
          assert_current_node :weekly_pay_before_tax?
        end

        context "weekly salary of over 430 before tax" do
          setup do
            add_response "1500"
          end

          should "give me statutory redundancy" do
            assert_current_node :done
          end

          should "give me a figure no higher than 430 per week" do
            assert_state_variable :statutory_redundancy_pay, "1,290"
            assert_state_variable :statutory_redundancy_pay_ni, "1,290"
          end
        end

        context "weekly salary of under 430 before tax" do
          setup do
            add_response "300"
          end

          should "give me a figure below 430" do
            assert_state_variable :statutory_redundancy_pay, "900"
            assert_state_variable :statutory_redundancy_pay_ni, "900"
          end
        end
      end
    end
  end # Before Feb 2013
  context "answer 1 Feb 2013, 42 y/o, worked for 4.5 years" do
    should "give the answer using the new rate" do
      add_response '2013-02-01'
      add_response '42'
      add_response '4.5'
      add_response '700'
      assert_current_node :done
      assert_state_variable :rate, 450
      assert_state_variable :ni_rate, 450
    end
  end # After Feb 2013

  context "2015/2016" do
    should "Use the correct rates" do
      add_response '2015-05-01'
      add_response '22'
      add_response '7'
      add_response '700'
      assert_current_node :done
      assert_state_variable :rate, 475
      assert_state_variable :ni_rate, 490
      assert_state_variable :max_amount, "14,250"
      assert_state_variable :ni_max_amount, "14,700"
      assert_state_variable :statutory_redundancy_pay, "1,662.50"
      assert_state_variable :statutory_redundancy_pay_ni, "1,715"
    end
  end

  context "answer 05 April 2014" do
    setup do
      add_response Date.parse("2014-04-05")
    end
    should "ask employee age" do
      assert_current_node :age_of_employee?
    end
  end
end
