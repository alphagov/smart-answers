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

      next_node do
        if calculator.lle_scheme?
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

      on_response do |response|
        calculator.residence = response
      end

      next_node do
        if calculator.lle_scheme?
          if calculator.credits_studied >= 120
            question :do_any_of_the_following_apply_uk_120_credits_or_above?
          else
            question :do_any_of_the_following_apply_all_uk_students?
          end
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
        if calculator.lle_scheme?
          case calculator.age
          when "under-60"
            question :are_you_studying_one_of_these_courses?
          when "60-or-more"
            outcome :outcome_over_60_students
          end

        else
          case calculator.course_type
          when "full-time"
            question :do_any_of_the_following_apply_uk_120_credits_or_above?
          when "part-time"
            question :how_many_credits_will_you_study?
          end
        end
      end
    end

    # Q7a
    value_question :how_many_credits_will_you_study?, parse: Integer do
      on_response do |response|
        calculator.credits_studied = response
      end

      validate :error_credit_amount do
        calculator.valid_credit_amount?
      end

      next_node do
        question :how_many_credits_does_a_full_time_student_study?
      end
    end

    # Q7b
    value_question :how_many_credits_does_a_full_time_student_study?, parse: Integer do
      on_response do |response|
        calculator.full_time_credits = response
      end

      validate :error_credit_amount do
        calculator.valid_full_time_credit_amount?
      end

      next_node do
        question :do_any_of_the_following_apply_all_uk_students?
      end
    end

    # Q8a uk full-time students
    checkbox_question :do_any_of_the_following_apply_uk_120_credits_or_above? do
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
        if calculator.lle_scheme?
          if response.include?("care-leaver") && !response.include?("children-under-17") && !response.include?("dependant-adult")
            calculator.household_income = 0
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

      next_node do |response|
        if calculator.lle_scheme?
          case calculator.age
          when "under-60"
            if response.include?("care-leaver")
              calculator.household_income = 0
              question :are_you_studying_one_of_these_courses?
            else
              question :whats_your_household_income?
            end
          when "60-or-more"
            if response.include?("care-leaver")
              calculator.household_income = 0
              outcome :outcome_over_60_students
            else
              question :whats_your_household_income?
            end
          end
        else
          question :what_course_are_you_studying?
        end
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

    value_question :how_many_credits_will_you_study_course_module?, parse: Integer do
      on_response do |response|
        calculator.credits_studied = response
      end

      validate :error_credit_amount do
        calculator.valid_credit_amount_lle?
      end

      next_node do
        case calculator.course_type
        when "full-time"
          case calculator.age
          when "under-60"
            question :how_much_are_your_tuition_fees_course_or_module?
          when "60-or-more"
            question :will_you_attend_in_person?
          end
        when "part-time"
          question :how_many_credits_fte_course_or_module?
        end
      end
    end

    value_question :how_many_credits_fte_course_or_module?, parse: Integer do
      on_response do |response|
        calculator.full_time_credits = response
      end

      validate :error_credit_amount do
        calculator.valid_full_time_credit_amount_lle?
      end

      next_node do
        case calculator.age
        when "under-60"
          question :how_much_are_your_tuition_fees_course_or_module?
        when "60-or-more"
          question :will_you_attend_in_person?
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
        case calculator.age
        when "under-60"
          question :have_you_studied_before?
        when "60-or-more"
          question :will_you_attend_in_person?
        end
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
        case calculator.age
        when "under-60"
          if response == "yes"
            question :where_will_you_live_while_studying_lle?
          elsif response == "no"
            question :are_you_unable_to_be_in_person_disability?
          end
        when "60-or-more"
          if response == "yes"
            if calculator.credits_studied >= 120
              question :do_any_of_the_following_apply_uk_120_credits_or_above?
            else
              question :do_any_of_the_following_apply_all_uk_students?
            end
          elsif response == "no"
            question :are_you_unable_to_be_in_person_disability?
          end
        end
      end
    end

    radio :where_will_you_live_while_studying_lle? do
      option :'at-home'
      option :'away-outside-london'
      option :'away-in-london'
      option :'living-overseas'

      on_response do |response|
        calculator.residence = response
      end

      next_node do
        if calculator.credits_studied >= 120
          question :do_any_of_the_following_apply_uk_120_credits_or_above?
        else
          question :do_any_of_the_following_apply_all_uk_students?
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
        case calculator.age
        when "under-60"
          if response == "yes"
            question :where_will_you_live_while_studying_lle?
          elsif response == "no"
            calculator.household_income = 0
            question :do_any_of_the_following_apply_distance_learner?
          end
        when "60-or-more"
          if response == "yes"
            if calculator.credits_studied >= 120
              question :do_any_of_the_following_apply_uk_120_credits_or_above?
            else
              question :do_any_of_the_following_apply_all_uk_students?
            end
          elsif response == "no"
            calculator.household_income = 0
            question :do_any_of_the_following_apply_distance_learner?
          end
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
        case calculator.age
        when "under-60"
          question :are_you_studying_one_of_these_courses?
        when "60-or-more"
          outcome :outcome_over_60_distance_learner
        end
      end
    end

    radio :are_you_studying_one_of_these_courses? do
      option :"teacher-training"
      option :"dental-medical-healthcare"
      option :"social-work"
      option :no

      on_response do |response|
        calculator.course_studied = response
      end

      next_node do |response|
        if calculator.age == "60-or-more"
          case response
          when "dental-medical-healthcare"
            question :is_your_course_eligible_nhs_bursary?
          else
            question :how_are_you_planning_to_study?
          end
        elsif calculator.age == "under-60"
          case response
          when "dental-medical-healthcare"
            question :is_your_course_eligible_nhs_bursary?
          else
            if calculator.attend_in_person == "yes" || calculator.disability_status == "yes"
              outcome :outcome_under_60_students
            elsif calculator.attend_in_person == "no"
              outcome :outcome_under_60_distance_learner
            end
          end
        end
      end
    end

    radio :is_your_course_eligible_nhs_bursary? do
      option :yes
      option :no

      on_response do |response|
        calculator.eligible_for_nhs_bursary = response
      end

      next_node do
        if calculator.age == "60-or-more"
          question :how_are_you_planning_to_study?
        elsif calculator.age == "under-60"
          if calculator.attend_in_person == "yes" || calculator.disability_status == "yes"
            outcome :outcome_under_60_students
          elsif calculator.attend_in_person == "no"
            outcome :outcome_under_60_distance_learner
          end
        end
      end
    end

    outcome :outcome_uk_full_time_students

    outcome :outcome_uk_part_time_students

    outcome :outcome_tuition_fee_only

    outcome :outcome_uk_full_time_dental_medical_students

    outcome :outcome_under_60_students

    outcome :outcome_under_60_distance_learner

    outcome :outcome_over_60_students

    outcome :outcome_over_60_distance_learner
  end
end
