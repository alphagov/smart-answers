multiple_choice :are_you_a_full_time_or_part_time_student? do
  option "Full-time"
  option "Part-time"
  next_node :how_much_is_your_tution_fee_per_year?
  save_input_as :course_type
end

money_question :how_much_is_your_tution_fee_per_year? do 
  next_node :where_will_you_live_while_studying?
  save_input_as :tuition_fee_amount                      
  
  calculate :tuition_fee_amount do |response|
    if :course_type == "Full-time"
      raise SmartAnswer::InvalidResponse if response.tuition_fee_amount > 9000
    else
      raise SmartAnswer::InvalidResponse if response.tuition_fee_amount > 6750
    end                                                                       
    Money.new(response.tuition_fee_amount)
  end
end

multiple_choice :where_will_you_live_while_studying? do
  option "at home with my parents"
  option "away from home, outside of London"
  option "away from home, in London"  
  save_input_as :where_will_you_live_while_studying?

  calculate :maintenance_loan_amount do |response|
    case response.where_will_you_live_while_studying?
    when /at home/ then Money.new("4473")
    when /outside of London/ then Money.new("5500")
    when /in London/ then Money.new("7675")
    else
      raise SmartAnswer::InvalidResponse
    end
  end
  next_node :how_much_do_your_parents_or_partner_earn?
end

multiple_choice :how_much_do_your_parents_or_partner_earn? do
  option "Up to £25,000"
  option "£25,001 - £30,000"
  option "£30,001 - £35,000"
  option "£35,001 - £40,000"    
  option "£40,001 - £42,600"
  option "More than £42,600"      
  option "I don't know"
  next_node :would_you_like_to_check_for_additional_grants_and_allowances?
  save_input_as :how_much_do_your_parents_earn?                                                 
  
  calculate :maintenance_grant_amount do |response|
    case response.how_much_do_your_parents_earn?
    when /Up to £25,000/ then Money.new('3250')
    when /£25,001 \- £30,000/ then Money.new('2341')
    when /£30,001 \- £35,000/ then Money.new('1432')
    when /£35,001 \- £40,000/ then Money.new('523')
    when /£40,001 \- £42,600/ then Money.new('50')
    when /More than £42,600/ then Money.new('0')
    when /I don't know/ then :dont_know
    end 
  end
end 

multiple_choice :would_you_like_to_check_for_additional_grants_and_allowances? do
  option :yes => :do_you_have_any_children_under_17?
  option :no => :done
  
  calculate :additional_benefits do
    if responses.last == "no"
      PhraseList.new
    end
  end 
end

multiple_choice :do_you_have_any_children_under_17? do
  option :yes
  option :no
  next_node :does_another_adult_depend_on_you_financially?
  
  calculate :additional_benefits do
    if responses.last == "yes"
      PhraseList.new(:dependent_children)
    else
      PhraseList.new
    end
  end
end

multiple_choice :does_another_adult_depend_on_you_financially? do
  option :yes
  option :no
  next_node :do_you_have_a_disability_or_health_condition?

  calculate :additional_benefits do |response|
    responses.last == "yes" ? additional_benefits + :dependent_adult : additional_benefits
  end
end

multiple_choice :do_you_have_a_disability_or_health_condition? do
  option :yes
  option :no                                    
  next_node :are_you_in_financial_hardship?     
  
  calculate :additional_benefits do |response|
    responses.last == "yes" ? additional_benefits + :disability : additional_benefits
  end
end

multiple_choice :are_you_in_financial_hardship? do
  option :yes
  option :no
  next_node :are_you_studying_one_of_these_courses?            
  
  calculate :additional_benefits do |response|
    responses.last == "yes" ? additional_benefits + :financial_hardship : additional_benefits
  end
end

multiple_choice :are_you_studying_one_of_these_courses? do
  option "Teacher training"
  option "Dental, medical, or healthcare"
  option "Social work"         
  option "None of these"                                                      
  
  calculate :additional_benefits do |response|
    case response.last
    when "Teacher training" 
      additional_benefits + :teacher_training
    when "Dental, medical, or healthcare" 
      additional_benefits + :medical
    when "Social work"
      additional_benefits + :social_work
    else
      additional_benefits
    end
  end
  
  next_node :done
end

outcome :done
