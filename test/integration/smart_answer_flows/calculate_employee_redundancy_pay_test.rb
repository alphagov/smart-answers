require_relative '../../test_helper'
require_relative 'flow_test_helper'

require "smart_answer_flows/calculate-employee-redundancy-pay"

class CalculateEmployeeRedundancyPayTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::CalculateEmployeeRedundancyPayFlow
  end

  should "ask when the employee was made redundant" do
    assert_current_node :date_of_redundancy?
  end

  context "answer before 1 Feb 2013" do
    setup do
      add_response '2013-01-31'
    end

    should "ask the age of the employee" do
      assert_current_node :age_of_employee?
      assert_state_variable :rate, 430
      assert_state_variable :ni_rate, 430
      assert_state_variable :max_amount, "12,900"
      assert_state_variable :ni_max_amount, "12,900"
    end

    context "aged 42" do
      setup do
        add_response "42"
      end

      should "ask how long the employee has been employed" do
        assert_current_node :years_employed?
      end

      context "1 year of employment" do
        setup do
          add_response "1"
        end

        should "bypass the salary question" do
          assert_current_node :done_no_statutory
        end
      end

      context "4 years of employment" do
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
            assert_state_variable :statutory_redundancy_pay, "1,935"
            assert_state_variable :statutory_redundancy_pay_ni, "1,935"
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

          should "give me the number of weeks entitlement" do
            assert_state_variable :number_of_weeks_entitlement, 2.0
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

          should "give me 2 weeks total entitlement" do
            assert_state_variable :number_of_weeks_entitlement, 2.0
          end
        end
      end
    end

    context "under 22 years of age" do
      setup do
        add_response "19"
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
          should "give me 2 weeks total entitlement" do
            assert_state_variable :number_of_weeks_entitlement, 2.0
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

          should "give me 2 weeks total entitlement" do
            assert_state_variable :number_of_weeks_entitlement, 2.0
          end
        end
      end
    end
  end # Before 1 Feb 2013
  context "answer after 1 Feb 2013" do
    should "give the answer using the new rate" do
      add_response '2013-02-01'
      add_response '19'
      add_response '2'
      add_response '500'
      assert_current_node :done
      assert_state_variable :rate, 450
      assert_state_variable :ni_rate, 450
      assert_state_variable :max_amount, "13,500"
      assert_state_variable :ni_max_amount, "13,500"
    end
  end # After Feb 2013

  context "answer tomorrow" do
    setup do
      add_response((Date.today + 1.day).to_s)
    end
    should "ask employee age" do
      assert_current_node :age_of_employee?
    end
  end

  context "dates out of range" do
    should "not allow dates before 2012" do
      add_response Date.parse("2011-12-31")
      assert_current_node_is_error
    end

    should "not allow dates next year" do
      add_response((Date.today.end_of_year + 1.day).to_s)
      assert_current_node_is_error
    end
  end
end
