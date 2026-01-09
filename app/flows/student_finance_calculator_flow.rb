class StudentFinanceCalculatorFlow < SmartAnswer::Flow
  def define
    content_id "434b6eb5-33c8-4300-aba3-f5ead58600b8"
    name "student-finance-calculator"
    status :published

    # Q1
    radio :when_does_your_course_start? do
      option :"2025-2026"
      option :"2026-2027"

      on_response do |response|
        self.calculator = SmartAnswer::Calculators::StudentFinanceCalculator.new
        calculator.course_start = response
      end

      next_node do
        question :what_loans_are_you_eligible_for?
      end
    end

    # Q2
    radio :what_loans_are_you_eligible_for? do
      option :"tuition-and-maintenance"
      option :"tuition-only"

      on_response do |response|
        calculator.loan_eligibility = response
      end

      next_node do
        question :will_you_be_studying_full_or_part_time?
      end
    end

    # Q3
    radio :will_you_be_studying_full_or_part_time? do
      option :"full-time"
      option :"part-time"

      on_response do |response|
        calculator.course_type = response
      end

      next_node do
        question :how_much_are_your_tuition_fees_per_year?
      end
    end

    # Q4
    money_question :how_much_are_your_tuition_fees_per_year? do
      on_response do |response|
        calculator.tuition_fee_amount = SmartAnswer::Money.new(response)
      end

      validate do
        calculator.valid_tuition_fee_amount?
      end

      next_node do
        if calculator.loan_eligibility == "tuition-and-maintenance"
          question :where_will_you_live_while_studying?
        elsif calculator.loan_eligibility == "tuition-only"
          outcome :outcome_tuition_fee_only
        end
      end
    end

    # Q5
    radio :where_will_you_live_while_studying? do
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

    # Q6
    money_question :whats_your_household_income? do
      on_response do |response|
        calculator.household_income = response
      end

      next_node do
        case calculator.course_type
        when "full-time"
          question :do_any_of_the_following_apply_uk_full_time_students_only?
        when "part-time"
          question :how_many_credits_will_you_study?
        end
      end
    end

    # Q7a
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

    # Q7b
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

    # Q8a uk full-time students
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

    # Q8b uk students
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

    # Q9a
    radio :what_course_are_you_studying? do
      option :"teacher-training"
      option :"dental-medical-healthcare"
      option :"social-work"
      option :"none-of-the-above"

      on_response do |response|
        calculator.course_studied = response
      end

      next_node do |response|
        case calculator.course_type
        when "full-time"
          if response == "dental-medical-healthcare"
            question :are_you_a_doctor_or_dentist?
          else
            outcome :outcome_uk_full_time_students
          end
        when "part-time"
          outcome :outcome_uk_part_time_students
        end
      end
    end

    # Q9b
    radio :are_you_a_doctor_or_dentist? do
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

    outcome :outcome_uk_part_time_students

    outcome :outcome_tuition_fee_only

    outcome :outcome_uk_full_time_dental_medical_students
  end
end
