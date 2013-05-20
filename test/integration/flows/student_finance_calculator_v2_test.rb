# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class StudentFinanceCalculatorV2Test < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'student-finance-calculator-v2'
  end

  should "ask when your course starts" do
    assert_current_node :when_does_your_course_start?
  end

  context "course starting between 2013 and 2014" do
    setup do
      add_response '2013-2014'
    end
    should "ask what sort of a student you are" do
      assert_current_node :what_type_of_student_are_you?
    end

    context "full-time uk student between 2013 and 2014" do
      setup do
        add_response 'uk-full-time'
      end

      should "ask how much your tuition fees are per year" do
        assert_current_node :how_much_are_your_tuition_fees_per_year?
      end
      should "be invalid if a fee over 9000 is entered" do
        add_response '9001'
        assert_current_node :how_much_are_your_tuition_fees_per_year?, :error => true
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
              should "go to result with teacher training" do
                add_response 'teacher-training'
                assert_current_node :outcome_uk_full_time_students
                assert_phrase_list :eligible_finance, [:tuition_fee_loan, :maintenance_loan, :maintenance_grant]
                assert_state_variable :tuition_fee_amount, 7500
                assert_state_variable :maintenance_loan_amount, 2698 #4375 - (maintenance_grant_amount/2.0).floor
                assert_state_variable :maintenance_grant_amount, 3354
                assert_phrase_list :students_body_text, [:uk_students_body_text]
                assert_phrase_list :uk_full_time_students, [:additional_benefits, :children_under_17, :dependant_adult, :has_disability, :low_income, :teacher_training]
                assert_phrase_list :household_income_figure, [:uk_students_body_text_with_nsp]
              end # end should
            end # end context children
          end # end context income
        end # end context living at home
      end # end context valid fees
    end # end context full-time student

    context "uk part-time student, with extra help circumstances" do
      setup do
        add_response 'uk-part-time'
        add_response '6000'
        add_response 'has-disability,low-income'
        add_response 'dental-medical-healthcare'
      end
      should "go to all uk students outcome" do
        assert_current_node :outcome_uk_all_students
        assert_phrase_list :eligible_finance, [:tuition_fee_loan]
        assert_state_variable :tuition_fee_amount, 6000
        assert_phrase_list :students_body_text, [:uk_students_body_text]
        assert_phrase_list :uk_all_students, [:additional_benefits, :has_disability, :low_income, :dental_medical_healthcare, :uk_students_body_text_no_nsp]
      end
    end

    context "uk part-time student, no extra help circumstances" do
      setup do
        add_response 'uk-part-time'
        add_response '6000'
        add_response 'no'
        add_response 'none-of-the-above'
      end
      should "go to all uk students outcome" do
        assert_current_node :outcome_uk_all_students
        assert_phrase_list :eligible_finance, [:tuition_fee_loan]
        assert_state_variable :tuition_fee_amount, 6000
                assert_phrase_list :students_body_text, [:uk_students_body_text]
        assert_phrase_list :uk_all_students, [:no_additional_benefits, :uk_students_body_text_no_nsp]
      end
    end

    context "eu full-time student" do
      setup do
        add_response 'eu-full-time'
        add_response '8000'
      end
      should "go to eu full-time students outcome" do
        assert_current_node :outcome_eu_students
        assert_phrase_list :eligible_finance, [:tuition_fee_loan]
        assert_state_variable :tuition_fee_amount, 8000
        assert_phrase_list :eu_students, [:eu_students_body_text, :eu_full_time_students, :eu_students_body_text_two]
      end
    end

    context "eu part-time student" do
      setup do
        add_response 'eu-part-time'
        add_response '4100'
      end
      should "go to eu part-time students outcome" do
        assert_current_node :outcome_eu_students
        assert_phrase_list :eligible_finance, [:tuition_fee_loan]
        assert_state_variable :tuition_fee_amount, 4100
        assert_phrase_list :eu_students, [:eu_students_body_text, :eu_part_time_students, :eu_students_body_text_two]
      end
    end

    
  end
end


