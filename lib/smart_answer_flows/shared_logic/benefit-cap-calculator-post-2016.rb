# Q1
multiple_choice :receive_housing_benefit_post_2016? do
  option :yes
  option :no

  save_input_as :housing_benefit

  next_node do |response|
    if response == 'yes'
      question :working_tax_credit_post_2016?
    else
      outcome :outcome_not_affected_no_housing_benefit_post_2016
    end
  end
end

# Q2
multiple_choice :working_tax_credit_post_2016? do
  option :yes
  option :no

  next_node do |response|
    if response == 'yes'
      outcome :outcome_not_affected_exemptions_post_2016
    else
      question :receiving_exemption_benefits_post_2016?
    end
  end
end

#Q3
multiple_choice :receiving_exemption_benefits_post_2016? do
  option :yes
  option :no

  next_node do |response|
    if response == 'yes'
      outcome :outcome_not_affected_exemptions_post_2016
    else
      question :receiving_non_exemption_benefits_post_2016?
    end
  end
end

#Q4
checkbox_question :receiving_non_exemption_benefits_post_2016? do
  option :bereavement
  option :carers
  option :child_benefit
  option :child_tax
  option :esa
  option :guardian
  option :incapacity
  option :income_support
  option :jsa
  option :maternity
  option :sda
  option :widowed_mother
  option :widowed_parent
  option :widow_pension
  option :widows_aged

  next_node_calculation :benefit_types do |response|
    response.split(",").map(&:to_sym)
  end

  calculate :total_benefits do
    0
  end

  calculate :benefit_cap do
    0
  end

  next_node do |response|
    if response == "none"
      outcome :outcome_not_affected_post_2016
    else
      case benefit_types.shift
      when :bereavement then question :bereavement_amount_post_2016?
      when :carers then question :carers_amount_post_2016?
      when :child_benefit then question :child_benefit_amount_post_2016?
      when :child_tax then question :child_tax_amount_post_2016?
      when :esa then question :esa_amount_post_2016?
      when :guardian then question :guardian_amount_post_2016?
      when :incapacity then question :incapacity_amount_post_2016?
      when :income_support then question :income_support_amount_post_2016?
      when :jsa then question :jsa_amount_post_2016?
      when :maternity then question :maternity_amount_post_2016?
      when :sda then question :sda_amount_post_2016?
      when :widowed_mother then question :widowed_mother_amount_post_2016?
      when :widowed_parent then question :widowed_parent_amount_post_2016?
      when :widow_pension then question :widow_pension_amount_post_2016?
      when :widows_aged then question :widows_aged_amount_post_2016?
      else
        if housing_benefit == 'yes'
          question :housing_benefit_amount_post_2016?
        else
          question :single_couple_lone_parent_post_2016?
        end
      end
    end
  end
end

#Q5a
money_question :bereavement_amount_post_2016? do

  calculate :total_benefits do |response|
    total_benefits + response.to_f
  end

  next_node do
    case benefit_types.shift
    when :carers then question :carers_amount_post_2016?
    when :child_benefit then question :child_benefit_amount_post_2016?
    when :child_tax then question :child_tax_amount_post_2016?
    when :esa then question :esa_amount_post_2016?
    when :guardian then question :guardian_amount_post_2016?
    when :incapacity then question :incapacity_amount_post_2016?
    when :income_support then question :income_support_amount_post_2016?
    when :jsa then question :jsa_amount_post_2016?
    when :maternity then question :maternity_amount_post_2016?
    when :sda then question :sda_amount_post_2016?
    when :widowed_mother then question :widowed_mother_amount_post_2016?
    when :widowed_parent then question :widowed_parent_amount_post_2016?
    when :widow_pension then question :widow_pension_amount_post_2016?
    when :widows_aged then question :widows_aged_amount_post_2016?
    else
      if housing_benefit == 'yes'
        question :housing_benefit_amount_post_2016?
      else
        question :single_couple_lone_parent_post_2016?
      end
    end
  end
end

