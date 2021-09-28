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
        assert_next_node :what_type_of_student_are_you?, for_response: "2020-2021"
      end
    end
  end

  context "question: what_type_of_student_are_you?," do
    setup do
      testing_node :what_type_of_student_are_you?
      add_responses when_does_your_course_start?: "2020-2021"
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

  context "UK full time students" do
    context "question: how_much_are_your_tuition_fees_per_year?," do
      setup do
        testing_node :how_much_are_your_tuition_fees_per_year?
        add_responses when_does_your_course_start?: "2020-2021",
                      what_type_of_student_are_you?: "uk-full-time"
      end

      should "render the question" do
        assert_rendered_question
      end

      context "validation" do
        should "be invalid if a fee over 9250 is entered for full time students" do
          assert_invalid_response "9251"
        end
      end

      context "next_node" do
        should "have a next node of where_will_you_live_while_studying?" do
          assert_next_node :where_will_you_live_while_studying?, for_response: "9250"
        end
      end
    end

    context "question: where_will_you_live_while_studying?," do
      setup do
        testing_node :where_will_you_live_while_studying?
        add_responses when_does_your_course_start?: "2020-2021",
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
        add_responses when_does_your_course_start?: "2020-2021",
                      what_type_of_student_are_you?: "uk-full-time",
                      how_much_are_your_tuition_fees_per_year?: "9250",
                      where_will_you_live_while_studying?: "at-home"
      end

      should "render the question" do
        assert_rendered_question
      end

      context "next_node" do
        should "have a next node do_any_of_the_following_apply_uk_full_time_students_only? for any response" do
          assert_next_node :do_any_of_the_following_apply_uk_full_time_students_only?, for_response: "50,000"
        end
      end
    end

    context "question: do_any_of_the_following_apply_uk_full_time_students_only?," do
      setup do
        testing_node :do_any_of_the_following_apply_uk_full_time_students_only?
        add_responses when_does_your_course_start?: "2020-2021",
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
          assert_next_node :what_course_are_you_studying?, for_response: "children-under-17,dependant-adult,has-disability,low-income"
        end
      end
    end

    context "question: what_course_are_you_studying?," do
      setup do
        testing_node :what_course_are_you_studying?
        add_responses when_does_your_course_start?: "2020-2021",
                      what_type_of_student_are_you?: "uk-full-time",
                      how_much_are_your_tuition_fees_per_year?: "9250",
                      where_will_you_live_while_studying?: "at-home",
                      whats_your_household_income?: "50,000",
                      do_any_of_the_following_apply_uk_full_time_students_only?: "children-under-17,dependant-adult,has-disability,low-income"
      end

      should "render the question" do
        assert_rendered_question
      end

      context "next_node" do
        should "have a next node of outcome_uk_full_time_students for any of the non-medical responses" do
          assert_next_node :outcome_uk_full_time_students, for_response: "teacher-training"
        end

        should "have a next node of are_you_a_doctor_or_dentist? for the medical response" do
          assert_next_node :are_you_a_doctor_or_dentist?, for_response: "dental-medical-healthcare"
        end
      end
    end

    context "question: are_you_a_doctor_or_dentist?," do
      setup do
        testing_node :are_you_a_doctor_or_dentist?
        add_responses when_does_your_course_start?: "2020-2021",
                      what_type_of_student_are_you?: "uk-full-time",
                      how_much_are_your_tuition_fees_per_year?: "9250",
                      where_will_you_live_while_studying?: "at-home",
                      whats_your_household_income?: "50,000",
                      do_any_of_the_following_apply_uk_full_time_students_only?: "children-under-17,dependant-adult,has-disability,low-income",
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
  end

  context "UK part time students" do
    context "question: how_much_are_your_tuition_fees_per_year?," do
      setup do
        testing_node :how_much_are_your_tuition_fees_per_year?
        add_responses when_does_your_course_start?: "2020-2021",
                      what_type_of_student_are_you?: "uk-part-time"
      end

      should "render the question" do
        assert_rendered_question
      end

      context "validation" do
        should "be invalid if a fee over 6935 is entered for part time students" do
          assert_invalid_response "6936"
        end
      end

      context "next_node" do
        should "have a next node of where_will_you_live_while_studying?" do
          assert_next_node :where_will_you_live_while_studying?, for_response: "6935"
        end
      end
    end

    context "how_many_credits_will_you_study?" do
      setup do
        testing_node :how_many_credits_will_you_study?
        add_responses when_does_your_course_start?: "2020-2021",
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
        should "have a next node of how_many_credits_does_a_full_time_student_study" do
          assert_next_node :how_many_credits_does_a_full_time_student_study?, for_response: "10"
        end
      end
    end

    context "how_many_credits_does_a_full_time_student_study?" do
      setup do
        testing_node :how_many_credits_does_a_full_time_student_study?
        add_responses when_does_your_course_start?: "2020-2021",
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
        should "have a next node of do_any_of_the_following_apply_all_uk_students?" do
          assert_next_node :do_any_of_the_following_apply_all_uk_students?, for_response: "11"
        end
      end
    end

    context "do_any_of_the_following_apply_all_uk_students?" do
      setup do
        testing_node :do_any_of_the_following_apply_all_uk_students?
        add_responses when_does_your_course_start?: "2020-2021",
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
        should "have a next node of what_course_are_you_studying?" do
          assert_next_node :what_course_are_you_studying?, for_response: "has-disability,low-income"
        end
      end
    end

    context "what_course_are_you_studying?" do
      setup do
        testing_node :what_course_are_you_studying?
        add_responses when_does_your_course_start?: "2020-2021",
                      what_type_of_student_are_you?: "uk-part-time",
                      how_much_are_your_tuition_fees_per_year?: "6935",
                      where_will_you_live_while_studying?: "at-home",
                      whats_your_household_income?: "50,000",
                      how_many_credits_will_you_study?: "10",
                      how_many_credits_does_a_full_time_student_study?: "11",
                      do_any_of_the_following_apply_all_uk_students?: "has-disability,low-income"
      end

      should "render the question" do
        assert_rendered_question
      end

      context "next_node" do
        should "have a next node of outcome_uk_part_time_students for any response" do
          assert_next_node :outcome_uk_part_time_students, for_response: "dental-medical-healthcare"
        end
      end
    end
  end

  context "EU full time students" do
    context "question: how_much_are_your_tuition_fees_per_year?," do
      setup do
        testing_node :how_much_are_your_tuition_fees_per_year?
        add_responses when_does_your_course_start?: "2020-2021",
                      what_type_of_student_are_you?: "eu-full-time"
      end

      should "render the question" do
        assert_rendered_question
      end

      context "validation" do
        should "be invalid if a fee over 9250 is entered for full time students" do
          assert_invalid_response "9251"
        end
      end

      context "next_node" do
        should "have a next node of outcome_eu_students" do
          assert_next_node :outcome_eu_students, for_response: "9250"
        end
      end
    end
  end

  context "EU part time students" do
    context "question: how_much_are_your_tuition_fees_per_year?," do
      setup do
        testing_node :how_much_are_your_tuition_fees_per_year?
        add_responses when_does_your_course_start?: "2020-2021",
                      what_type_of_student_are_you?: "eu-part-time"
      end

      should "render the question" do
        assert_rendered_question
      end

      context "validation" do
        should "be invalid if a fee over 6935 is entered for part time students" do
          assert_invalid_response "6936"
        end
      end

      context "next_node" do
        should "have a next node of outcome_eu_students" do
          assert_next_node :outcome_eu_students, for_response: "6935"
        end
      end
    end
  end
end
