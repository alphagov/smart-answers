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
      should "have a next node of what_type_of_student_are_you? for any response" do
        assert_next_node :what_type_of_student_are_you?, for_response: "2023-2024"
      end
    end
  end

  context "question: what_type_of_student_are_you?," do
    setup do
      testing_node :what_type_of_student_are_you?
      add_responses when_does_your_course_start?: "2023-2024"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node of how_much_are_your_tuition_fees_per_year? for any response" do
        assert_next_node :how_much_are_your_tuition_fees_per_year?, for_response: "uk-full-time"
      end
    end
  end

  context "question: how_much_are_your_tuition_fees_per_year?," do
    setup do
      testing_node :how_much_are_your_tuition_fees_per_year?
      add_responses when_does_your_course_start?: "2023-2024",
                    what_type_of_student_are_you?: "uk-full-time"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "validation" do
      %w[uk-full-time eu-full-time].each do |full_time_student_type|
        should "be invalid for a fee greater than the maximum for a #{full_time_student_type} student" do
          add_responses what_type_of_student_are_you?: full_time_student_type
          max_for_full_time = SmartAnswer::Calculators::StudentFinanceCalculator::TUITION_FEE_MAXIMUM["full-time"]
          assert_invalid_response (max_for_full_time + 1).to_s
        end
      end

      %w[uk-part-time eu-part-time].each do |part_time_student_type|
        should "be invalid for a fee greater than the maximum for a #{part_time_student_type} student" do
          add_responses what_type_of_student_are_you?: part_time_student_type
          max_for_part_time = SmartAnswer::Calculators::StudentFinanceCalculator::TUITION_FEE_MAXIMUM["part-time"]
          assert_invalid_response (max_for_part_time + 1).to_s
        end
      end
    end

    context "next_node" do
      %w[uk-full-time uk-part-time].each do |uk_student_type|
        should "have a next node of where_will_you_live_while_studying? for a #{uk_student_type} student" do
          add_responses what_type_of_student_are_you?: uk_student_type
          assert_next_node :where_will_you_live_while_studying?, for_response: "5000"
        end
      end

      %w[eu-full-time eu-part-time].each do |eu_student_type|
        should "have a next node of outcome_tuition_fee_only for a #{eu_student_type} student" do
          add_responses what_type_of_student_are_you?: eu_student_type
          assert_next_node :outcome_tuition_fee_only, for_response: "5000"
        end
      end
    end
  end

  context "question: where_will_you_live_while_studying?," do
    setup do
      testing_node :where_will_you_live_while_studying?
      add_responses when_does_your_course_start?: "2023-2024",
                    what_type_of_student_are_you?: "uk-full-time",
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
      add_responses when_does_your_course_start?: "2023-2024",
                    what_type_of_student_are_you?: "uk-full-time",
                    how_much_are_your_tuition_fees_per_year?: "6935",
                    where_will_you_live_while_studying?: "at-home"
    end

    should "render the question" do
      assert_rendered_question
    end

    context "next_node" do
      should "have a next node do_any_of_the_following_apply_uk_full_time_students_only? for full time students" do
        assert_next_node :do_any_of_the_following_apply_uk_full_time_students_only?, for_response: "50,000"
      end

      should "have a next node of how_many_credits_will_you_study? for part time students" do
        add_responses what_type_of_student_are_you?: "uk-part-time"

        assert_next_node :how_many_credits_will_you_study?, for_response: "50,000"
      end
    end
  end

  context "question: how_many_credits_will_you_study?" do
    setup do
      testing_node :how_many_credits_will_you_study?
      add_responses when_does_your_course_start?: "2023-2024",
                    what_type_of_student_are_you?: "uk-part-time",
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
      add_responses when_does_your_course_start?: "2023-2024",
                    what_type_of_student_are_you?: "uk-part-time",
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
    end

    context "next_node" do
      should "have a next node of do_any_of_the_following_apply_all_uk_students for a response that is greater than the number of part-time credits?" do
        assert_next_node :do_any_of_the_following_apply_all_uk_students?, for_response: "11"
      end
    end
  end

  context "question: do_any_of_the_following_apply_uk_full_time_students_only?," do
    setup do
      testing_node :do_any_of_the_following_apply_uk_full_time_students_only?
      add_responses when_does_your_course_start?: "2023-2024",
                    what_type_of_student_are_you?: "uk-full-time",
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
      add_responses when_does_your_course_start?: "2023-2024",
                    what_type_of_student_are_you?: "uk-part-time",
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
      add_responses when_does_your_course_start?: "2023-2024",
                    what_type_of_student_are_you?: "uk-full-time",
                    how_much_are_your_tuition_fees_per_year?: "6935",
                    where_will_you_live_while_studying?: "at-home",
                    whats_your_household_income?: "50,000",
                    do_any_of_the_following_apply_uk_full_time_students_only?: "children-under-17"
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
        add_responses what_type_of_student_are_you?: "uk-part-time",
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
      add_responses when_does_your_course_start?: "2023-2024",
                    what_type_of_student_are_you?: "uk-full-time",
                    how_much_are_your_tuition_fees_per_year?: "9250",
                    where_will_you_live_while_studying?: "at-home",
                    whats_your_household_income?: "50,000",
                    do_any_of_the_following_apply_uk_full_time_students_only?: "children-under-17",
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
      add_responses when_does_your_course_start?: "2023-2024",
                    what_type_of_student_are_you?: "uk-full-time",
                    how_much_are_your_tuition_fees_per_year?: "9250",
                    where_will_you_live_while_studying?: "at-home",
                    whats_your_household_income?: "50,000",
                    do_any_of_the_following_apply_uk_full_time_students_only?: "children-under-17",
                    what_course_are_you_studying?: "teacher-training"
    end

    should "render text for when the student is not eligible for extra grants and allowances" do
      add_responses do_any_of_the_following_apply_uk_full_time_students_only?: "no",
                    what_course_are_you_studying?: "none-of-the-above"

      assert_rendered_outcome text: "You don’t qualify for extra grants and allowances"
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

    should "render text for child tax credit when the student has a child under 17" do
      assert_rendered_outcome text: "Child Tax Credit"
    end

    should "render text for when the student is eligible for an adult dependant's grant" do
      add_responses whats_your_household_income?: "15,000",
                    do_any_of_the_following_apply_uk_full_time_students_only?: "dependant-adult"

      assert_rendered_outcome text: "Adult Dependant’s Grant"
    end

    should "render text if student has a disability" do
      add_responses do_any_of_the_following_apply_uk_full_time_students_only?: "has-disability"

      assert_rendered_outcome text: "Disabled Students’ Allowance"
    end

    should "render text if student has low income" do
      add_responses do_any_of_the_following_apply_uk_full_time_students_only?: "low-income"

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
  end

  context "outcome: outcome_uk_part_time_students" do
    setup do
      testing_node :outcome_uk_part_time_students
      add_responses when_does_your_course_start?: "2023-2024",
                    what_type_of_student_are_you?: "uk-part-time",
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

      assert_rendered_outcome text: "You don’t qualify for extra grants and allowances"
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
  end

  context "outcome: outcome_uk_full_time_dental_medical_students" do
    setup do
      testing_node :outcome_uk_full_time_dental_medical_students
      add_responses when_does_your_course_start?: "2023-2024",
                    what_type_of_student_are_you?: "uk-full-time",
                    how_much_are_your_tuition_fees_per_year?: "9250",
                    where_will_you_live_while_studying?: "at-home",
                    whats_your_household_income?: "50,000",
                    do_any_of_the_following_apply_uk_full_time_students_only?: "children-under-17",
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
                    do_any_of_the_following_apply_uk_full_time_students_only?: "dependant-adult"

      assert_rendered_outcome text: "Adult Dependant’s Grant"
    end

    should "render text if student has a disability" do
      add_responses do_any_of_the_following_apply_uk_full_time_students_only?: "has-disability"

      assert_rendered_outcome text: "Disabled Students’ Allowance"
    end

    should "render text if student has children under 17" do
      assert_rendered_outcome text: "Childcare Allowance"
    end

    should "render text if student has adult dependenants" do
      add_responses do_any_of_the_following_apply_uk_full_time_students_only?: "dependant-adult"

      assert_rendered_outcome text: "Dependants’ Allowance"
    end

    should "render text for child tax credit when the student has a child under 17" do
      assert_rendered_outcome text: "Child Tax Credit"
    end

    should "render text if student has low income" do
      add_responses do_any_of_the_following_apply_uk_full_time_students_only?: "low-income"

      assert_rendered_outcome text: "University and college hardship funds"
    end
  end
end
