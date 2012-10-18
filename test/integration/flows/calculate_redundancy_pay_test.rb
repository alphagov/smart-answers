# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class CalculateRedundancyPayTest < ActiveSupport::TestCase
  include FlowTestHelper

  context "Employer" do
    setup do
      setup_for_testing_flow 'calculate-employee-redundancy-pay'
    end

    should "be in employer flow for age" do
      assert_current_node :age_of_employee?
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
          end
        end

        context "weekly salary of under 430 before tax" do
          setup do
            add_response "300"
          end

          should "give me a figure below 430" do
            assert_state_variable :statutory_redundancy_pay, "600"
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
          end
        end

        context "weekly salary of under 430 before tax" do
          setup do
            add_response "300"
          end

          should "give me a figure below 430" do
            assert_state_variable :statutory_redundancy_pay, "900"
          end
        end
      end
    end
  end

  context "Employee" do
    setup do
      setup_for_testing_flow 'calculate-your-redundancy-pay'
    end

    should "be in employee flow for age" do
      assert_current_node :age_of_employee?
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
          end
        end

        context "weekly salary of under 430 before tax" do
          setup do
            add_response "300"
          end

          should "give me a figure below 430" do
            assert_state_variable :statutory_redundancy_pay, "600"
          end
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
          end
        end

        context "weekly salary of under 430 before tax" do
          setup do
            add_response "300"
          end

          should "give me a figure below 430" do
            assert_state_variable :statutory_redundancy_pay, "900"
          end
        end
      end
    end
  end
end