#Q5b
money_question :carers_amount_post_2016? do

  calculate :total_benefits do |response|
    total_benefits + response.to_f
  end

  next_node do
    case benefit_types.shift
    when :child_benefit then question :child_benefit_amount_post_2016?
    when :child_tax then question :child_tax_amount_post_2016?
    when :esa then question :esa_amount_post_2016?
    when :guardian then question :guardian_amount_post_2016?
    when :incapacity then question :incapacity_amount_post_2016?
    when :income_support then question :income_support_amount_post_2016?
    when :jsa then question :jsa_amount_post_2016?
    when :maternity then question :maternity_amount_post_2016?
    when :sda then question :sda_amount_post_2016?
    when :widowed_mother then question :widowed_mother_amount_post_2016?
    when :widowed_parent then question :widowed_parent_amount_post_2016?
    when :widow_pension then question :widow_pension_amount_post_2016?
    when :widows_aged then question :widows_aged_amount_post_2016?
    else
      if housing_benefit == 'yes'
        question :housing_benefit_amount_post_2016?
      else
        question :single_couple_lone_parent_post_2016?
      end
    end
  end
end

#Q5c
money_question :child_benefit_amount_post_2016? do

  calculate :total_benefits do |response|
    total_benefits + response.to_f
  end

  next_node do
    case benefit_types.shift
    when :child_tax then question :child_tax_amount_post_2016?
    when :esa then question :esa_amount_post_2016?
    when :guardian then question :guardian_amount_post_2016?
    when :incapacity then question :incapacity_amount_post_2016?
    when :income_support then question :income_support_amount_post_2016?
    when :jsa then question :jsa_amount_post_2016?
    when :maternity then question :maternity_amount_post_2016?
    when :sda then question :sda_amount_post_2016?
    when :widowed_mother then question :widowed_mother_amount_post_2016?
    when :widowed_parent then question :widowed_parent_amount_post_2016?
    when :widow_pension then question :widow_pension_amount_post_2016?
    when :widows_aged then question :widows_aged_amount_post_2016?
    else
      if housing_benefit == 'yes'
        question :housing_benefit_amount_post_2016?
      else
        question :single_couple_lone_parent_post_2016?
      end
    end
  end
end

#Q5d
money_question :child_tax_amount_post_2016? do

  calculate :total_benefits do |response|
    total_benefits + response.to_f
  end

  next_node do
    case benefit_types.shift
    when :esa then question :esa_amount_post_2016?
    when :guardian then question :guardian_amount_post_2016?
    when :incapacity then question :incapacity_amount_post_2016?
    when :income_support then question :income_support_amount_post_2016?
    when :jsa then question :jsa_amount_post_2016?
    when :maternity then question :maternity_amount_post_2016?
    when :sda then question :sda_amount_post_2016?
    when :widowed_mother then question :widowed_mother_amount_post_2016?
    when :widowed_parent then question :widowed_parent_amount_post_2016?
    when :widow_pension then question :widow_pension_amount_post_2016?
    when :widows_aged then question :widows_aged_amount_post_2016?
    else
      if housing_benefit == 'yes'
        question :housing_benefit_amount_post_2016?
      else
        question :single_couple_lone_parent_post_2016?
      end
    end
  end
end

#Q5e
money_question :esa_amount_post_2016? do

  calculate :total_benefits do |response|
    total_benefits + response.to_f
  end

  next_node do
    case benefit_types.shift
    when :guardian then question :guardian_amount_post_2016?
    when :incapacity then question :incapacity_amount_post_2016?
    when :income_support then question :income_support_amount_post_2016?
    when :jsa then question :jsa_amount_post_2016?
    when :maternity then question :maternity_amount_post_2016?
    when :sda then question :sda_amount_post_2016?
    when :widowed_mother then question :widowed_mother_amount_post_2016?
    when :widowed_parent then question :widowed_parent_amount_post_2016?
    when :widow_pension then question :widow_pension_amount_post_2016?
    when :widows_aged then question :widows_aged_amount_post_2016?
    else
      if housing_benefit == 'yes'
        question :housing_benefit_amount_post_2016?
      else
        question :single_couple_lone_parent_post_2016?
      end
    end
  end
end

