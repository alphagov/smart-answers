status :published
satisfies_need "100578"

### This will need updating before 6th April 2016 ###
# Q1
multiple_choice :what_is_your_marital_status? do
  option :married
  option :will_marry_before_specific_date
  option :will_marry_on_or_after_specific_date
  option :widowed
  option :divorced

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

  calculate :lower_basic_state_pension_rate do
    rate = SmartAnswer::Calculators::RatesQuery.new('state_pension', relevant_date: Date.today).rates.lower_weekly_rate
    "£#{rate}"
  end
  calculate :higher_basic_state_pension_rate do
    rate = SmartAnswer::Calculators::RatesQuery.new('state_pension', relevant_date: Date.today).rates.weekly_rate
    "£#{rate}"
  end

  next_node_if(:what_is_your_gender?, responded_with("divorced"))
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
    answers << :old3 if responses.first == "widowed"
    answers
  end

  calculate :result_phrase do
    if responses.first == "widowed" and responses.last == "your_pension_age_before_specific_date"
      PhraseList.new(
        :current_rules_and_additional_pension,
        :increase_retirement_income #outcome 2
      )
    end
  end

  define_predicate(:widow_and_new_pension?) do |response|
    answers == [:widow] && response == "your_pension_age_after_specific_date"
  end

  define_predicate(:widow_and_old_pension?) do |response|
    answers == [:widow] && response == "your_pension_age_before_specific_date"
  end

  next_node_if(:what_is_your_gender?, widow_and_new_pension?)
  next_node_if(:final_outcome, widow_and_old_pension?)
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
    phrases = PhraseList.new
    if answers == [:old1, :old2, :old3] || answers == [:new1, :old2, :old3]
      phrases << :current_rules_no_additional_pension #outcome 1
    elsif answers == [:old1, :old2, :new3] || answers == [:new1, :old2, :new3]
      phrases << :current_rules_national_insurance_no_state_pension #outcome 3
    end
    phrases << :increase_retirement_income
    phrases
  end

  define_predicate(:gender_not_needed_for_outcome?) {
    answers == [:old1, :old2] || answers == [:new1, :old2]
  }

  next_node_if(:final_outcome, gender_not_needed_for_outcome?)
  next_node :what_is_your_gender?
end

# Q4
multiple_choice :what_is_your_gender? do
  option :male_gender
  option :female_gender

  calculate :result_phrase do
    phrases = PhraseList.new
    if responses.last == "male_gender"
      if responses.first == "divorced"
        phrases << :impossibility_due_to_divorce #outcome 9
      else
        phrases << :impossibility_to_increase_pension #outcome 8
      end
    else
      if responses.first == "divorced"
        phrases << :age_dependent_pension #outcome 10
      elsif responses.first == "widowed"
        phrases << :married_woman_and_state_pension #outcome 6
      else
        phrases << :married_woman_no_state_pension #outcome 5
      end
    end
    phrases << :increase_retirement_income
    phrases
  end
  next_node :final_outcome
end

outcome :final_outcome
