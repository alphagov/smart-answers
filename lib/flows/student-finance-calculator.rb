satisfies_need 2175
status :published

max_maintainence_loan_amounts = {
  "2013-2014" => {
    "at-home" => 4375,
    "away-outside-london" => 5500,
    "away-in-london" => 7675
  },
  "2014-2015" => {
    "at-home" => 4418,
    "away-outside-london" => 5555,
    "away-in-london" => 7751
  }
}

#Q1
multiple_choice :when_does_your_course_start? do
  option :"2013-2014"
  option :"2014-2015"

  save_input_as :start_date
  next_node :what_type_of_student_are_you?
end

#Q2
multiple_choice :what_type_of_student_are_you? do
  option :"uk-full-time"
  option :"uk-part-time"
  option :"eu-full-time"
  option :"eu-part-time"

  save_input_as :course_type
  next_node :how_much_are_your_tuition_fees_per_year?
end

#Q3
money_question :how_much_are_your_tuition_fees_per_year? do

  calculate :tuition_fee_amount do
    if course_type == "uk-full-time" or course_type == 'eu-full-time'
      raise SmartAnswer::InvalidResponse if responses.last > 9000
    else
      raise SmartAnswer::InvalidResponse if responses.last > 6750
    end
    Money.new(responses.last)
  end

  calculate :eligible_finance do
    PhraseList.new(:tuition_fee_loan)
  end

  next_node do
    case course_type
    when 'uk-full-time'
      :where_will_you_live_while_studying?
    when 'uk-part-time'
      :do_any_of_the_following_apply_all_uk_students?
    when 'eu-full-time','eu-part-time'
      :outcome_eu_students
    end
  end

end
#Q4
multiple_choice :where_will_you_live_while_studying? do
  option :'at-home'
  option :'away-outside-london'
  option :'away-in-london'

  calculate :max_maintenance_loan_amount do
    begin
      Money.new(max_maintainence_loan_amounts[start_date][responses.last].to_s) 
    rescue
      raise SmartAnswer::InvalidResponse
    end
  end

  save_input_as :where_living
  next_node :whats_your_household_income?
end

#Q5
money_question :whats_your_household_income? do
    
  calculate :household_income_figure do
    if responses.last <= 25000
      PhraseList.new(:uk_students_body_text_with_nsp)
    else
      PhraseList.new(:uk_students_body_text_no_nsp)
    end
  end

  calculate :maintenance_grant_amount do
    if start_date == "2013-2014"
      # decreases from max by £1 for each complete £5.33 of income above £25k
      # min of £50 at £42611
      if responses.last <= 25000
        Money.new('3354')
      else
        if responses.last > 42611
          Money.new ('0')
        else
          Money.new( 3354 - ((responses.last - 25000)/5.33).floor )
        end
      end
    else
      # 2014-15:max of £3,387 for income up to £25,000 then, 
      # £1 less than max for each whole £5.28 above £25000 up to £42,611
      # min grant is £50 for income = £42,620
      # no grant for  income above £42,620  decreases from max by £1 for each complete £5.50 of income above £25k
      if responses.last <= 25000
        Money.new('3387')
      else
        if responses.last > 42620
          Money.new('0')
        else
          Money.new( 3387 - ((responses.last - 25000)/5.28).floor )
        end
      end
    end
  end

  # loan amount depends on maintenance grant amount and household income
  calculate :maintenance_loan_amount do
    if responses.last <= 42875
      # reduce maintenance loan by £0.5 for each £1 of maintenance grant
      Money.new ( max_maintenance_loan_amount - (maintenance_grant_amount.value / 2.0).floor)
    else
      # reduce maintenance loan by £1 for each full £10 of income above £42875 until loan reaches 65% of max, when no further reduction applies
      min_loan_amount = (0.65 * max_maintenance_loan_amount.value).floor # to match the reference table
      reduced_loan_amount = max_maintenance_loan_amount - ((responses.last - 42875)/10.0).floor
      if reduced_loan_amount > min_loan_amount
        Money.new (reduced_loan_amount)
      else
        Money.new (min_loan_amount)
      end
    end 
  end

  calculate :eligible_finance do
    finance = eligible_finance + :maintenance_loan

    if maintenance_grant_amount > 0
      finance + :maintenance_grant
    else
      finance
    end
  end

  
  next_node :do_any_of_the_following_apply_uk_full_time_students_only?
