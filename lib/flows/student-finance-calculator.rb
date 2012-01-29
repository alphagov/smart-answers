section_slug "education"
satisfies_need 2175
status :published

multiple_choice :are_you_a_full_time_or_part_time_student? do
  option :'full-time'
  option :'part-time'
  next_node :how_much_is_your_tuition_fee_per_year?
  save_input_as :course_type
end

money_question :how_much_is_your_tuition_fee_per_year? do
  next_node do
    if course_type == "full-time"
      :where_will_you_live_while_studying?
    else
      :do_you_want_to_check_for_additional_grants_and_allowances?
    end
  end

  calculate :tuition_fee_amount do
    if course_type == "full-time"
      raise SmartAnswer::InvalidResponse if responses.last > 9000
    else
      raise SmartAnswer::InvalidResponse if responses.last > 6750
    end
    Money.new(responses.last)
  end

  calculate :eligible_finance do
    PhraseList.new(:tuition_fee_loan)
  end
end

multiple_choice :where_will_you_live_while_studying? do
  option :'at-home'
  option :'away-outside-london'
  option :'away-in-london'
  save_input_as :where_will_you_live_while_studying?

  calculate :maintenance_loan_amount do
    case responses.last
    when "at-home" then Money.new("4473")
    when "away-outside-london" then Money.new("5500")
    when "away-in-london" then Money.new("7675")
    else
      raise SmartAnswer::InvalidResponse
    end
  end
  next_node :whats_your_household_income?

  calculate :eligible_finance do
    eligible_finance + :maintenance_loan
  end
end

multiple_choice :whats_your_household_income? do
  option :'up-to-25000'
  option :'25001-30000'
  option :'30001-35000'
  option :'35001-40000'
  option :'40001-42600'
  option :'more-than-42600'
  next_node :do_you_want_to_check_for_additional_grants_and_allowances?
  save_input_as :whats_your_household_income?

  calculate :maintenance_grant_amount do
    case responses.last
    when "up-to-25000" then Money.new('3250')
    when "25001-30000" then Money.new('2341')
    when "30001-35000" then Money.new('1432')
    when "35001-40000" then Money.new('523')
    when "40001-42600" then Money.new('50')
    when "more-than-42600" then Money.new('0')
    end
  end

  calculate :eligible_finance do
    eligible_finance + :maintenance_grant
  end
end

multiple_choice :do_you_want_to_check_for_additional_grants_and_allowances? do
  option :yes
  option :no

  save_input_as :check_for_additional_grants_and_allowances

  next_node do |response|
    if response == "yes"
      (course_type == "full-time") ? :do_you_have_any_children_under_17? : :do_you_have_a_disability_or_health_condition?
    else
      :done
    end
  end

  calculate :additional_benefits do
    if responses.last == "yes"
      PhraseList.new(:body)
    else
      PhraseList.new
    end
  end
end

multiple_choice :do_you_have_any_children_under_17? do
  option :yes
  option :no
  next_node :does_another_adult_depend_on_you_financially?

  calculate :additional_benefits do
    additional_benefits = PhraseList.new(:body)
    if responses.last == "yes"
      additional_benefits +:dependent_children
    end
    additional_benefits
  end
end

multiple_choice :does_another_adult_depend_on_you_financially? do
  option :yes
  option :no
  next_node :do_you_have_a_disability_or_health_condition?

  calculate :additional_benefits do
    responses.last == "yes" ? additional_benefits + :dependent_adult : additional_benefits
  end
end

multiple_choice :do_you_have_a_disability_or_health_condition? do
  option :yes
  option :no
  next_node :are_you_in_financial_hardship?

  calculate :additional_benefits do
    responses.last == "yes" ? additional_benefits + :disability : additional_benefits
  end
end

multiple_choice :are_you_in_financial_hardship? do
  option :yes
  option :no
  next_node :are_you_studying_one_of_these_courses?

  calculate :additional_benefits do
    responses.last == "yes" ? additional_benefits + :financial_hardship : additional_benefits
  end
end

multiple_choice :are_you_studying_one_of_these_courses? do
  option :'teacher-training'
  option :'dental-medical-or-healthcare'
  option :'social-work'
  option :'none'

  calculate :additional_benefits do
    puts additional_benefits.inspect
    case responses.last
    when "teacher-training"
      additional_benefits + :teacher_training
    when "dental-medical-or-healthcare"
      additional_benefits + :medical
    when "social-work"
      additional_benefits + :social_work
    else
      additional_benefits
    end
  end

  next_node :done
end

outcome :done