#Q5f
money_question :guardian_amount_post_2016? do

  calculate :total_benefits do |response|
    total_benefits + response.to_f
  end

  next_node do
    case benefit_types.shift
    when :incapacity then question :incapacity_amount_post_2016?
    when :income_support then question :income_support_amount_post_2016?
    when :jsa then question :jsa_amount_post_2016?
    when :maternity then question :maternity_amount_post_2016?
    when :sda then question :sda_amount_post_2016?
    when :widowed_mother then question :widowed_mother_amount_post_2016?
    when :widowed_parent then question :widowed_parent_amount_post_2016?
    when :widow_pension then question :widow_pension_amount_post_2016?
    when :widows_aged then question :widows_aged_amount_post_2016?
    else
      if housing_benefit == 'yes'
        question :housing_benefit_amount_post_2016?
      else
        question :single_couple_lone_parent_post_2016?
      end
    end
  end
end

#Q5g
money_question :incapacity_amount_post_2016? do

  calculate :total_benefits do |response|
    total_benefits + response.to_f
  end

  next_node do
    case benefit_types.shift
    when :income_support then question :income_support_amount_post_2016?
    when :jsa then question :jsa_amount_post_2016?
    when :maternity then question :maternity_amount_post_2016?
    when :sda then question :sda_amount_post_2016?
    when :widowed_mother then question :widowed_mother_amount_post_2016?
    when :widowed_parent then question :widowed_parent_amount_post_2016?
    when :widow_pension then question :widow_pension_amount_post_2016?
    when :widows_aged then question :widows_aged_amount_post_2016?
    else
      if housing_benefit == 'yes'
        question :housing_benefit_amount_post_2016?
      else
        question :single_couple_lone_parent_post_2016?
      end
    end
  end
end

#Q5h
money_question :income_support_amount_post_2016? do

  calculate :total_benefits do |response|
    total_benefits + response.to_f
  end

  next_node do
    case benefit_types.shift
    when :jsa then question :jsa_amount_post_2016?
    when :maternity then question :maternity_amount_post_2016?
    when :sda then question :sda_amount_post_2016?
    when :widowed_mother then question :widowed_mother_amount_post_2016?
    when :widowed_parent then question :widowed_parent_amount_post_2016?
    when :widow_pension then question :widow_pension_amount_post_2016?
    when :widows_aged then question :widows_aged_amount_post_2016?
    else
      if housing_benefit == 'yes'
        question :housing_benefit_amount_post_2016?
      else
        question :single_couple_lone_parent_post_2016?
      end
    end
  end
end

#Q5i
money_question :jsa_amount_post_2016? do

  calculate :total_benefits do |response|
    total_benefits + response.to_f
  end

  next_node do
    case benefit_types.shift
    when :maternity then question :maternity_amount_post_2016?
    when :sda then question :sda_amount_post_2016?
    when :widowed_mother then question :widowed_mother_amount_post_2016?
    when :widowed_parent then question :widowed_parent_amount_post_2016?
    when :widow_pension then question :widow_pension_amount_post_2016?
    when :widows_aged then question :widows_aged_amount_post_2016?
    else
      if housing_benefit == 'yes'
        question :housing_benefit_amount_post_2016?
      else
        question :single_couple_lone_parent_post_2016?
      end
    end
  end
end

#Q5j
money_question :maternity_amount_post_2016? do

  calculate :total_benefits do |response|
    total_benefits + response.to_f
  end

  next_node do
    case benefit_types.shift
    when :sda then question :sda_amount_post_2016?
    when :widowed_mother then question :widowed_mother_amount_post_2016?
    when :widowed_parent then question :widowed_parent_amount_post_2016?
    when :widow_pension then question :widow_pension_amount_post_2016?
    when :widows_aged then question :widows_aged_amount_post_2016?
    else
      if housing_benefit == 'yes'
        question :housing_benefit_amount_post_2016?
      else
        question :single_couple_lone_parent_post_2016?
      end
    end
  end
end

#Q5k
money_question :sda_amount_post_2016? do

  calculate :total_benefits do |response|
    total_benefits + response.to_f
  end

  next_node do
    case benefit_types.shift
    when :widowed_mother then question :widowed_mother_amount_post_2016?
    when :widowed_parent then question :widowed_parent_amount_post_2016?
    when :widow_pension then question :widow_pension_amount_post_2016?
    when :widows_aged then question :widows_aged_amount_post_2016?
    else
      if housing_benefit == 'yes'
        question :housing_benefit_amount_post_2016?
      else
        question :single_couple_lone_parent_post_2016?
      end
    end
  end
