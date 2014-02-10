status :draft
#??????
satisfies_need "" #??????

total_input = [] #used for calculating the right outcome

# Q1
multiple_choice :what_is_your_marital_status? do
  option :married
  option :will_marry_before_specific_date
  option :will_marry_on_or_after_specific_date 
  option :widowed

  save_input_as :marital_status
  
  if :marital_status == "married" or :marital_status == "will_marry_before_specific_date"
    total_input << :old1
  elsif :marital_status == "will_marry_on_or_after_specific_date"
    total_input << :new1
  elsif :marital_status == "widow"
    total_input << :old1 << :widow
  end
  
  next_node :when_will_you_reach_pension_age?
end

# Q2
multiple_choice :when_will_you_reach_pension_age? do
  option :your_pension_age_before_specific_date
  option :your_pension_age_after_specific_date
  
  save_input_as :your_pension_age
  
  if :your_pension_age == "your_pension_age_before_specific_date"
    total_input << :old2
  elsif :your_pension_age == "your_pension_age_after_specific_date"
    total_input << :new2
  end

  next_node :when_will_your_partner_reach_pension_age?
end

multiple_choice :when_will_your_partner_reach_pension_age? do
  option :partner_pension_age_before_specific_date
  option :partner_pension_age_after_specific_date
  
  save_input_as :partner_pension_age
  
  if :partner_pension_age == "partner_pension_age_before_specific_date"
    total_input << :old3
  elsif :partner_pension_age == "partner_pension_age_after_specific_date"
    total_input << :new3
  end

  outcome_1_array = [:old1, :old2, :old3]
  # outcome_2_array = [:old1, :old2, :old3, :widow]
  # outcome_3_array = [:old1, :old2, :new3]
  # outcome_4_array = [:old1, :old2, :new3, :widow]
  

  # next_node do 
  # if %w(old1).include?(total_input) && %w(old2).include?(total_input) && %w(old3).include?(total_input)
  if total_input == outcome_1_array
    next_node :outcome_1
  #   elsif %w(old1).include?(total_input) && %w(old2).include?(total_input) && %w(old3).include?(total_input) && %w(widow).include?(total_input)
  #     :outcome_2
  #   elsif %w(old1).include?(total_input) && %w(old2).include?(total_input) && %w(new3).include?(total_input)
  #     :outcome_3
  #   elsif %w(old1).include?(total_input) && %w(old2).include?(total_input) && %w(new3).include?(total_input) && %w(widow).include?(total_input)
  #     :outcome_4
  else
    puts total_input
    next_node :outcome_2
  #   end
  end  
end


outcome :outcome_1
outcome :outcome_2
outcome :outcome_3
outcome :outcome_4
