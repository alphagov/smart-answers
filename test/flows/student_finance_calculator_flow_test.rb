require "test_helper"
require "support/flow_test_helper"

class StudentFinanceCalculatorTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup { testing_flow StudentFinanceCalculatorFlow }

  should "render a start page" do
    assert_rendered_start_page
  end

  context "question: when_does_your_course_start?" do
    setup { testing_node :when_does_your_course_start? }

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      context "pre-LLE responses" do
        should "have a next node of what_loans_are_you_eligible_for? for 2025-2026 response" do
          assert_next_node :what_loans_are_you_eligible_for?, for_response: "2025-2026"
        end

        should "have a next node of what_loans_are_you_eligible_for? for 2026-2027 response" do
          assert_next_node :what_loans_are_you_eligible_for?, for_response: "2026-2027"
        end
      end

      context "post-LLE responses" do
        should "have a next node of what_age_are_you_on_first_day_of_course? for 2027-2028 response" do
          assert_next_node :what_age_are_you_on_first_day_of_course?, for_response: "2027-2028"
        end
      end
    end
  end

  context "question: what_loans_are_you_eligible_for?," do
    setup do
      testing_node :what_loans_are_you_eligible_for?
      add_responses when_does_your_course_start?: "2025-2026"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of will_you_be_studying_full_or_part_time? for any response" do
        assert_next_node :will_you_be_studying_full_or_part_time?, for_response: "tuition-and-maintenance"
      end
    end
  end

  context "question: will_you_be_studying_full_or_part_time?," do
    setup do
      testing_node :will_you_be_studying_full_or_part_time?
      add_responses when_does_your_course_start?: "2025-2026",
                    what_loans_are_you_eligible_for?: "tuition-and-maintenance"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of how_much_are_your_tuition_fees_per_year? for any response" do
        assert_next_node :how_much_are_your_tuition_fees_per_year?, for_response: "full-time"
      end
    end
  end

  context "question: how_much_are_your_tuition_fees_per_year?," do
    setup do
      testing_node :how_much_are_your_tuition_fees_per_year?
      add_responses when_does_your_course_start?: "2025-2026",
                    what_loans_are_you_eligible_for?: "tuition-and-maintenance",
                    will_you_be_studying_full_or_part_time?: "full-time"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      %w[tuition-and-maintenance tuition-only].each do |loan_type|
        should "be invalid for a fee greater than the maximum for a full-time student with a #{loan_type} loan" do
          add_responses when_does_your_course_start?: "2025-2026",
                        what_loans_are_you_eligible_for?: loan_type,
                        will_you_be_studying_full_or_part_time?: "full-time"
          max_for_full_time = SmartAnswer::Calculators::StudentFinanceCalculator::TUITION_FEE_MAXIMUM["2025-2026"]["full-time"]
          assert_invalid_response (max_for_full_time + 1).to_s
        end

        should "be invalid for a fee greater than the maximum for a part-time student with a #{loan_type} loan" do
          add_responses when_does_your_course_start?: "2025-2026",
                        what_loans_are_you_eligible_for?: loan_type,
                        will_you_be_studying_full_or_part_time?: "part-time"
          max_for_part_time = SmartAnswer::Calculators::StudentFinanceCalculator::TUITION_FEE_MAXIMUM["2025-2026"]["part-time"]
          assert_invalid_response (max_for_part_time + 1).to_s
        end
      end
    end

    context "next_node" do
      %w[full-time part-time].each do |course_type|
        should "have a next node of where_will_you_live_while_studying? for a #{course_type} student with a tuition-and-maintenance loan" do
          add_responses what_loans_are_you_eligible_for?: "tuition-and-maintenance",
                        will_you_be_studying_full_or_part_time?: course_type
          assert_next_node :where_will_you_live_while_studying?, for_response: "5000"
        end

        should "have a next node of outcome_tuition_fee_only for a #{course_type} student with a tuition-only loan" do
          add_responses what_loans_are_you_eligible_for?: "tuition-only",
                        will_you_be_studying_full_or_part_time?: course_type
          assert_next_node :outcome_tuition_fee_only, for_response: "5000"
        end
      end
    end
  end

  context "question: where_will_you_live_while_studying?," do
    setup do
      testing_node :where_will_you_live_while_studying?
      add_responses when_does_your_course_start?: "2025-2026",
                    what_loans_are_you_eligible_for?: "tuition-and-maintenance",
                    will_you_be_studying_full_or_part_time?: "full-time",
                    how_much_are_your_tuition_fees_per_year?: "9250"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of whats_your_household_income? for any response" do
        assert_next_node :whats_your_household_income?, for_response: "at-home"
      end
    end
  end

  context "question: whats_your_household_income?," do
    setup do
      testing_node :whats_your_household_income?
      add_responses when_does_your_course_start?: "2025-2026",
                    what_loans_are_you_eligible_for?: "tuition-and-maintenance",
                    will_you_be_studying_full_or_part_time?: "full-time",
                    how_much_are_your_tuition_fees_per_year?: "6935",
                    where_will_you_live_while_studying?: "at-home"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node do_any_of_the_following_apply_uk_120_credits_or_above? for full time students" do
        assert_next_node :do_any_of_the_following_apply_uk_120_credits_or_above?, for_response: "50,000"
      end

      should "have a next node of how_many_credits_will_you_study? for part time students" do
        add_responses will_you_be_studying_full_or_part_time?: "part-time"

        assert_next_node :how_many_credits_will_you_study?, for_response: "50,000"
      end
    end
  end

  context "question: how_many_credits_will_you_study?" do
    setup do
      testing_node :how_many_credits_will_you_study?
      add_responses when_does_your_course_start?: "2025-2026",
                    what_loans_are_you_eligible_for?: "tuition-and-maintenance",
                    will_you_be_studying_full_or_part_time?: "part-time",
                    how_much_are_your_tuition_fees_per_year?: "6935",
                    where_will_you_live_while_studying?: "at-home",
                    whats_your_household_income?: "50,000"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid if the number of credits entered is less than 0" do
        assert_invalid_response "0"
      end

      should "be invalid if the number of credits entered is not a whole number" do
        assert_invalid_response "100.1"
      end
    end

    context "next_node" do
      should "have a next node of how_many_credits_does_a_full_time_student_study for any response" do
        assert_next_node :how_many_credits_does_a_full_time_student_study?, for_response: "10"
      end
    end
  end

  context "question: how_many_credits_does_a_full_time_student_study?" do
    setup do
      testing_node :how_many_credits_does_a_full_time_student_study?
      add_responses when_does_your_course_start?: "2025-2026",
                    what_loans_are_you_eligible_for?: "tuition-and-maintenance",
                    will_you_be_studying_full_or_part_time?: "part-time",
                    how_much_are_your_tuition_fees_per_year?: "6935",
                    where_will_you_live_while_studying?: "at-home",
                    whats_your_household_income?: "50,000",
                    how_many_credits_will_you_study?: "10"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      should "be invalid if the number of full time credits is less than part time course credits" do
        assert_invalid_response "9"
      end

      should "be invalid if the number of credits entered is not a whole number" do
        assert_invalid_response "100.1"
      end
    end

    context "next_node" do
      should "have a next node of do_any_of_the_following_apply_all_uk_students for a response that is greater than the number of part-time credits?" do
        assert_next_node :do_any_of_the_following_apply_all_uk_students?, for_response: "11"
      end
    end
  end

  context "question: do_any_of_the_following_apply_uk_120_credits_or_above?" do
    setup do
      testing_node :do_any_of_the_following_apply_uk_120_credits_or_above?
      add_responses when_does_your_course_start?: "2025-2026",
                    what_loans_are_you_eligible_for?: "tuition-and-maintenance",
                    will_you_be_studying_full_or_part_time?: "full-time",
                    how_much_are_your_tuition_fees_per_year?: "9250",
                    where_will_you_live_while_studying?: "at-home",
                    whats_your_household_income?: "50,000"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node what_course_are_you_studying? for any response" do
        assert_next_node :what_course_are_you_studying?, for_response: "children-under-17"
      end
    end
  end

  context "question: do_any_of_the_following_apply_all_uk_students?" do
    setup do
      testing_node :do_any_of_the_following_apply_all_uk_students?
      add_responses when_does_your_course_start?: "2025-2026",
                    what_loans_are_you_eligible_for?: "tuition-and-maintenance",
                    will_you_be_studying_full_or_part_time?: "part-time",
                    how_much_are_your_tuition_fees_per_year?: "6935",
                    where_will_you_live_while_studying?: "at-home",
                    whats_your_household_income?: "50,000",
                    how_many_credits_will_you_study?: "10",
                    how_many_credits_does_a_full_time_student_study?: "11"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of what_course_are_you_studying? for any response" do
        assert_next_node :what_course_are_you_studying?, for_response: "has-disability"
      end
    end
  end

  context "question: what_course_are_you_studying?," do
    setup do
      testing_node :what_course_are_you_studying?
      add_responses when_does_your_course_start?: "2025-2026",
                    what_loans_are_you_eligible_for?: "tuition-and-maintenance",
                    will_you_be_studying_full_or_part_time?: "full-time",
                    how_much_are_your_tuition_fees_per_year?: "6935",
                    where_will_you_live_while_studying?: "at-home",
                    whats_your_household_income?: "50,000",
                    do_any_of_the_following_apply_uk_120_credits_or_above?: "children-under-17"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of outcome_uk_full_time_students for full time, non medical, uk students" do
        assert_next_node :outcome_uk_full_time_students, for_response: "teacher-training"
      end

      should "have a next node of are_you_a_doctor_or_dentist? for full time uk students given a dental-medical-healthcare response" do
        assert_next_node :are_you_a_doctor_or_dentist?, for_response: "dental-medical-healthcare"
      end

      should "have a next node of outcome_uk_part_time_students for part time, non medical, uk students" do
        add_responses will_you_be_studying_full_or_part_time?: "part-time",
                      how_many_credits_will_you_study?: "10",
                      how_many_credits_does_a_full_time_student_study?: "11",
                      do_any_of_the_following_apply_all_uk_students?: "has-disability"
        assert_next_node :outcome_uk_part_time_students, for_response: "dental-medical-healthcare"
      end
    end
  end

  context "question: are_you_a_doctor_or_dentist?," do
    setup do
      testing_node :are_you_a_doctor_or_dentist?
      add_responses when_does_your_course_start?: "2025-2026",
                    what_loans_are_you_eligible_for?: "tuition-and-maintenance",
                    will_you_be_studying_full_or_part_time?: "full-time",
                    how_much_are_your_tuition_fees_per_year?: "9250",
                    where_will_you_live_while_studying?: "at-home",
                    whats_your_household_income?: "50,000",
                    do_any_of_the_following_apply_uk_120_credits_or_above?: "children-under-17",
                    what_course_are_you_studying?: "dental-medical-healthcare"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of outcome_uk_full_time_students for a no response" do
        assert_next_node :outcome_uk_full_time_students, for_response: "no"
      end

      should "have a next node of outcome_uk_full_time_dental_medical_students for a yes response" do
        assert_next_node :outcome_uk_full_time_dental_medical_students, for_response: "yes"
      end
    end
  end

  context "outcome: outcome_uk_full_time_students" do
    setup do
      testing_node :outcome_uk_full_time_students
      add_responses when_does_your_course_start?: "2026-2027",
                    what_loans_are_you_eligible_for?: "tuition-and-maintenance",
                    will_you_be_studying_full_or_part_time?: "full-time",
                    how_much_are_your_tuition_fees_per_year?: "9250",
                    where_will_you_live_while_studying?: "at-home",
                    whats_your_household_income?: "50,000",
                    do_any_of_the_following_apply_uk_120_credits_or_above?: "children-under-17",
                    what_course_are_you_studying?: "teacher-training"
    end

    should "render text for when the student is not eligible for extra grants and allowances" do
      add_responses do_any_of_the_following_apply_uk_120_credits_or_above?: "no",
                    what_course_are_you_studying?: "none-of-the-above"

      assert_rendered_outcome text: "You do not qualify for any extra grants or allowances."
    end

    should "render text for when the student is not eligible for extra grants and allowances and has a dependant adult" do
      add_responses do_any_of_the_following_apply_uk_120_credits_or_above?: "dependant-adult",
                    what_course_are_you_studying?: "none-of-the-above"

      assert_rendered_outcome text: "You do not qualify for any extra grants or allowances."
    end

    should "render text for when the student is not eligible for extra grants and allowances and is a care leaver" do
      add_responses do_any_of_the_following_apply_uk_120_credits_or_above?: "care-leaver",
                    what_course_are_you_studying?: "none-of-the-above"

      assert_rendered_outcome text: "You do not qualify for any extra grants or allowances."
    end

    should "render text for when the student is eligible for extra grants and allowances" do
      assert_rendered_outcome text: "Depending on your income and circumstances"
    end

    should "render text for when the student is eligible for childcare grant, one child" do
      add_responses whats_your_household_income?: "15,000"

      assert_rendered_outcome text: "a week for a single child"
    end

    should "render text for when the student is eligible for childcare grant, more than one child" do
      add_responses whats_your_household_income?: "25,000"

      assert_rendered_outcome text: "a week in Childcare Grant if you have 2 or more children"
    end

    should "render text for when the student is eligible for parents learning allowance" do
      add_responses whats_your_household_income?: "18,000"

      assert_rendered_outcome text: "Parents’ Learning Allowance"
    end

    should "render text for when the student is eligible for an adult dependant's grant" do
      add_responses whats_your_household_income?: "15,000",
                    do_any_of_the_following_apply_uk_120_credits_or_above?: "dependant-adult"

      assert_rendered_outcome text: "Adult Dependant’s Grant"
    end

    should "render text if student has a disability" do
      add_responses do_any_of_the_following_apply_uk_120_credits_or_above?: "has-disability"

      assert_rendered_outcome text: "Disabled Students’ Allowance"
    end

    should "render text if student has low income" do
      add_responses do_any_of_the_following_apply_uk_120_credits_or_above?: "low-income"

      assert_rendered_outcome text: "University and college hardship funds"
    end

    should "render text if student is eligible for teacher training funding" do
      assert_rendered_outcome text: "Funding for teacher training"
    end

    should "render text if student is eligible for social work funding" do
      add_responses what_course_are_you_studying?: "social-work"

      assert_rendered_outcome text: "Social Work Bursary"
    end

    should "render the full time student text within the extra help partial" do
      assert_rendered_outcome text: "You might be able to get help with the costs of travel for study or work placements"
    end

    should "render text if student is a care leaver" do
      add_responses do_any_of_the_following_apply_uk_120_credits_or_above?: "care-leaver"

      assert_rendered_outcome text: "If you’re a care leaver, your household income is not used to calculate your Maintenance Loan."
    end
  end

  context "outcome: outcome_uk_part_time_students" do
    setup do
      testing_node :outcome_uk_part_time_students
      add_responses when_does_your_course_start?: "2026-2027",
                    what_loans_are_you_eligible_for?: "tuition-and-maintenance",
                    will_you_be_studying_full_or_part_time?: "part-time",
                    how_much_are_your_tuition_fees_per_year?: "6935",
                    where_will_you_live_while_studying?: "at-home",
                    whats_your_household_income?: "50,000",
                    how_many_credits_will_you_study?: "10",
                    how_many_credits_does_a_full_time_student_study?: "11",
                    do_any_of_the_following_apply_all_uk_students?: "has-disability",
                    what_course_are_you_studying?: "dental-medical-healthcare"
    end

    should "render text if the student is studying a medical course" do
      assert_rendered_outcome text: "To qualify for a Maintenance Loan you must be studying a DipHE in dental hygiene and dental therapy"
    end

    should "render text if the student is studying a teaching course" do
      add_responses what_course_are_you_studying?: "teacher-training"

      assert_rendered_outcome text: "To qualify for a Maintenance Loan you must be studying an Initial Teacher Training course"
    end

    should "render text if the student is not studying a maintenance loan qualified course" do
      add_responses what_course_are_you_studying?: "none-of-the-above"

      assert_rendered_outcome text: "To qualify for a Maintenance Loan, you must be studying one of the following courses"
    end

    should "render text if the student is eligible for a maintenance loan" do
      add_responses how_many_credits_will_you_study?: "8",
                    how_many_credits_does_a_full_time_student_study?: "10"

      assert_rendered_outcome text: "How your Maintenance Loan is calculated"
    end

    should "not render text if the student is not eligible for a maintenance loan" do
      add_responses how_many_credits_will_you_study?: "2",
                    how_many_credits_does_a_full_time_student_study?: "10"

      assert_no_match "How your Maintenance Loan is calculated", @test_flow.outcome_text
    end

    should "render text for when the student is not eligible for extra grants and allowances" do
      add_responses do_any_of_the_following_apply_all_uk_students?: "no",
                    what_course_are_you_studying?: "none-of-the-above"

      assert_rendered_outcome text: "You do not qualify for any extra grants or allowances"
    end

    should "render text if student has a disability" do
      add_responses do_any_of_the_following_apply_all_uk_students?: "has-disability"

      assert_rendered_outcome text: "Disabled Students’ Allowance"
    end

    should "render text if student has low income" do
      add_responses do_any_of_the_following_apply_all_uk_students?: "low-income"

      assert_rendered_outcome text: "University and college hardship funds"
    end

    should "render text if student is eligible for teacher training funding" do
      add_responses what_course_are_you_studying?: "teacher-training"

      assert_rendered_outcome text: "Funding for teacher training"
    end

    should "render text if student is eligible for social work funding" do
      add_responses what_course_are_you_studying?: "social-work"

      assert_rendered_outcome text: "Social Work Bursary"
    end

    should "render text if student is a care leaver" do
      add_responses do_any_of_the_following_apply_all_uk_students?: "care-leaver"

      assert_rendered_outcome text: "If you’re a care leaver, your household income is not used to calculate your Maintenance Loan."
    end
  end

  context "outcome: outcome_uk_full_time_dental_medical_students" do
    setup do
      testing_node :outcome_uk_full_time_dental_medical_students
      add_responses when_does_your_course_start?: "2025-2026",
                    what_loans_are_you_eligible_for?: "tuition-and-maintenance",
                    will_you_be_studying_full_or_part_time?: "full-time",
                    how_much_are_your_tuition_fees_per_year?: "9250",
                    where_will_you_live_while_studying?: "at-home",
                    whats_your_household_income?: "50,000",
                    do_any_of_the_following_apply_uk_120_credits_or_above?: "children-under-17",
                    what_course_are_you_studying?: "dental-medical-healthcare",
                    are_you_a_doctor_or_dentist?: "yes"
    end

    should "render text for when the student is eligible for childcare grant, one child" do
      add_responses whats_your_household_income?: "15,000"

      assert_rendered_outcome text: "a week for a single child"
    end

    should "render text for when the student is eligible for childcare grant, more than one child" do
      add_responses whats_your_household_income?: "25,000"

      assert_rendered_outcome text: "a week in Childcare Grant if you have 2 or more children"
    end

    should "render text for when the student is eligible for parents learning allowance" do
      add_responses whats_your_household_income?: "18,000"

      assert_rendered_outcome text: "Parents’ Learning Allowance"
    end

    should "render text for when the student is eligible for an adult dependant's grant" do
      add_responses whats_your_household_income?: "15,000",
                    do_any_of_the_following_apply_uk_120_credits_or_above?: "dependant-adult"

      assert_rendered_outcome text: "Adult Dependant’s Grant"
    end

    should "render text if student has a disability" do
      add_responses do_any_of_the_following_apply_uk_120_credits_or_above?: "has-disability"

      assert_rendered_outcome text: "Disabled Students’ Allowance"
    end

    should "render text if student has children under 17" do
      assert_rendered_outcome text: "Childcare Allowance"
    end

    should "render text if student has adult dependenants" do
      add_responses do_any_of_the_following_apply_uk_120_credits_or_above?: "dependant-adult"

      assert_rendered_outcome text: "Dependants’ Allowance"
    end

    should "render text if student has low income" do
      add_responses do_any_of_the_following_apply_uk_120_credits_or_above?: "low-income"

      assert_rendered_outcome text: "University and college hardship funds"
    end

    should "render text if student is a care leaver" do
      add_responses do_any_of_the_following_apply_uk_120_credits_or_above?: "care-leaver"

      assert_rendered_outcome text: "If you need more money to fund your living costs and you qualify, you can apply for extra help."
    end
  end

  context "2027-2028 Lifelong Learning Entitlement (LLE) journey" do
    context "question: what_age_are_you_on_first_day_of_course?" do
      setup do
        testing_node :what_age_are_you_on_first_day_of_course?
        add_responses when_does_your_course_start?: "2027-2028"
      end

      should "render the question" do
        assert_rendered_question
      end

      context "next_node" do
        should "have a next node of how_are_you_planning_to_study? for under-60 response" do
          assert_next_node :how_are_you_planning_to_study?, for_response: "under-60"
        end

        should "have a next node of are_you_studying_one_of_these_courses? for 60-or-more response" do
          assert_next_node :are_you_studying_one_of_these_courses?, for_response: "60-or-more"
        end
      end
    end

    context "when under 60" do
      context "question: how_are_you_planning_to_study?" do
        setup do
          testing_node :how_are_you_planning_to_study?
          add_responses when_does_your_course_start?: "2027-2028",
                        what_age_are_you_on_first_day_of_course?: "under-60"
        end

        should "render the question" do
          assert_rendered_question
        end

        context "next_node" do
          %w[full-time part-time].each do |response|
            should "have a next node of how_many_credits_will_you_study_course_module? for #{response} response" do
              assert_next_node :how_many_credits_will_you_study_course_module?, for_response: response
            end
          end
        end
      end

      context "question: how_many_credits_will_you_study_course_module?" do
        setup do
          testing_node :how_many_credits_will_you_study_course_module?
          add_responses when_does_your_course_start?: "2027-2028",
                        what_age_are_you_on_first_day_of_course?: "under-60",
                        how_are_you_planning_to_study?: "full-time"
        end

        should "render the question" do
          assert_rendered_question
        end

        context "validation" do
          should "be invalid below 30 credits" do
            assert_invalid_response "29"
          end

          should "be invalid above 180 credits" do
            assert_invalid_response "181"
          end

          should "be invalid if the number of credits entered is not a whole number" do
            assert_invalid_response "100.1"
          end

          should "be valid between 30 and 180 credits" do
            assert_valid_response "100"
          end
        end

        context "next_node" do
          should "have a next node of how_much_are_your_tuition_fees_course_or_module? for a full-time student" do
            assert_next_node :how_much_are_your_tuition_fees_course_or_module?, for_response: "120"
          end

          should "have a next node of how_many_credits_fte_course_or_module? for a part-time student" do
            add_responses how_are_you_planning_to_study?: "part-time"
            assert_next_node :how_many_credits_fte_course_or_module?, for_response: "60"
          end
        end
      end

      context "question: how_many_credits_fte_course_or_module?" do
        setup do
          testing_node :how_many_credits_fte_course_or_module?
          add_responses when_does_your_course_start?: "2027-2028",
                        what_age_are_you_on_first_day_of_course?: "under-60",
                        how_are_you_planning_to_study?: "part-time",
                        how_many_credits_will_you_study_course_module?: "60"
        end

        should "render the question" do
          assert_rendered_question
        end

        context "validation" do
          should "be invalid below part-time credits" do
            assert_invalid_response "59"
          end

          should "be invalid above 180 credits" do
            assert_invalid_response "181"
          end

          should "be invalid if the number of credits entered is not a whole number" do
            assert_invalid_response "100.1"
          end

          should "be valid between part-time credits and 180 credits" do
            assert_valid_response "100"
          end
        end

        context "next_node" do
          should "have a next node of how_much_are_your_tuition_fees_course_or_module?" do
            assert_next_node :how_much_are_your_tuition_fees_course_or_module?, for_response: "120"
          end
        end
      end

      context "question: how_much_are_your_tuition_fees_course_or_module?" do
        setup do
          testing_node :how_much_are_your_tuition_fees_course_or_module?
          add_responses when_does_your_course_start?: "2027-2028",
                        what_age_are_you_on_first_day_of_course?: "under-60",
                        how_are_you_planning_to_study?: "full-time",
                        how_many_credits_will_you_study_course_module?: "120"
        end

        should "render the question" do
          assert_rendered_question
        end

        context "validation" do
          # The LLE maximum for 120 credits is (120 / 120) * 9790 = £9790
          should "be invalid if above the LLE maximum for 120 credits" do
            assert_invalid_response "9791"
          end

          should "be valid if not above the LLE maximum for 120 credits" do
            assert_valid_response "9790"
          end
        end

        context "next_node" do
          should "have a next node of have_you_studied_before?" do
            assert_next_node :have_you_studied_before?, for_response: "9790"
          end
        end
      end

      context "question: have_you_studied_before?" do
        setup do
          testing_node :have_you_studied_before?
          add_responses when_does_your_course_start?: "2027-2028",
                        what_age_are_you_on_first_day_of_course?: "under-60",
                        how_are_you_planning_to_study?: "full-time",
                        how_many_credits_will_you_study_course_module?: "120",
                        how_much_are_your_tuition_fees_course_or_module?: "9790"
        end

        should "render the question" do
          assert_rendered_question
        end

        context "next_node" do
          should "have a next node of will_you_attend_in_person? for yes response" do
            assert_next_node :will_you_attend_in_person?, for_response: "yes"
          end

          should "have a next node of will_you_attend_in_person? for no response" do
            assert_next_node :will_you_attend_in_person?, for_response: "no"
          end
        end
      end

      context "question: will_you_attend_in_person?" do
        setup do
          testing_node :will_you_attend_in_person?
          add_responses when_does_your_course_start?: "2027-2028",
                        what_age_are_you_on_first_day_of_course?: "under-60",
                        how_are_you_planning_to_study?: "full-time",
                        how_many_credits_will_you_study_course_module?: "120",
                        how_much_are_your_tuition_fees_course_or_module?: "9790",
                        have_you_studied_before?: "yes"
        end

        should "render the question" do
          assert_rendered_question
        end

        context "next_node" do
          should "have a next node of where_will_you_live_while_studying_lle? for yes response" do
            assert_next_node :where_will_you_live_while_studying_lle?, for_response: "yes"
          end

          should "have a next node of are_you_unable_to_be_in_person_disability? for no response" do
            assert_next_node :are_you_unable_to_be_in_person_disability?, for_response: "no"
          end
        end
      end

      context "question: are_you_unable_to_be_in_person_disability?" do
        setup do
          testing_node :are_you_unable_to_be_in_person_disability?
          add_responses when_does_your_course_start?: "2027-2028",
                        what_age_are_you_on_first_day_of_course?: "under-60",
                        how_are_you_planning_to_study?: "full-time",
                        how_many_credits_will_you_study_course_module?: "120",
                        how_much_are_your_tuition_fees_course_or_module?: "9790",
                        have_you_studied_before?: "yes",
                        will_you_attend_in_person?: "no"
        end

        should "render the question" do
          assert_rendered_question
        end

        context "next_node" do
          should "have a next node of where_will_you_live_while_studying_lle? for yes response" do
            assert_next_node :where_will_you_live_while_studying_lle?, for_response: "yes"
          end

          should "have a next node of do_any_of_the_following_apply_distance_learner? for no response" do
            assert_next_node :do_any_of_the_following_apply_distance_learner?, for_response: "no"
          end
        end
      end

      context "question: where_will_you_live_while_studying_lle?" do
        setup do
          testing_node :where_will_you_live_while_studying_lle?
          add_responses when_does_your_course_start?: "2027-2028",
                        what_age_are_you_on_first_day_of_course?: "under-60",
                        how_are_you_planning_to_study?: "full-time",
                        how_many_credits_will_you_study_course_module?: "120",
                        how_much_are_your_tuition_fees_course_or_module?: "9790",
                        have_you_studied_before?: "yes",
                        will_you_attend_in_person?: "yes"
        end

        should "render the question" do
          assert_rendered_question
        end

        context "next_node" do
          context "full-time students at 120 credits" do
            %w[at-home away-outside-london away-in-london living-overseas].each do |response|
              should "have a next node of do_any_of_the_following_apply_uk_120_credits_or_above? for #{response} response" do
                assert_next_node :do_any_of_the_following_apply_uk_120_credits_or_above?, for_response: response
              end
            end
          end

          context "full-time students below 120 credits" do
            setup do
              add_responses how_many_credits_will_you_study_course_module?: "60",
                            how_much_are_your_tuition_fees_course_or_module?: "4895"
            end
            %w[at-home away-outside-london away-in-london living-overseas].each do |response|
              should "have a next node of do_any_of_the_following_apply_all_uk_students? for #{response} response" do
                assert_next_node :do_any_of_the_following_apply_all_uk_students?, for_response: response
              end
            end
          end

          context "part-time students under 120 credits" do
            setup do
              add_responses how_are_you_planning_to_study?: "part-time",
                            how_many_credits_will_you_study_course_module?: "60",
                            how_many_credits_fte_course_or_module?: "120",
                            how_much_are_your_tuition_fees_course_or_module?: "4500"
            end

            %w[at-home away-outside-london away-in-london living-overseas].each do |response|
              should "have a next node of do_any_of_the_following_apply_all_uk_students? for #{response} response" do
                assert_next_node :do_any_of_the_following_apply_all_uk_students?, for_response: response
              end
            end
          end

          context "part-time students at 120 credits" do
            setup do
              add_responses how_are_you_planning_to_study?: "part-time",
                            how_many_credits_will_you_study_course_module?: "120",
                            how_many_credits_fte_course_or_module?: "180",
                            how_much_are_your_tuition_fees_course_or_module?: "9600"
            end

            %w[at-home away-outside-london away-in-london living-overseas].each do |response|
              should "have a next node of do_any_of_the_following_apply_uk_120_credits_or_above? for #{response} response" do
                assert_next_node :do_any_of_the_following_apply_uk_120_credits_or_above?, for_response: response
              end
            end
          end
        end
      end

      context "question: do_any_of_the_following_apply_uk_120_credits_or_above?" do
        setup do
          testing_node :do_any_of_the_following_apply_uk_120_credits_or_above?
          add_responses when_does_your_course_start?: "2027-2028",
                        what_age_are_you_on_first_day_of_course?: "under-60",
                        how_are_you_planning_to_study?: "full-time",
                        how_many_credits_will_you_study_course_module?: "120",
                        how_much_are_your_tuition_fees_course_or_module?: "9790",
                        have_you_studied_before?: "yes",
                        will_you_attend_in_person?: "yes",
                        where_will_you_live_while_studying_lle?: "at-home"
        end

        should "render the question" do
          assert_rendered_question
        end

        context "next_node" do
          %w[dependant-adult has-disability low-income no].each do |response|
            should "have a next node of whats_your_household_income? when #{response} and not a care leaver" do
              assert_next_node :whats_your_household_income?, for_response: response
            end
          end

          should "have a next node of are_you_studying_one_of_these_courses? when a care leaver" do
            assert_next_node :are_you_studying_one_of_these_courses?, for_response: "care-leaver"
          end

          should "have a next node of whats_your_household_income? when a care leaver and has a dependant adult" do
            assert_next_node :whats_your_household_income?, for_response: %w[care-leaver dependant-adult]
          end

          should "have a next node of whats_your_household_income? when a care leaver and has children under 17" do
            assert_next_node :whats_your_household_income?, for_response: %w[care-leaver children-under-17]
          end
        end
      end

      context "question: do_any_of_the_following_apply_all_uk_students?" do
        setup do
          testing_node :do_any_of_the_following_apply_all_uk_students?
          add_responses when_does_your_course_start?: "2027-2028",
                        what_age_are_you_on_first_day_of_course?: "under-60",
                        how_are_you_planning_to_study?: "part-time",
                        how_many_credits_will_you_study_course_module?: "60",
                        how_many_credits_fte_course_or_module?: "120",
                        how_much_are_your_tuition_fees_course_or_module?: "4500",
                        have_you_studied_before?: "yes",
                        will_you_attend_in_person?: "yes",
                        where_will_you_live_while_studying_lle?: "at-home"
        end

        should "render the question" do
          assert_rendered_question
        end

        context "next_node" do
          %w[has-disability low-income no].each do |response|
            should "have a next node of whats_your_household_income? when #{response} and not a care leaver" do
              assert_next_node :whats_your_household_income?, for_response: response
            end
          end

          should "have a next node of are_you_studying_one_of_these_courses? when a care leaver" do
            assert_next_node :are_you_studying_one_of_these_courses?, for_response: "care-leaver"
          end
        end
      end

      context "question: whats_your_household_income?" do
        setup do
          testing_node :whats_your_household_income?
          add_responses when_does_your_course_start?: "2027-2028",
                        what_age_are_you_on_first_day_of_course?: "under-60",
                        how_are_you_planning_to_study?: "full-time",
                        how_many_credits_will_you_study_course_module?: "120",
                        how_much_are_your_tuition_fees_course_or_module?: "9790",
                        have_you_studied_before?: "yes",
                        will_you_attend_in_person?: "yes",
                        where_will_you_live_while_studying_lle?: "at-home",
                        do_any_of_the_following_apply_uk_120_credits_or_above?: "no"
        end

        should "render the question" do
          assert_rendered_question
        end

        context "next_node" do
          should "have a next node of are_you_studying_one_of_these_courses?" do
            assert_next_node :are_you_studying_one_of_these_courses?, for_response: "25000"
          end
        end
      end

      context "question: do_any_of_the_following_apply_distance_learner?" do
        setup do
          testing_node :do_any_of_the_following_apply_distance_learner?
          add_responses when_does_your_course_start?: "2027-2028",
                        what_age_are_you_on_first_day_of_course?: "under-60",
                        how_are_you_planning_to_study?: "full-time",
                        how_many_credits_will_you_study_course_module?: "120",
                        how_much_are_your_tuition_fees_course_or_module?: "9790",
                        have_you_studied_before?: "yes",
                        will_you_attend_in_person?: "no",
                        are_you_unable_to_be_in_person_disability?: "no"
        end

        should "render the question" do
          assert_rendered_question
        end

        context "next_node" do
          %w[has-disability low-income no].each do |response|
            should "have a next node of are_you_studying_one_of_these_courses? for #{response} response" do
              assert_next_node :are_you_studying_one_of_these_courses?, for_response: response
            end
          end
        end
      end

      context "question: are_you_studying_one_of_these_courses?" do
        setup do
          testing_node :are_you_studying_one_of_these_courses?
          add_responses when_does_your_course_start?: "2027-2028",
                        what_age_are_you_on_first_day_of_course?: "under-60",
                        how_are_you_planning_to_study?: "full-time",
                        how_many_credits_will_you_study_course_module?: "120",
                        how_much_are_your_tuition_fees_course_or_module?: "9790",
                        have_you_studied_before?: "yes",
                        will_you_attend_in_person?: "yes",
                        where_will_you_live_while_studying_lle?: "at-home",
                        do_any_of_the_following_apply_uk_120_credits_or_above?: "no",
                        whats_your_household_income?: "25000"
        end

        should "render the question" do
          assert_rendered_question
        end

        context "next_node" do
          should "have a next node of is_your_course_eligible_nhs_bursary? for a dental-medical-healthcare response" do
            assert_next_node :is_your_course_eligible_nhs_bursary?, for_response: "dental-medical-healthcare"
          end

          %w[teacher-training social-work no].each do |response|
            should "have a next node of outcome_under_60_students for a #{response} response when attending in person" do
              assert_next_node :outcome_under_60_students, for_response: response
            end

            should "have a next node of outcome_under_60_students for a #{response} response when not attending in person due to disability" do
              add_responses will_you_attend_in_person?: "no",
                            are_you_unable_to_be_in_person_disability?: "yes",
                            where_will_you_live_while_studying_lle?: "at-home"
              assert_next_node :outcome_under_60_students, for_response: response
            end

            should "have a next node of outcome_under_60_distance_learner for a #{response} response when not attending in person" do
              add_responses will_you_attend_in_person?: "no",
                            are_you_unable_to_be_in_person_disability?: "no",
                            do_any_of_the_following_apply_distance_learner?: "no"
              assert_next_node :outcome_under_60_distance_learner, for_response: response
            end
          end
        end
      end

      context "question: is_your_course_eligible_nhs_bursary?" do
        setup do
          testing_node :is_your_course_eligible_nhs_bursary?
          add_responses when_does_your_course_start?: "2027-2028",
                        what_age_are_you_on_first_day_of_course?: "under-60",
                        how_are_you_planning_to_study?: "full-time",
                        how_many_credits_will_you_study_course_module?: "120",
                        how_much_are_your_tuition_fees_course_or_module?: "9790",
                        have_you_studied_before?: "yes",
                        will_you_attend_in_person?: "yes",
                        where_will_you_live_while_studying_lle?: "at-home",
                        do_any_of_the_following_apply_uk_120_credits_or_above?: "no",
                        whats_your_household_income?: "25000",
                        are_you_studying_one_of_these_courses?: "dental-medical-healthcare"
        end

        should "render the question" do
          assert_rendered_question
        end

        context "next_node" do
          %w[yes no].each do |response|
            should "have a next node of outcome_under_60_students for a #{response} response when attending in person" do
              assert_next_node :outcome_under_60_students, for_response: response
            end

            should "have a next node of outcome_under_60_students for a #{response} response when not attending in person due to disability" do
              add_responses will_you_attend_in_person?: "no",
                            are_you_unable_to_be_in_person_disability?: "yes",
                            where_will_you_live_while_studying_lle?: "at-home"
              assert_next_node :outcome_under_60_students, for_response: response
            end

            should "have a next node of outcome_under_60_distance_learner for a #{response} response when not attending in person" do
              add_responses will_you_attend_in_person?: "no",
                            are_you_unable_to_be_in_person_disability?: "no",
                            do_any_of_the_following_apply_distance_learner?: "no",
                            are_you_studying_one_of_these_courses?: "dental-medical-healthcare"
              assert_next_node :outcome_under_60_distance_learner, for_response: response
            end
          end
        end
      end

      context "outcome: outcome_under_60_students" do
        setup do
          testing_node :outcome_under_60_students
          add_responses when_does_your_course_start?: "2027-2028",
                        what_age_are_you_on_first_day_of_course?: "under-60",
                        how_are_you_planning_to_study?: "full-time",
                        how_many_credits_will_you_study_course_module?: "120",
                        how_much_are_your_tuition_fees_course_or_module?: "9790",
                        have_you_studied_before?: "no",
                        will_you_attend_in_person?: "yes",
                        where_will_you_live_while_studying_lle?: "at-home",
                        do_any_of_the_following_apply_uk_120_credits_or_above?: "low-income",
                        whats_your_household_income?: "25,000",
                        are_you_studying_one_of_these_courses?: "dental-medical-healthcare",
                        is_your_course_eligible_nhs_bursary?: "yes"
        end

        should "render the Tuition Fee Loan summary" do
          assert_rendered_outcome text: "Tuition Fee Loan"
        end

        should "render the Maintenance Loan summary" do
          assert_rendered_outcome text: "How your Maintenance Loan is calculated"
        end

        should "render NHS bursary signposting when the course is NHS-bursary eligible" do
          assert_rendered_outcome text: "NHS funding towards your fees and living costs"
        end

        should "not render NHS bursary signposting when the course is not NHS-bursary eligible" do
          add_responses is_your_course_eligible_nhs_bursary?: "no"
          assert_no_rendered_outcome text: "NHS funding towards your fees and living costs"
        end

        should "render the low-income (hardship funds) extra help" do
          assert_rendered_outcome text: "University and college hardship funds"
        end

        should "not show grants or allowances the student is not eligible for" do
          add_responses do_any_of_the_following_apply_uk_120_credits_or_above?: "no",
                        whats_your_household_income?: "60,000"
          ["a week for a single child",
           "Disabled Students",
           "Learning Allowance",
           "Adult Dependant",
           "University and college hardship funds"].each do |text|
            assert_no_rendered_outcome text:
          end
        end

        should "render the care-leaver Maintenance Loan text for a care leaver" do
          add_responses do_any_of_the_following_apply_uk_120_credits_or_above?: "care-leaver"
          assert_rendered_outcome text: "You can choose to borrow the maximum amount"
        end

        should "render the reduced healthcare Maintenance Loan for years 5 and 6 of a dental/medical course" do
          assert_rendered_outcome text: "reduced Maintenance Loan"
        end

        should "render the standard (non-dental) Maintenance Loan final-year text" do
          add_responses are_you_studying_one_of_these_courses?: "teacher-training"
          assert_rendered_outcome text: "You may get less Maintenance Loan in your final year"
        end

        should "render the studied-before Tuition Fee Loan note when the student has studied before" do
          add_responses have_you_studied_before?: "yes"
          assert_rendered_outcome text: "your loan might be less"
        end

        should "render Childcare Grant for one child for a low-income student with children" do
          add_responses do_any_of_the_following_apply_uk_120_credits_or_above?: "children-under-17",
                        whats_your_household_income?: "15,000"
          assert_rendered_outcome text: "a week for a single child"
        end

        should "render Childcare Grant for more than one child at a higher income" do
          add_responses do_any_of_the_following_apply_uk_120_credits_or_above?: "children-under-17",
                        whats_your_household_income?: "25,000"
          assert_rendered_outcome text: "if you have 2 or more children"
        end

        should "render Parents' Learning Allowance for a low-income student with children" do
          add_responses do_any_of_the_following_apply_uk_120_credits_or_above?: "children-under-17",
                        whats_your_household_income?: "18,000"
          assert_rendered_outcome text: "Learning Allowance"
        end

        should "render Adult Dependant's Grant for a low-income student with an adult dependant" do
          add_responses do_any_of_the_following_apply_uk_120_credits_or_above?: "dependant-adult",
                        whats_your_household_income?: "15,000"
          assert_rendered_outcome text: "Adult Dependant"
        end

        should "render Disabled Students' Allowance when the student has a disability" do
          add_responses do_any_of_the_following_apply_uk_120_credits_or_above?: "has-disability"
          assert_rendered_outcome text: "Disabled Students"
        end

        should "render teacher training funding signposting for a teacher training course" do
          add_responses are_you_studying_one_of_these_courses?: "teacher-training"
          assert_rendered_outcome text: "funding for teacher training"
        end

        should "render Social Work Bursary signposting for a social work course" do
          add_responses are_you_studying_one_of_these_courses?: "social-work"
          assert_rendered_outcome text: "Social Work Bursary"
        end

        should "not show the not-in-person message when unable to attend due to disability" do
          add_responses are_you_unable_to_be_in_person_disability?: "yes",
                        where_will_you_live_while_studying_lle?: "at-home",
                        do_any_of_the_following_apply_uk_120_credits_or_above?: "no",
                        whats_your_household_income?: "25,000"
          assert_no_rendered_outcome text: "Because you are not attending the course in person"
        end
      end

      context "outcome: outcome_under_60_distance_learner" do
        setup do
          testing_node :outcome_under_60_distance_learner
          add_responses when_does_your_course_start?: "2027-2028",
                        what_age_are_you_on_first_day_of_course?: "under-60",
                        how_are_you_planning_to_study?: "full-time",
                        how_many_credits_will_you_study_course_module?: "120",
                        how_much_are_your_tuition_fees_course_or_module?: "4500",
                        have_you_studied_before?: "no",
                        will_you_attend_in_person?: "no",
                        are_you_unable_to_be_in_person_disability?: "no",
                        do_any_of_the_following_apply_distance_learner?: "no",
                        are_you_studying_one_of_these_courses?: "no"
        end

        should "render the Tuition Fee Loan summary" do
          assert_rendered_outcome text: "Tuition Fee Loan"
        end

        should "explain that a non-in-person student is not eligible for a Maintenance Loan" do
          assert_rendered_outcome text: "Because you are not attending the course in person, you are not eligible for a Maintenance Loan"
        end

        should "not render the Maintenance Loan calculation breakdown" do
          assert_no_rendered_outcome text: "How your Maintenance Loan is calculated"
        end

        should "render the low-income (hardship funds) extra help for a distance learner" do
          add_responses do_any_of_the_following_apply_distance_learner?: "low-income"
          assert_rendered_outcome text: "University and college hardship funds"
        end
      end
    end

    context "when over 60" do
      context "question: are_you_studying_one_of_these_courses?" do
        setup do
          testing_node :are_you_studying_one_of_these_courses?
          add_responses when_does_your_course_start?: "2027-2028",
                        what_age_are_you_on_first_day_of_course?: "60-or-more"
        end

        should "render the question" do
          assert_rendered_question
        end

        context "next_node" do
          should "have a next node of is_your_course_eligible_nhs_bursary? for a dental-medical-healthcare response" do
            assert_next_node :is_your_course_eligible_nhs_bursary?, for_response: "dental-medical-healthcare"
          end

          %w[teacher-training social-work no].each do |response|
            should "have a next node of how_are_you_planning_to_study for a #{response} response" do
              assert_next_node :how_are_you_planning_to_study?, for_response: response
            end
          end
        end
      end

      context "question: is_your_course_eligible_nhs_bursary?" do
        setup do
          testing_node :is_your_course_eligible_nhs_bursary?
          add_responses when_does_your_course_start?: "2027-2028",
                        what_age_are_you_on_first_day_of_course?: "60-or-more",
                        are_you_studying_one_of_these_courses?: "dental-medical-healthcare"
        end

        should "render the question" do
          assert_rendered_question
        end

        context "next_node" do
          %w[yes no].each do |response|
            should "have a next node of how_are_you_planning_to_study for a #{response} response" do
              assert_next_node :how_are_you_planning_to_study?, for_response: response
            end
          end
        end
      end

      context "question: how_are_you_planning_to_study?" do
        setup do
          testing_node :how_are_you_planning_to_study?
          add_responses when_does_your_course_start?: "2027-2028",
                        what_age_are_you_on_first_day_of_course?: "60-or-more",
                        are_you_studying_one_of_these_courses?: "dental-medical-healthcare",
                        is_your_course_eligible_nhs_bursary?: "yes"
        end

        should "render the question" do
          assert_rendered_question
        end

        context "next_node" do
          %w[full-time part-time].each do |response|
            should "have a next node of how_many_credits_will_you_study_course_module? for #{response} response" do
              assert_next_node :how_many_credits_will_you_study_course_module?, for_response: response
            end
          end
        end
      end

      context "question: how_many_credits_will_you_study_course_module?" do
        setup do
          testing_node :how_many_credits_will_you_study_course_module?
          add_responses when_does_your_course_start?: "2027-2028",
                        what_age_are_you_on_first_day_of_course?: "60-or-more",
                        are_you_studying_one_of_these_courses?: "dental-medical-healthcare",
                        is_your_course_eligible_nhs_bursary?: "yes",
                        how_are_you_planning_to_study?: "full-time"
        end

        should "render the question" do
          assert_rendered_question
        end

        context "validation" do
          should "be invalid below 30 credits" do
            assert_invalid_response "29"
          end

          should "be invalid above 180 credits" do
            assert_invalid_response "181"
          end

          should "be invalid if the number of credits entered is not a whole number" do
            assert_invalid_response "100.1"
          end

          should "be valid between 30 and 180 credits" do
            assert_valid_response "100"
          end
        end

        context "next_node" do
          should "have a next node of will_you_attend_in_person? for a full-time student" do
            assert_next_node :will_you_attend_in_person?, for_response: "120"
          end

          should "have a next node of how_many_credits_fte_course_or_module? for a part-time student" do
            add_responses how_are_you_planning_to_study?: "part-time"
            assert_next_node :how_many_credits_fte_course_or_module?, for_response: "60"
          end
        end
      end

      context "question: how_many_credits_fte_course_or_module?" do
        setup do
          testing_node :how_many_credits_fte_course_or_module?
          add_responses when_does_your_course_start?: "2027-2028",
                        what_age_are_you_on_first_day_of_course?: "60-or-more",
                        are_you_studying_one_of_these_courses?: "dental-medical-healthcare",
                        is_your_course_eligible_nhs_bursary?: "yes",
                        how_are_you_planning_to_study?: "part-time",
                        how_many_credits_will_you_study_course_module?: "60"
        end

        should "render the question" do
          assert_rendered_question
        end

        context "validation" do
          should "be invalid below part-time credits" do
            assert_invalid_response "59"
          end

          should "be invalid above 180 credits" do
            assert_invalid_response "181"
          end

          should "be invalid if the number of credits entered is not a whole number" do
            assert_invalid_response "100.1"
          end

          should "be valid between part-time credits and 180 credits" do
            assert_valid_response "100"
          end
        end

        context "next_node" do
          should "have a next node of will_you_attend_in_person?" do
            assert_next_node :will_you_attend_in_person?, for_response: "120"
          end
        end
      end

      context "question: will_you_attend_in_person?" do
        setup do
          testing_node :will_you_attend_in_person?
          add_responses when_does_your_course_start?: "2027-2028",
                        what_age_are_you_on_first_day_of_course?: "60-or-more",
                        are_you_studying_one_of_these_courses?: "dental-medical-healthcare",
                        is_your_course_eligible_nhs_bursary?: "yes",
                        how_are_you_planning_to_study?: "full-time",
                        how_many_credits_will_you_study_course_module?: "120"
        end

        should "render the question" do
          assert_rendered_question
        end

        context "next_node" do
          should "have a next node of do_any_of_the_following_apply_all_uk_students? for yes response with < 120 credits" do
            add_responses how_many_credits_will_you_study_course_module?: "90"

            assert_next_node :do_any_of_the_following_apply_all_uk_students?, for_response: "yes"
          end

          should "have a next node of do_any_of_the_following_apply_uk_120_credits_or_above? for yes response with >= 120 credits" do
            assert_next_node :do_any_of_the_following_apply_uk_120_credits_or_above?, for_response: "yes"
          end

          should "have a next node of are_you_unable_to_be_in_person_disability? for no response" do
            assert_next_node :are_you_unable_to_be_in_person_disability?, for_response: "no"
          end
        end
      end

      context "question: are_you_unable_to_be_in_person_disability?" do
        setup do
          testing_node :are_you_unable_to_be_in_person_disability?
          add_responses when_does_your_course_start?: "2027-2028",
                        what_age_are_you_on_first_day_of_course?: "60-or-more",
                        are_you_studying_one_of_these_courses?: "dental-medical-healthcare",
                        is_your_course_eligible_nhs_bursary?: "yes",
                        how_are_you_planning_to_study?: "full-time",
                        how_many_credits_will_you_study_course_module?: "120",
                        will_you_attend_in_person?: "no"
        end

        should "render the question" do
          assert_rendered_question
        end

        context "next_node" do
          should "have a next node of do_any_of_the_following_apply_all_uk_students? for yes response with < 120 credits" do
            add_responses how_many_credits_will_you_study_course_module?: "90"

            assert_next_node :do_any_of_the_following_apply_all_uk_students?, for_response: "yes"
          end

          should "have a next node of do_any_of_the_following_apply_uk_120_credits_or_above? for yes response with >= 120 credits" do
            assert_next_node :do_any_of_the_following_apply_uk_120_credits_or_above?, for_response: "yes"
          end

          should "have a next node of do_any_of_the_following_apply_distance_learner? for no response" do
            assert_next_node :do_any_of_the_following_apply_distance_learner?, for_response: "no"
          end
        end
      end

      context "question: do_any_of_the_following_apply_all_uk_students?" do
        setup do
          testing_node :do_any_of_the_following_apply_all_uk_students?
          add_responses when_does_your_course_start?: "2027-2028",
                        what_age_are_you_on_first_day_of_course?: "60-or-more",
                        are_you_studying_one_of_these_courses?: "dental-medical-healthcare",
                        is_your_course_eligible_nhs_bursary?: "yes",
                        how_are_you_planning_to_study?: "full-time",
                        how_many_credits_will_you_study_course_module?: "60",
                        will_you_attend_in_person?: "yes"
        end

        should "render the question" do
          assert_rendered_question
        end

        context "next_node" do
          %w[has-disability low-income no].each do |response|
            should "have a next node of whats_your_household_income? for anyone not a care leaver and #{response} response" do
              assert_next_node :whats_your_household_income?, for_response: response
            end
          end
        end

        context "next_node" do
          should "have a next node of outcome_over_60_students for care leaver" do
            assert_next_node :outcome_over_60_students, for_response: "care-leaver"
          end
        end
      end

      context "question: do_any_of_the_following_apply_distance_learner?" do
        setup do
          testing_node :do_any_of_the_following_apply_distance_learner?
          add_responses when_does_your_course_start?: "2027-2028",
                        what_age_are_you_on_first_day_of_course?: "60-or-more",
                        are_you_studying_one_of_these_courses?: "dental-medical-healthcare",
                        is_your_course_eligible_nhs_bursary?: "yes",
                        how_are_you_planning_to_study?: "full-time",
                        how_many_credits_will_you_study_course_module?: "120",
                        will_you_attend_in_person?: "no",
                        are_you_unable_to_be_in_person_disability?: "no"
        end

        should "render the question" do
          assert_rendered_question
        end

        context "next_node" do
          %w[has-disability low-income no].each do |response|
            should "have a next node of outcome_over_60_distance_learner? for #{response} response" do
              assert_next_node :outcome_over_60_distance_learner, for_response: response
            end
          end
        end
      end

      context "question: whats_your_household_income?," do
        setup do
          testing_node :whats_your_household_income?
          add_responses when_does_your_course_start?: "2027-2028",
                        what_age_are_you_on_first_day_of_course?: "60-or-more",
                        are_you_studying_one_of_these_courses?: "dental-medical-healthcare",
                        is_your_course_eligible_nhs_bursary?: "yes",
                        how_are_you_planning_to_study?: "full-time",
                        how_many_credits_will_you_study_course_module?: "60",
                        will_you_attend_in_person?: "yes",
                        do_any_of_the_following_apply_all_uk_students?: "has-disability"
        end

        should "render the question" do
          assert_rendered_question
        end

        context "next_node" do
          should "have a next node outcome_over_60_students?" do
            assert_next_node :outcome_over_60_students, for_response: "50,000"
          end
        end
      end

      context "outcome: outcome_over_60_students" do
        setup do
          testing_node :outcome_over_60_students
          add_responses when_does_your_course_start?: "2027-2028",
                        what_age_are_you_on_first_day_of_course?: "60-or-more",
                        are_you_studying_one_of_these_courses?: "dental-medical-healthcare",
                        is_your_course_eligible_nhs_bursary?: "yes",
                        how_are_you_planning_to_study?: "full-time",
                        how_many_credits_will_you_study_course_module?: "120",
                        will_you_attend_in_person?: "yes",
                        do_any_of_the_following_apply_uk_120_credits_or_above?: "no",
                        whats_your_household_income?: "27,000"
        end

        should "render Special Support loan when the course is in person" do
          assert_rendered_outcome text: "You could get a Special Support loan of "
        end

        should "render Special Support loan when the course is in person and the student makes over 50_000" do
          add_responses whats_your_household_income?: "50,000"
          assert_rendered_outcome text: "You are not eligible for any loans."
        end

        should "render NHS bursary signposting when the course is NHS-bursary eligible" do
          assert_rendered_outcome text: "NHS funding towards your fees and living costs"
        end

        should "not render NHS bursary signposting when the course is not NHS-bursary eligible" do
          add_responses is_your_course_eligible_nhs_bursary?: "no"
          assert_no_rendered_outcome text: "NHS funding towards your fees and living costs"
        end

        should "render the low-income (hardship funds) extra help" do
          assert_rendered_outcome text: "You could get a bursary, scholarship or financial hardship funding from your university or college."
        end

        should "not show grants or allowances the student is not eligible for" do
          add_responses do_any_of_the_following_apply_uk_120_credits_or_above?: "no",
                        whats_your_household_income?: "60,000"
          ["a week for a single child",
           "Disabled Students",
           "Learning Allowance",
           "Adult Dependant",
           "University and college hardship funds"].each do |text|
            assert_no_rendered_outcome text:
          end
        end

        should "render Childcare Grant for one child for a low-income student with children" do
          add_responses do_any_of_the_following_apply_uk_120_credits_or_above?: "children-under-17",
                        whats_your_household_income?: "15,000"
          assert_rendered_outcome text: "a week for a single child"
        end

        should "render Childcare Grant for more than one child at a higher income" do
          add_responses do_any_of_the_following_apply_uk_120_credits_or_above?: "children-under-17",
                        whats_your_household_income?: "25,000"
          assert_rendered_outcome text: "if you have 2 or more children"
        end

        should "render Parents' Learning Allowance for a low-income student with children" do
          add_responses do_any_of_the_following_apply_uk_120_credits_or_above?: "children-under-17",
                        whats_your_household_income?: "18,000"
          assert_rendered_outcome text: "Learning Allowance"
        end

        should "render Adult Dependant's Grant for a low-income student with an adult dependant" do
          add_responses do_any_of_the_following_apply_uk_120_credits_or_above?: "dependant-adult",
                        whats_your_household_income?: "15,000"
          assert_rendered_outcome text: "Adult Dependant"
        end

        should "render Disabled Students' Allowance when the student has a disability" do
          add_responses do_any_of_the_following_apply_uk_120_credits_or_above?: "has-disability"
          assert_rendered_outcome text: "Disabled Students"
        end

        should "render University and college hardship funds when the student has a low income" do
          add_responses do_any_of_the_following_apply_uk_120_credits_or_above?: "low-income"
          assert_rendered_outcome text: "University and college hardship funds"
        end

        should "render teacher training funding signposting for a teacher training course" do
          add_responses are_you_studying_one_of_these_courses?: "teacher-training"
          assert_rendered_outcome text: "funding for teacher training"
        end

        should "render Social Work Bursary signposting for a social work course" do
          add_responses are_you_studying_one_of_these_courses?: "social-work"
          assert_rendered_outcome text: "Social Work Bursary"
        end
      end

      context "outcome: outcome_over_60_distance_learner" do
        setup do
          testing_node :outcome_over_60_distance_learner
          add_responses when_does_your_course_start?: "2027-2028",
                        what_age_are_you_on_first_day_of_course?: "60-or-more",
                        are_you_studying_one_of_these_courses?: "dental-medical-healthcare",
                        is_your_course_eligible_nhs_bursary?: "yes",
                        how_are_you_planning_to_study?: "full-time",
                        how_many_credits_will_you_study_course_module?: "120",
                        will_you_attend_in_person?: "no",
                        are_you_unable_to_be_in_person_disability?: "no",
                        do_any_of_the_following_apply_distance_learner?: "no"
        end

        should "render not eligible for loans when distance learning" do
          assert_rendered_outcome text: "You are not eligible for any loans."
        end

        should "render not eligible for loans when distance learning and disabled" do
          add_responses do_any_of_the_following_apply_distance_learner?: "has-disability"
          assert_rendered_outcome text: "You are not eligible for any loans."
        end

        should "render NHS bursary signposting when the course is NHS-bursary eligible" do
          assert_rendered_outcome text: "NHS funding towards your fees and living costs"
        end

        should "not render NHS bursary signposting when the course is not NHS-bursary eligible" do
          add_responses is_your_course_eligible_nhs_bursary?: "no"
          assert_no_rendered_outcome text: "NHS funding towards your fees and living costs"
        end

        should "render the low-income (hardship funds) extra help" do
          assert_rendered_outcome text: "You could get a bursary, scholarship or financial hardship funding from your university or college."
        end

        should "not show grants or allowances the student is not eligible for" do
          add_responses do_any_of_the_following_apply_distance_learner?: "no",
                        whats_your_household_income?: "60,000"
          ["a week for a single child",
           "Disabled Students",
           "Learning Allowance",
           "Adult Dependant",
           "University and college hardship funds"].each do |text|
            assert_no_rendered_outcome text:
          end
        end

        should "render Disabled Students' Allowance when the student has a disability" do
          add_responses do_any_of_the_following_apply_distance_learner?: "has-disability"
          assert_rendered_outcome text: "Disabled Students"
        end

        should "render University and college hardship funds when the student has a low income" do
          add_responses do_any_of_the_following_apply_distance_learner?: "low-income"
          assert_rendered_outcome text: "University and college hardship funds"
        end

        should "render teacher training funding signposting for a teacher training course" do
          add_responses are_you_studying_one_of_these_courses?: "teacher-training"
          assert_rendered_outcome text: "funding for teacher training"
        end

        should "render Social Work Bursary signposting for a social work course" do
          add_responses are_you_studying_one_of_these_courses?: "social-work"
          assert_rendered_outcome text: "Social Work Bursary"
        end
      end
    end
  end
end