end

#Q5n
money_question :widow_pension_amount_post_2016? do

  calculate :total_benefits do |response|
    total_benefits + response.to_f
  end

  next_node do
    case benefit_types.shift
    when :widowed_mother then question :widowed_mother_amount_post_2016?
    when :widowed_parent then question :widowed_parent_amount_post_2016?
    when :widows_aged then question :widows_aged_amount_post_2016?
    else
      if housing_benefit == 'yes'
        question :housing_benefit_amount_post_2016?
      else
        question :single_couple_lone_parent_post_2016?
      end
    end
  end
end

#Q5l
money_question :widowed_mother_amount_post_2016? do

  calculate :total_benefits do |response|
    total_benefits + response.to_f
  end

  next_node do
    case benefit_types.shift
    when :widowed_parent then question :widowed_parent_amount_post_2016?
    when :widows_aged then question :widows_aged_amount_post_2016?
    else
      if housing_benefit == 'yes'
        question :housing_benefit_amount_post_2016?
      else
        question :single_couple_lone_parent_post_2016?
      end
    end
  end
end

#Q5m
money_question :widowed_parent_amount_post_2016? do

  calculate :total_benefits do |response|
    total_benefits + response.to_f
  end

  next_node do
    case benefit_types.shift
    when :widows_aged then question :widows_aged_amount_post_2016?
    else
      if housing_benefit == 'yes'
        question :housing_benefit_amount_post_2016?
      else
        question :single_couple_lone_parent_post_2016?
      end
    end
  end
end

#Q5o
money_question :widows_aged_amount_post_2016? do

  calculate :total_benefits do |response|
    total_benefits + response.to_f
  end

  next_node do
    if housing_benefit == 'yes'
      question :housing_benefit_amount_post_2016?
    else
      question :single_couple_lone_parent_post_2016?
    end
  end
end

#Q5p
money_question :housing_benefit_amount_post_2016? do
  save_input_as :housing_benefit_amount

  calculate :total_benefits do |response|
    total_benefits + response.to_f
  end

  next_node do
    question :single_couple_lone_parent_post_2016?
  end
end

#Q6
multiple_choice :single_couple_lone_parent_post_2016? do
  option :single
  option :couple
  option :parent

  calculate :benefit_cap do |response|
    if response == 'single'
      benefit_cap = 350
    else
      benefit_cap = 500
    end
    sprintf("%.2f", benefit_cap)
  end

  next_node do |response|
    if response == 'single'
      cap = 350
    else
      cap = 500
    end

    if total_benefits > cap
      outcome :outcome_affected_greater_than_cap_post_2016
    else
      outcome :outcome_not_affected_less_than_cap_post_2016
    end
  end
end

##OUTCOMES

## Outcome 1
outcome :outcome_not_affected_exemptions_post_2016

## Outcome 2
outcome :outcome_not_affected_no_housing_benefit_post_2016

## Outcome 3
outcome :outcome_affected_greater_than_cap_post_2016 do
  precalculate :total_benefits do
    sprintf("%.2f", total_benefits)
  end

  precalculate :housing_benefit_amount do
    sprintf("%.2f", housing_benefit_amount)
  end

  precalculate :total_over_cap do
    sprintf("%.2f", (total_benefits.to_f - benefit_cap.to_f))
  end

  precalculate :new_housing_benefit_amount do
    housing_benefit_amount.to_f - total_over_cap.to_f
  end

  precalculate :new_housing_benefit do
    amount = sprintf("%.2f", new_housing_benefit_amount)
    if amount < "0.5"
      amount = sprintf("%.2f", 0.5)
    end
    amount
  end
end

## Outcome 4
outcome :outcome_not_affected_less_than_cap_post_2016 do
  precalculate :total_benefits do
    sprintf("%.2f", total_benefits)
  end
end

## Outcome 5
outcome :outcome_not_affected_post_2016
