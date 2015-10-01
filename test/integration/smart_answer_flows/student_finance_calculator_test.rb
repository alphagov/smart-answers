require_relative '../../test_helper'
require_relative 'flow_test_helper'

require "smart_answer_flows/student-finance-calculator"

class StudentFinanceCalculatorTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::StudentFinanceCalculatorFlow
  end

  should "ask when your course starts" do
    assert_current_node :when_does_your_course_start?
  end

  context "course starting between 2015 and 2016" do
    setup do
      add_response '2015-2016'
    end
    should "ask what sort of a student you are" do
      assert_current_node :what_type_of_student_are_you?
    end

    context "full-time uk student between 2015 and 2016" do
      setup do
        add_response 'uk-full-time'
      end

      should "ask how much your tuition fees are per year" do
        assert_current_node :how_much_are_your_tuition_fees_per_year?
      end
      should "be invalid if a fee over 9000 is entered" do
        add_response '9001'
        assert_current_node :how_much_are_your_tuition_fees_per_year?, error: true
      end

      context "with valid fees entered" do
        setup do
          add_response '7500'
        end
        should "ask where you will live while studying" do
          assert_current_node :where_will_you_live_while_studying?
        end

        context "living at home" do
          setup do
            add_response 'at-home'
          end
          should "ask whats your household income" do
            assert_current_node :whats_your_household_income?
          end

          context "household income higher than limit" do
            should "reduce the maintenance loan amount by £1 for every £9.59 over the threshold" do
              add_response '43875'
              assert_state_variable :maintenance_loan_amount, 4461
            end
          end

          context "household income up to 25k" do
            setup do
              add_response '24500'
            end
            should "ask do any of the following apply?" do
              assert_current_node :do_any_of_the_following_apply_uk_full_time_students_only?
            end

            context "has children under 17 and adult dependant" do
              setup do
                add_response 'children-under-17,dependant-adult,has-disability,low-income'
              end
              should "ask what course you are studying" do
                assert_current_node :what_course_are_you_studying?
              end
            end # end context children
          end # end context income
        end # end context living at home
      end # end context valid fees
    end # end context full-time student
  end
end
