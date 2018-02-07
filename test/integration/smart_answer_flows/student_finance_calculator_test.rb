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

  context "course starting between 2017 and 2018" do
    setup do
      add_response '2017-2018'
    end
    should "ask what sort of a student you are" do
      assert_current_node :what_type_of_student_are_you?
    end

    context "full-time uk student between 2017 and 2018" do
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
                  assert_current_node :are_you_studying_one_of_these_dental_or_medical_courses?
                end
                context "What dental or medical course are you studying?" do
                  setup do
                    add_response 'dental-hygiene-or-dental-therapy'
                  end
                  should "ask what course you are studying" do
                    assert_current_node :outcome_uk_full_time_dental_medical_students
                  end
                end # end what dental or medical course
              end # end what course
            end # end context children
          end # end context income
        end # end context living at home
      end # end context valid fees
    end # end context full-time student

    context "part-time uk student between 2017 and 2018" do
      should "ask how much your tuition fees are per year" do
        add_response 'uk-part-time'
        assert_current_node :how_much_are_your_tuition_fees_per_year?
      end
      should "be invalid if a fee over 6935 is entered" do
        add_response 'uk-part-time'
        add_response '6936'
        assert_current_node :how_much_are_your_tuition_fees_per_year?, error: true
      end
      should "ask do any of the following apply?" do
        add_response 'uk-part-time'
        add_response '6935'
        assert_current_node :do_any_of_the_following_apply_all_uk_students?
      end
      should "ask what course are you studying?" do
        add_response 'uk-part-time'
        add_response '6935'
        add_response 'has-disability,low-income'
        assert_current_node :what_course_are_you_studying?
      end
      should "ask are you studying dental hygiene or dental therapy?" do
        add_response 'uk-part-time'
        add_response '6935'
        add_response 'has-disability,low-income'
        add_response 'dental-medical-healthcare'
        assert_current_node :are_you_studying_dental_hygiene_or_dental_therapy?
      end
      should "show uk part time dental medical students outcome" do
        add_response 'uk-part-time'
        add_response '6935'
        add_response 'has-disability,low-income'
        add_response 'dental-medical-healthcare'
        add_response 'yes'
        assert_current_node :outcome_uk_part_time_dental_medical_students
      end
      should "show uk all students outcome" do
        add_response 'uk-part-time'
        add_response '6935'
        add_response 'has-disability,low-income'
        add_response 'dental-medical-healthcare'
        add_response 'no'
        assert_current_node :outcome_uk_all_students
      end
    end # end context part-time student
  end

  context "#dental-medical-healthcare" do
    context "#uk-full-time students" do
      context "#doctor-or-dentist" do
        should "Go to outcome_uk_full_time_dental_medical_students" do
          add_response '2017-2018' # When does your course start?
          add_response 'uk-full-time' # What type of student are you?
          add_response '9000' # Tuition fee amount
          add_response 'away-in-london' # Living situation
          add_response '0' # Household income
          add_response 'no' # Any special circumstances
          add_response 'dental-medical-healthcare' # Studying dental-medical-healthcare
          add_response 'doctor-or-dentist' # Studying to be a doctor or dentist

          assert_current_node :outcome_uk_full_time_dental_medical_students
        end
      end

      context "#dental-hygiene-or-dental-therapy" do
        should "Go to outcome_uk_full_time_dental_medical_students" do
          add_response '2017-2018' # When does your course start?
          add_response 'uk-full-time' # What type of student are you?
          add_response '9000' # Tuition fee amount
          add_response 'away-in-london' # Living situation
          add_response '0' # Household income
          add_response 'no' # Any special circumstances
          add_response 'dental-medical-healthcare' # Studying dental-medical-healthcare
          add_response 'dental-hygiene-or-dental-therapy' # Studying dental hygiene or dental therapy

          assert_current_node :outcome_uk_full_time_dental_medical_students
        end
      end

      context "#none-of-the-above" do
        should "Go to outcome_uk_full_time_students" do
          add_response '2017-2018' # When does your course start?
          add_response 'uk-full-time' # What type of student are you?
          add_response '9000' # Tuition fee amount
          add_response 'away-in-london' # Living situation
          add_response '0' # Household income
          add_response 'no' # Any special circumstances
          add_response 'dental-medical-healthcare' # Studying dental-medical-healthcare
          add_response 'none-of-the-above' # Studying another dental or medical course

          assert_current_node :outcome_uk_full_time_students
        end
      end
    end

    context "#uk-part-time students" do
      context "dental hygiene or dental therapy" do
        should "Go to outcome_uk_part_time_dental_medical_students" do
          add_response '2017-2018' # When does your course start?
          add_response 'uk-part-time' # What type of student are you?
          add_response '6750' # Tuition fee amount
          add_response 'no' # Any special circumstances
          add_response 'dental-medical-healthcare' # Studying dental-medical-healthcare
          add_response 'yes' # Studying dental hygiene or dental therapy

          assert_current_node :outcome_uk_part_time_dental_medical_students
        end
      end

      context "other medical or dental course" do
        should "Go to outcome_uk_all_students" do
          add_response '2017-2018' # When does your course start?
          add_response 'uk-part-time' # What type of student are you?
          add_response '6750' # Tuition fee amount
          add_response 'no' # Any special circumstances
          add_response 'dental-medical-healthcare' # Studying dental-medical-healthcare
          add_response 'no' # Not studying dental hygiene or dental therapy

          assert_current_node :outcome_uk_all_students
        end
      end
    end
  end

  context "#teacher-training" do
    context "#uk-full-time students" do
      should "Go to outcome_uk_full_time_students" do
        add_response '2017-2018' # When does your course start?
        add_response 'uk-full-time' # What type of student are you?
        add_response '9000' # Tuition fee amount
        add_response 'away-in-london' # Living situation
        add_response '0' # Household income
        add_response 'no' # Any special circumstances
        add_response 'teacher-training' # Studying dental-medical-healthcare

        assert_current_node :outcome_uk_full_time_students
      end
    end

    context "#uk-full-time students" do
      should "Go to outcome_uk_part_time_students" do
        add_response '2017-2018' # When does your course start?
        add_response 'uk-part-time' # What type of student are you?
        add_response '6750' # Tuition fee amount
        add_response 'no' # Any special circumstances
        add_response 'teacher-training' # Studying dental-medical-healthcare

        assert_current_node :outcome_uk_all_students
      end
    end
  end
end
