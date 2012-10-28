satisfies_need 2175
status :published

multiple_choice :when_does_your_course_start? do
  option :'2012-2013'
  option :'2013-2014'
  save_input_as :start_date
  next_node :are_you_a_full_time_or_part_time_student?
end

multiple_choice :are_you_a_full_time_or_part_time_student? do
  option :'full-time'
  option :'part-time'
  save_input_as :course_type
  next_node :how_much_are_your_tuition_fees_per_year?
end

money_question :how_much_are_your_tuition_fees_per_year? do
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

  next_node do
    if course_type == "full-time"
      :where_will_you_live_while_studying?
    else
      :part_time_do_you_want_to_check_for_additional_grants_and_allowances?
    end
  end
end

multiple_choice :where_will_you_live_while_studying? do
  option :'at-home'
  option :'away-outside-london'
  option :'away-in-london'

  calculate :max_maintenance_loan_amount do
    case responses.last
    when "at-home" then Money.new("4375")
    when "away-outside-london" then Money.new("5500")
    when "away-in-london" then Money.new("7675")
    else
      raise SmartAnswer::InvalidResponse
    end
  end

  next_node :whats_your_household_income?
end

money_question :whats_your_household_income? do

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
      # 2012-13: decreases from max by £1 for each complete £5.50 of income above £25k
      # min of £50 at 42600
      if responses.last <= 25000
        Money.new('3250')
      else
        if responses.last > 42600
          Money.new('0')
        else
          Money.new( 3250 - ((responses.last - 25000)/5.5).floor )
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

  next_node do |response|
    if course_type == "full-time"
      :full_time_do_you_want_to_check_for_additional_grants_and_allowances?
    else
      :part_time_do_you_want_to_check_for_additional_grants_and_allowances?
    end
  end

end

multiple_choice :full_time_do_you_want_to_check_for_additional_grants_and_allowances? do
  option :yes => :do_you_have_any_children_under_17?
  option :no => :done

  calculate :additional_benefits do
    if responses.last == "yes"
      PhraseList.new(:body)
    else
      PhraseList.new
    end
  end

  calculate :extra_grants do
    if responses.last == "no"
      PhraseList.new(:additional_grants_and_allowances)
    else
      PhraseList.new
    end
  end

end

multiple_choice :part_time_do_you_want_to_check_for_additional_grants_and_allowances? do
  option :yes => :do_you_have_a_disability_or_health_condition?
  option :no => :done
  
  calculate :additional_benefits do
    if responses.last == "yes"
      PhraseList.new(:body)
    else
      PhraseList.new
    end
  end

  calculate :extra_grants do
    if responses.last == "no"
      PhraseList.new(:additional_grants_and_allowances)
    else
      PhraseList.new
    end
  end
end


multiple_choice :do_you_have_any_children_under_17? do
  option :yes
  option :no

  calculate :additional_benefits do
    responses.last == "yes" ? additional_benefits + :dependent_children : additional_benefits
  end

  next_node :does_another_adult_depend_on_you_financially?
end

multiple_choice :does_another_adult_depend_on_you_financially? do
  option :yes
  option :no

  calculate :additional_benefits do
    responses.last == "yes" ? additional_benefits + :dependent_adult : additional_benefits
  end

  next_node :do_you_have_a_disability_or_health_condition?
end

multiple_choice :do_you_have_a_disability_or_health_condition? do
  option :yes
  option :no

  calculate :additional_benefits do
    responses.last == "yes" ? additional_benefits + :disability : additional_benefits
  end

  next_node :are_you_in_financial_hardship?
end

multiple_choice :are_you_in_financial_hardship? do
  option :yes
  option :no
  
  calculate :additional_benefits do
    responses.last == "yes" ? additional_benefits + :financial_hardship : additional_benefits
  end

  next_node :are_you_studying_one_of_these_courses?
end

multiple_choice :are_you_studying_one_of_these_courses? do
  option :'teacher-training'
  option :'dental-medical-or-healthcare'
  option :'social-work'
  option :'none'

  calculate :additional_benefits do
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

outcome :done do

  precalculate :additional_benefits do
    a = [:dependent_children, :dependent_adult, :disability, :financial_hardship, :teacher_training, :medical, :social_work]
    if (additional_benefits.phrase_keys & a).empty?
      PhraseList.new
    else
      additional_benefits
    end
  end

  precalculate :extra_grants do
    a = [:dependent_children, :dependent_adult, :disability, :financial_hardship, :teacher_training, :medical, :social_work]
    if (additional_benefits.phrase_keys & a).empty?
      PhraseList.new(:additional_grants_and_allowances)
    else
      extra_grants
    end
  end

end
