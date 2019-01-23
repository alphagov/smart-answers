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

  context "course starting between 2018 and 2019" do
    setup do
      add_response '2018-2019'
    end
    should "ask what sort of a student you are" do
      assert_current_node :what_type_of_student_are_you?
    end

    context "full-time uk student between 2018 and 2019" do
      setup do
        add_response 'uk-full-time'
      end

      should "ask how much your tuition fees are per year" do
        assert_current_node :how_much_are_your_tuition_fees_per_year?
      end
      should "be invalid if a fee over 9250 is entered" do
        add_response '9251'
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
              context "What course are you studying?" do
                setup do
                  add_response 'dental-medical-healthcare'
                end
                should "ask are you studying one of these dental or medical courses?" do
                  assert_current_node :are_you_a_doctor_or_dentist?
                end

                context "You are a doctor or dentist" do
                  setup do
                    add_response 'yes'
                  end
                  should "be on the full time dental and medical student outcome" do
                    assert_current_node :outcome_uk_full_time_dental_medical_students
                  end
                end

                context "You are not a doctor dentist" do
                  setup do
                    add_response 'no'
                  end

                  should "be on the full time student outcome" do
                    assert_current_node :outcome_uk_full_time_students
                  end
                end
              end
            end
          end
        end
      end
    end

    context "part-time uk student between 2018 and 2019" do
      should "ask how much your tuition fees are per year" do
        add_response 'uk-part-time'
        assert_current_node :how_much_are_your_tuition_fees_per_year?
      end
      should "be invalid if a fee over 6935 is entered" do
        add_response 'uk-part-time'
        add_response '6936'
        assert_current_node :how_much_are_your_tuition_fees_per_year?, error: true
      end
      should "ask where you live" do
        add_response 'uk-part-time'
        add_response '6935'
        assert_current_node :where_will_you_live_while_studying?
      end
      should "ask for your household income" do
        add_response 'uk-part-time'
        add_response '6935'
        add_response 'at-home'
        assert_current_node :whats_your_household_income?
      end
      should "ask how many credits you will study" do
        add_response 'uk-part-time'
        add_response '6935'
        add_response 'at-home'
        add_response '5000'
        assert_current_node :how_many_credits_will_you_study?
      end
      should "be invalid if course credits are negative" do
        add_response 'uk-part-time'
        add_response '6935'
        add_response 'at-home'
        add_response '5000'
        add_response '-1'
        assert_current_node :how_many_credits_will_you_study?, error: true
      end
      should "ask how many credits a full-time student on the same course would study" do
        add_response 'uk-part-time'
        add_response '6935'
        add_response 'at-home'
        add_response '5000'
        add_response '10'
        assert_current_node :how_many_credits_does_a_full_time_student_study?
      end
      should "be invalid if full time credits are negative" do
        add_response 'uk-part-time'
        add_response '6935'
        add_response 'at-home'
        add_response '5000'
        add_response '5'
        add_response '-1'
        assert_current_node :how_many_credits_does_a_full_time_student_study?, error: true
      end
      should "be invalid if full time credits are less than part time course credits" do
        add_response 'uk-part-time'
        add_response '6935'
        add_response 'at-home'
        add_response '5000'
        add_response '20'
        add_response '19'
        assert_current_node :how_many_credits_does_a_full_time_student_study?, error: true
      end
      should "ask do any of the following apply?" do
        add_response 'uk-part-time'
        add_response '6935'
        add_response 'at-home'
        add_response '5000'
        add_response '5'
        add_response '10'
        assert_current_node :do_any_of_the_following_apply_all_uk_students?
      end
      should "ask what course are you studying?" do
        add_response 'uk-part-time'
        add_response '6935'
        add_response 'at-home'
        add_response '5000'
        add_response '5'
        add_response '10'
        add_response 'has-disability,low-income'
        assert_current_node :what_course_are_you_studying?
      end
      should "go to the outcome for all part-time UK students" do
        add_response 'uk-part-time'
        add_response '6935'
        add_response 'at-home'
        add_response '5000'
        add_response '5'
        add_response '10'
        add_response 'has-disability,low-income'
        add_response 'dental-medical-healthcare'
        assert_current_node :outcome_uk_all_students
      end
    end
  end


end