end

#Q6a uk full-time students
checkbox_question :do_any_of_the_following_apply_uk_full_time_students_only? do
  option :"children-under-17"
  option :"dependant-adult"
  option :"has-disability"
  option :"low-income"
  option :"no"

  calculate :uk_ft_circumstances do
    responses.last.split(',')
  end

  next_node :what_course_are_you_studying?
end

#Q6b uk students
checkbox_question :do_any_of_the_following_apply_all_uk_students? do
  option :"has-disability"
  option :"low-income"
  option :"no"

  calculate :all_uk_students_circumstances do
    responses.last.split(',')
  end

  next_node :what_course_are_you_studying?
end

#Q7
multiple_choice :what_course_are_you_studying? do
  option :"teacher-training"
  option :"dental-medical-healthcare"
  option :"social-work"
  option :"none-of-the-above"

  save_input_as :course_studied

  next_node do
    case course_type
    when 'uk-full-time'
      :outcome_uk_full_time_students
    when 'uk-part-time'
      :outcome_uk_all_students
    else
      :outcome_eu_students
    end
  end

end

outcome :outcome_uk_full_time_students do
  precalculate :students_body_text do
    PhraseList.new(:uk_students_body_text)
  end
  precalculate :uk_full_time_students do
    phrases = PhraseList.new
    if uk_ft_circumstances.include?('no') and course_studied == 'none-of-the-above'
      phrases << :no_additional_benefits
    else
      phrases << :additional_benefits
      if uk_ft_circumstances.include?('children-under-17')
        phrases << :"children_under_17_#{start_date}"
      end
      if uk_ft_circumstances.include?('dependant-adult')
        phrases << :"dependant_adult_#{start_date}"
      end
      if uk_ft_circumstances.include?('has-disability')
        phrases << :has_disability
      end
      if uk_ft_circumstances.include?('low-income')
        phrases << :low_income
      end

      if course_studied == 'teacher-training'
        phrases << :teacher_training
      elsif course_studied == 'dental-medical-healthcare'
        phrases << :dental_medical_healthcare
      elsif course_studied == 'social-work'
        phrases << :social_work
      end
    phrases
    end
  end
end

outcome :outcome_uk_all_students do
  precalculate :students_body_text do
    PhraseList.new(:uk_students_body_text)
  end
  precalculate :uk_all_students do
    phrases = PhraseList.new
    if all_uk_students_circumstances.include?('no') and course_studied == 'none-of-the-above'
      phrases << :no_additional_benefits
    else
      phrases << :additional_benefits
      if all_uk_students_circumstances.include?('has-disability')
        phrases << :has_disability
      end
      if all_uk_students_circumstances.include?('low-income')
        phrases << :low_income
      end
      if course_studied == 'teacher-training'
        phrases << :teacher_training
      elsif course_studied == 'dental-medical-healthcare'
        phrases << :dental_medical_healthcare
      elsif course_studied == 'social-work'
        phrases << :social_work
      end
    end
    phrases << :uk_students_body_text_no_nsp
    phrases
  end
end

outcome :outcome_eu_students do
  precalculate :eu_students do
    phrases = PhraseList.new
    phrases << :eu_students_body_text
    if course_type == 'eu-full-time'
      phrases << :eu_full_time_students
    else
      phrases << :eu_part_time_students
    end
    phrases << :eu_students_body_text_two
    phrases
  end
end
