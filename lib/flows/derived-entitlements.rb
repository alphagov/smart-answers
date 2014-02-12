status :draft
#??????
satisfies_need "" #??????


# Q1
multiple_choice :what_is_your_marital_status? do
  option :married
  option :will_marry_before_specific_date
  option :will_marry_on_or_after_specific_date 
  option :widowed

  calculate :answers do
    answers = []
    if responses.last == "married" or responses.last == "will_marry_before_specific_date"
      answers << :old1
    elsif responses.last == "will_marry_on_or_after_specific_date"
      answers << :new1
    elsif responses.last == "widowed"
      answers << :widow
    end
    answers
  end  
  next_node :when_will_you_reach_pension_age?
end

# Q2
multiple_choice :when_will_you_reach_pension_age? do
  option :your_pension_age_before_specific_date
  option :your_pension_age_after_specific_date
  
  calculate :answers do
    if responses.last == "your_pension_age_before_specific_date"
      answers << :old2
    elsif responses.last == "your_pension_age_after_specific_date"
      answers << :new2
    end
    answers
  end
  next_node :when_will_your_partner_reach_pension_age?
end

#Q3
multiple_choice :when_will_your_partner_reach_pension_age? do
  option :partner_pension_age_before_specific_date
  option :partner_pension_age_after_specific_date
    
  calculate :answers do
    if responses.last == "partner_pension_age_before_specific_date"
      answers << :old3
    elsif responses.last == "partner_pension_age_after_specific_date"
      answers << :new3
    end
    answers
  end
  
  calculate :result_phrase do
    phrases=PhraseList.new
    
    if answers == [:old1, :old2, :old3] || answers == [:new1, :new2, :old3] || answers == [:new1, :old2, :old3]
      phrases << :current_rules_no_additional_pension
    elsif answers == [:widow, :old2, :old3]
      phrases << :current_rules_and_additional_pension
    elsif answers == [:old1, :old2, :new3]
      phrases << :current_rules_national_insurance_no_state_pension
    elsif answers == [:widow, :old2, :new3]
      phrases << :current_rules_national_insurance_and_state_pension
    elsif answers == [:old1, :new2, :new3] || answers == [:new1, :new2, :new3] || answers == [:old1, :new2, :old3]
      phrases << :married_woman_no_state_pension
    elsif answers == [:widow, :new2, :new3]
    end
    phrases
  end
  
  next_node do |response|
    if answers == [:widow, :new2]
      :what_is_your_gender?
    else
      :final_outcome
    end
  end
end

# Q4
multiple_choice :what_is_your_gender? do
  option :male_gender
  option :female_gender
  
  calculate :result_phrase do
    phrases=PhraseList.new
    
    if responses.last == "male_gender"
      phrases << :impossibility_to_increase_pension
    elsif responses.last == "female_gender"
      phrases << :married_woman_and_state_pension
    end
    phrases
  end
  next_node :final_outcome
end

outcome :final_outcome