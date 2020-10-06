module SmartAnswer
  class StudentFinanceCalculatorFlow < Flow
    def define
      start_page_content_id "434b6eb5-33c8-4300-aba3-f5ead58600b8"
      flow_content_id "92631e38-206a-4785-82b2-4f544db16040"
      name "student-finance-calculator"
      status :published
      satisfies_need "7389628a-b288-45c4-a8c3-f4d9de7f8873"

      # Q1
      multiple_choice :when_does_your_course_start? do
        option :"2019-2020"
        option :"2020-2021"

        on_response do |response|
          self.calculator = Calculators::StudentFinanceCalculator.new
          calculator.course_start = response
        end

        next_node do
          question :what_type_of_student_are_you?
        end
      end

      # Q2
      multiple_choice :what_type_of_student_are_you? do
        option :"uk-full-time"
        option :"uk-part-time"
        option :"eu-full-time"
        option :"eu-part-time"

        on_response do |response|
          calculator.course_type = response
        end

        next_node do
          question :how_much_are_your_tuition_fees_per_year?
        end
      end

      # Q3
      money_question :how_much_are_your_tuition_fees_per_year? do
        on_response do |response|
          calculator.tuition_fee_amount = SmartAnswer::Money.new(response)
        end

        validate do
          calculator.valid_tuition_fee_amount?
        end

        next_node do
          case calculator.course_type
          when "uk-full-time"
            question :where_will_you_live_while_studying?
          when "uk-part-time"
            question :where_will_you_live_while_studying?
          when "eu-full-time", "eu-part-time"
            outcome :outcome_eu_students
          end
        end
      end

      # Q4
      multiple_choice :where_will_you_live_while_studying? do
        option :'at-home'
        option :'away-outside-london'
        option :'away-in-london'

        on_response do |response|
          calculator.residence = response
        end

        next_node do
          question :whats_your_household_income?
        end
      end

      # Q5
      money_question :whats_your_household_income? do
        on_response do |response|
          calculator.household_income = response
        end

        next_node do
          case calculator.course_type
          when "uk-full-time"
            question :do_any_of_the_following_apply_uk_full_time_students_only?
          when "uk-part-time"
            question :how_many_credits_will_you_study?
          end
        end
      end

      # Q6a
      value_question :how_many_credits_will_you_study?, parse: Float do
        on_response do |response|
          calculator.part_time_credits = response
        end

        validate do
          calculator.valid_credit_amount?
        end

        next_node do
          question :how_many_credits_does_a_full_time_student_study?
        end
      end

      # Q6b
      value_question :how_many_credits_does_a_full_time_student_study?, parse: Float do
        on_response do |response|
          calculator.full_time_credits = response
        end

        validate do
          calculator.valid_full_time_credit_amount?
        end

        next_node do
          question :do_any_of_the_following_apply_all_uk_students?
        end
      end

      # Q7a uk full-time students
      checkbox_question :do_any_of_the_following_apply_uk_full_time_students_only? do
        option :"children-under-17"
        option :"dependant-adult"
        option :"has-disability"
        option :"low-income"
        option :no

        on_response do |response|
          calculator.uk_ft_circumstances = response.split(",")
        end

        next_node do
          question :what_course_are_you_studying?
        end
      end

      # Q7b uk students
      checkbox_question :do_any_of_the_following_apply_all_uk_students? do
        option :"has-disability"
        option :"low-income"
        option :no

        on_response do |response|
          calculator.uk_all_circumstances = response.split(",")
        end

        next_node do
          question :what_course_are_you_studying?
        end
      end

      # Q8a
      multiple_choice :what_course_are_you_studying? do
        option :"teacher-training"
        option :"dental-medical-healthcare"
        option :"social-work"
        option :"none-of-the-above"

        on_response do |response|
          calculator.course_studied = response
        end

        next_node do |response|
          case calculator.course_type
          when "uk-full-time"
            if response == "dental-medical-healthcare"
              question :are_you_a_doctor_or_dentist?
            else
              outcome :outcome_uk_full_time_students
            end
          when "uk-part-time"
            outcome :outcome_uk_all_students
          else
            outcome :outcome_eu_students
          end
        end
      end

      # Q8b
      multiple_choice :are_you_a_doctor_or_dentist? do
        option :yes
        option :no

        on_response do |response|
          calculator.doctor_or_dentist = (response == "yes")
        end

        next_node do |response|
          if response == "yes"
            outcome :outcome_uk_full_time_dental_medical_students
          else
            outcome :outcome_uk_full_time_students
          end
        end
      end

      outcome :outcome_uk_full_time_students

      outcome :outcome_uk_all_students

      outcome :outcome_eu_students

      outcome :outcome_uk_full_time_dental_medical_students
    end
  end
end
