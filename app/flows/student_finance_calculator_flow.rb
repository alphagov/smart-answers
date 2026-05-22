class StudentFinanceCalculatorFlow < SmartAnswer::Flow
  def define
    content_id "434b6eb5-33c8-4300-aba3-f5ead58600b8"
    name "student-finance-calculator"
    status :published

    # Q1
    radio :when_does_your_course_start? do
      option :"2025-2026"
      option :"2026-2027"
      option :"2027-2028"

      on_response do |response|
        self.calculator = SmartAnswer::Calculators::StudentFinanceCalculator.new
        calculator.course_start = response
      end

      next_node do |response|
        if response == "2027-2028"
          question :what_age_are_you_on_first_day_of_course?
        else
          question :what_loans_are_you_eligible_for?
        end
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
      option :'overseas'

      on_response do |response|
        calculator.residence = response
      end

      next_node do
        case calculator.course_start
        when "2027-2028"
          question :do_any_of_the_following_apply_uk_full_time_students_only?
        else
          question :whats_your_household_income?
        end
      end
    end

    # Q6
    money_question :whats_your_household_income? do
      on_response do |response|
        calculator.household_income = response
      end

      next_node do
        if calculator.course_start == "2027-2028"
          question :are_you_studying_one_of_these_courses?
        else
          case calculator.course_type
          when "full-time"
            question :do_any_of_the_following_apply_uk_full_time_students_only?
          when "part-time"
            question :how_many_credits_will_you_study?
          end
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
          case calculator.course_type
          when "full-time"
            question :how_much_are_your_tuition_fees_per_year?
          when "part-time"
            question :how_many_credits_does_a_full_time_student_study?
          end
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
      option :"care-leaver"
      option :no

      on_response do |response|
        calculator.uk_ft_circumstances = response.split(",")
      end

      next_node do |response|
        case calculator.course_start
        when "2027-2028"
          if response.include?("care-leaver")
            question :are_you_studying_one_of_these_courses?
          else
            question :whats_your_household_income?
          end
        else
          question :what_course_are_you_studying?
        end
      end
    end

    # Q8b uk students
    checkbox_question :do_any_of_the_following_apply_all_uk_students? do
      option :"has-disability"
      option :"low-income"
      option :"care-leaver"
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

    # Q2
    radio :what_age_are_you_on_first_day_of_course? do
      option :"under-60"
      option :"60-or-more"

      on_response do |response|
        calculator.age = response
      end

      next_node do |response|
        if response == "under-60"
          question :how_are_you_planning_to_study?
        else
          question :are_you_studying_one_of_these_courses?
        end
      end
    end

    radio :how_are_you_planning_to_study? do
      option :"full-time"
      option :"part-time"

      on_response do |response|
        calculator.course_type = response
      end

      next_node do
        question :how_many_credits_will_you_study_course_module?
      end
    end

    value_question :how_many_credits_will_you_study_course_module?, parse: Float do
      on_response do |response|
        calculator.part_time_credits = response
      end

      validate do
        calculator.valid_credit_amount_lle?
      end

      next_node do
        case calculator.course_type
        when "full-time"
          question :how_much_are_your_tuition_fees_course_or_module?
        when "part-time"
          question :how_much_are_your_tuition_fees_course_or_module?
        end
      end
    end

    money_question :how_much_are_your_tuition_fees_course_or_module? do
      on_response do |response|
        calculator.tuition_fee_amount = SmartAnswer::Money.new(response)
      end

      validate do
        calculator.valid_tuition_fee_amount_lle?
      end

      next_node do
        question :have_you_studied_before?
      end
    end

    radio :have_you_studied_before? do
      option :yes
      option :no

      on_response do |response|
        calculator.studied_before = response
      end

      next_node do
        question :will_you_attend_in_person?
      end
    end

    radio :will_you_attend_in_person? do
      option :yes
      option :no

      on_response do |response|
        calculator.attend_in_person = response
      end

      next_node do |response|
        if response == "yes"
          question :where_will_you_live_while_studying?
        elsif response == "no"
          question :are_you_unable_to_be_in_person_disability?
        end
      end
    end

    radio :are_you_unable_to_be_in_person_disability? do
      option :yes
      option :no

      on_response do |response|
        calculator.disability_status = response
      end

      next_node do |response|
        if response == "yes"
          question :where_will_you_live_while_studying?
        elsif response == "no"
          question :do_any_of_the_following_apply_distance_learner?
        end
      end
    end

    checkbox_question :do_any_of_the_following_apply_distance_learner? do
      option :"has-disability"
      option :"low-income"
      option :no

      on_response do |response|
        calculator.uk_all_circumstances = response.split(",")
      end

      next_node do
        question :are_you_studying_one_of_these_courses?
      end
    end

    radio :are_you_studying_one_of_these_courses? do
      option :"teacher-training"
      option :"dental-medicine-healthcare"
      option :"social-work"
      option :no


      on_response do |response|
        calculator.specific_courses = response
      end

      next_node do |response|
        case response
        when "dental-medicine-healthcare"
          question :is_your_course_eligible_nhs_bursary?
        when "teacher-training"
          outcome :outcome_uk_full_time_students_teacher_training
        when "social-work"
          outcome :outcome_uk_full_time_students_social_work
        when "no"
          outcome :outcome_uk_full_time_students_full_time
        end
      end
    end

    radio :is_your_course_eligible_nhs_bursary? do
      option :yes
      option :no

      on_response do |response|
        calculator.eligible_for_nhs_bursary = response
      end

      next_node do |response|
        if response == "yes"
          outcome :outcome_uk_full_time_students_nhs_bursary
        elsif response == "no"
          outcome :outcome_uk_full_time_students_nhs_nhs
        end
      end
    end

    outcome :outcome_uk_full_time_students

    outcome :outcome_uk_part_time_students

    outcome :outcome_tuition_fee_only

    outcome :outcome_uk_full_time_dental_medical_students

    outcome :outcome_lifelong_learning_entitlement
  end
end
