node_name = -> base_name do
  base_name_without_question_mark = base_name.to_s.sub(/\?$/, '')
  question_mark = (base_name.to_s =~ /\?$/) ? '?' : ''
  "#{base_name_without_question_mark}#{node_suffix}#{question_mark}".to_sym
end

# Q1
multiple_choice node_name[:receive_housing_benefit?] do
  option :yes
  option :no

  save_input_as :housing_benefit

  next_node do |response|
    if response == 'yes'
      question node_name[:working_tax_credit?]
    else
      outcome node_name[:outcome_not_affected_no_housing_benefit]
    end
  end
end

# Q2
multiple_choice node_name[:working_tax_credit?] do
  option :yes
  option :no

  next_node do |response|
    if response == 'yes'
      outcome node_name[:outcome_not_affected_exemptions]
    else
      question node_name[:receiving_exemption_benefits?]
    end
  end
end

#Q3
multiple_choice node_name[:receiving_exemption_benefits?] do
  option :yes
  option :no

  next_node do |response|
    if response == 'yes'
      outcome node_name[:outcome_not_affected_exemptions]
    else
      question node_name[:receiving_non_exemption_benefits?]
    end
  end
end

#Q4
checkbox_question node_name[:receiving_non_exemption_benefits?] do
  option :bereavement
  option :carers unless node_suffix == '_post_2016'
  option :child_benefit
  option :child_tax
  option :esa
  option :guardian unless node_suffix == '_post_2016'
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
      outcome node_name[:outcome_not_affected]
    else
      case benefit_types.shift
      when :bereavement then question node_name[:bereavement_amount?]
      when :carers then question node_name[:carers_amount?]
      when :child_benefit then question node_name[:child_benefit_amount?]
      when :child_tax then question node_name[:child_tax_amount?]
      when :esa then question node_name[:esa_amount?]
      when :guardian then question node_name[:guardian_amount?]
      when :incapacity then question node_name[:incapacity_amount?]
      when :income_support then question node_name[:income_support_amount?]
      when :jsa then question node_name[:jsa_amount?]
      when :maternity then question node_name[:maternity_amount?]
      when :sda then question node_name[:sda_amount?]
      when :widowed_mother then question node_name[:widowed_mother_amount?]
      when :widowed_parent then question node_name[:widowed_parent_amount?]
      when :widow_pension then question node_name[:widow_pension_amount?]
      when :widows_aged then question node_name[:widows_aged_amount?]
      else
        if housing_benefit == 'yes'
          question node_name[:housing_benefit_amount?]
        else
          question node_name[:single_couple_lone_parent?]
        end
      end
    end
  end
end

#Q5a
money_question node_name[:bereavement_amount?] do

  calculate :total_benefits do |response|
    total_benefits + response.to_f
  end

  next_node do
    case benefit_types.shift
    when :carers then question node_name[:carers_amount?]
    when :child_benefit then question node_name[:child_benefit_amount?]
    when :child_tax then question node_name[:child_tax_amount?]
    when :esa then question node_name[:esa_amount?]
    when :guardian then question node_name[:guardian_amount?]
    when :incapacity then question node_name[:incapacity_amount?]
    when :income_support then question node_name[:income_support_amount?]
    when :jsa then question node_name[:jsa_amount?]
    when :maternity then question node_name[:maternity_amount?]
    when :sda then question node_name[:sda_amount?]
    when :widowed_mother then question node_name[:widowed_mother_amount?]
    when :widowed_parent then question node_name[:widowed_parent_amount?]
    when :widow_pension then question node_name[:widow_pension_amount?]
    when :widows_aged then question node_name[:widows_aged_amount?]
    else
      if housing_benefit == 'yes'
        question node_name[:housing_benefit_amount?]
      else
        question node_name[:single_couple_lone_parent?]
      end
    end
  end
end

unless node_suffix == '_post_2016'
  #Q5b
  money_question node_name[:carers_amount?] do

    calculate :total_benefits do |response|
      total_benefits + response.to_f
    end

    next_node do
      case benefit_types.shift
      when :child_benefit then question node_name[:child_benefit_amount?]
      when :child_tax then question node_name[:child_tax_amount?]
      when :esa then question node_name[:esa_amount?]
      when :guardian then question node_name[:guardian_amount?]
      when :incapacity then question node_name[:incapacity_amount?]
      when :income_support then question node_name[:income_support_amount?]
      when :jsa then question node_name[:jsa_amount?]
      when :maternity then question node_name[:maternity_amount?]
      when :sda then question node_name[:sda_amount?]
      when :widowed_mother then question node_name[:widowed_mother_amount?]
      when :widowed_parent then question node_name[:widowed_parent_amount?]
      when :widow_pension then question node_name[:widow_pension_amount?]
      when :widows_aged then question node_name[:widows_aged_amount?]
      else
        if housing_benefit == 'yes'
          question node_name[:housing_benefit_amount?]
        else
          question node_name[:single_couple_lone_parent?]
        end
      end
    end
  end
end

#Q5c
money_question node_name[:child_benefit_amount?] do

  calculate :total_benefits do |response|
    total_benefits + response.to_f
  end

  next_node do
    case benefit_types.shift
    when :child_tax then question node_name[:child_tax_amount?]
    when :esa then question node_name[:esa_amount?]
    when :guardian then question node_name[:guardian_amount?]
    when :incapacity then question node_name[:incapacity_amount?]
    when :income_support then question node_name[:income_support_amount?]
    when :jsa then question node_name[:jsa_amount?]
    when :maternity then question node_name[:maternity_amount?]
    when :sda then question node_name[:sda_amount?]
    when :widowed_mother then question node_name[:widowed_mother_amount?]
    when :widowed_parent then question node_name[:widowed_parent_amount?]
    when :widow_pension then question node_name[:widow_pension_amount?]
    when :widows_aged then question node_name[:widows_aged_amount?]
    else
      if housing_benefit == 'yes'
        question node_name[:housing_benefit_amount?]
      else
        question node_name[:single_couple_lone_parent?]
      end
    end
  end
end

#Q5d
money_question node_name[:child_tax_amount?] do

  calculate :total_benefits do |response|
    total_benefits + response.to_f
  end

  next_node do
    case benefit_types.shift
    when :esa then question node_name[:esa_amount?]
    when :guardian then question node_name[:guardian_amount?]
    when :incapacity then question node_name[:incapacity_amount?]
    when :income_support then question node_name[:income_support_amount?]
    when :jsa then question node_name[:jsa_amount?]
    when :maternity then question node_name[:maternity_amount?]
    when :sda then question node_name[:sda_amount?]
    when :widowed_mother then question node_name[:widowed_mother_amount?]
    when :widowed_parent then question node_name[:widowed_parent_amount?]
    when :widow_pension then question node_name[:widow_pension_amount?]
    when :widows_aged then question node_name[:widows_aged_amount?]
    else
      if housing_benefit == 'yes'
        question node_name[:housing_benefit_amount?]
      else
        question node_name[:single_couple_lone_parent?]
      end
    end
  end
end

#Q5e
money_question node_name[:esa_amount?] do

  calculate :total_benefits do |response|
    total_benefits + response.to_f
  end

  next_node do
    case benefit_types.shift
    when :guardian then question node_name[:guardian_amount?]
    when :incapacity then question node_name[:incapacity_amount?]
    when :income_support then question node_name[:income_support_amount?]
    when :jsa then question node_name[:jsa_amount?]
    when :maternity then question node_name[:maternity_amount?]
    when :sda then question node_name[:sda_amount?]
    when :widowed_mother then question node_name[:widowed_mother_amount?]
    when :widowed_parent then question node_name[:widowed_parent_amount?]
    when :widow_pension then question node_name[:widow_pension_amount?]
    when :widows_aged then question node_name[:widows_aged_amount?]
    else
      if housing_benefit == 'yes'
        question node_name[:housing_benefit_amount?]
      else
        question node_name[:single_couple_lone_parent?]
      end
    end
  end
end

unless node_suffix == '_post_2016'
  #Q5f
  money_question node_name[:guardian_amount?] do

    calculate :total_benefits do |response|
      total_benefits + response.to_f
    end

    next_node do
      case benefit_types.shift
      when :incapacity then question node_name[:incapacity_amount?]
      when :income_support then question node_name[:income_support_amount?]
      when :jsa then question node_name[:jsa_amount?]
      when :maternity then question node_name[:maternity_amount?]
      when :sda then question node_name[:sda_amount?]
      when :widowed_mother then question node_name[:widowed_mother_amount?]
      when :widowed_parent then question node_name[:widowed_parent_amount?]
      when :widow_pension then question node_name[:widow_pension_amount?]
      when :widows_aged then question node_name[:widows_aged_amount?]
      else
        if housing_benefit == 'yes'
          question node_name[:housing_benefit_amount?]
        else
          question node_name[:single_couple_lone_parent?]
        end
      end
    end
  end
end

#Q5g
money_question node_name[:incapacity_amount?] do

  calculate :total_benefits do |response|
    total_benefits + response.to_f
  end

  next_node do
    case benefit_types.shift
    when :income_support then question node_name[:income_support_amount?]
    when :jsa then question node_name[:jsa_amount?]
    when :maternity then question node_name[:maternity_amount?]
    when :sda then question node_name[:sda_amount?]
    when :widowed_mother then question node_name[:widowed_mother_amount?]
    when :widowed_parent then question node_name[:widowed_parent_amount?]
    when :widow_pension then question node_name[:widow_pension_amount?]
    when :widows_aged then question node_name[:widows_aged_amount?]
    else
      if housing_benefit == 'yes'
        question node_name[:housing_benefit_amount?]
      else
        question node_name[:single_couple_lone_parent?]
      end
    end
  end
end

#Q5h
money_question node_name[:income_support_amount?] do

  calculate :total_benefits do |response|
    total_benefits + response.to_f
  end

  next_node do
    case benefit_types.shift
    when :jsa then question node_name[:jsa_amount?]
    when :maternity then question node_name[:maternity_amount?]
    when :sda then question node_name[:sda_amount?]
    when :widowed_mother then question node_name[:widowed_mother_amount?]
    when :widowed_parent then question node_name[:widowed_parent_amount?]
    when :widow_pension then question node_name[:widow_pension_amount?]
    when :widows_aged then question node_name[:widows_aged_amount?]
    else
      if housing_benefit == 'yes'
        question node_name[:housing_benefit_amount?]
      else
        question node_name[:single_couple_lone_parent?]
      end
    end
  end
end

#Q5i
money_question node_name[:jsa_amount?] do

  calculate :total_benefits do |response|
    total_benefits + response.to_f
  end

  next_node do
    case benefit_types.shift
    when :maternity then question node_name[:maternity_amount?]
    when :sda then question node_name[:sda_amount?]
    when :widowed_mother then question node_name[:widowed_mother_amount?]
    when :widowed_parent then question node_name[:widowed_parent_amount?]
    when :widow_pension then question node_name[:widow_pension_amount?]
    when :widows_aged then question node_name[:widows_aged_amount?]
    else
      if housing_benefit == 'yes'
        question node_name[:housing_benefit_amount?]
      else
        question node_name[:single_couple_lone_parent?]
      end
    end
  end
end

#Q5j
money_question node_name[:maternity_amount?] do

  calculate :total_benefits do |response|
    total_benefits + response.to_f
  end

  next_node do
    case benefit_types.shift
    when :sda then question node_name[:sda_amount?]
    when :widowed_mother then question node_name[:widowed_mother_amount?]
    when :widowed_parent then question node_name[:widowed_parent_amount?]
    when :widow_pension then question node_name[:widow_pension_amount?]
    when :widows_aged then question node_name[:widows_aged_amount?]
    else
      if housing_benefit == 'yes'
        question node_name[:housing_benefit_amount?]
      else
        question node_name[:single_couple_lone_parent?]
      end
    end
  end
end

#Q5k
money_question node_name[:sda_amount?] do

  calculate :total_benefits do |response|
    total_benefits + response.to_f
  end

  next_node do
    case benefit_types.shift
    when :widowed_mother then question node_name[:widowed_mother_amount?]
    when :widowed_parent then question node_name[:widowed_parent_amount?]
    when :widow_pension then question node_name[:widow_pension_amount?]
    when :widows_aged then question node_name[:widows_aged_amount?]
    else
      if housing_benefit == 'yes'
        question node_name[:housing_benefit_amount?]
      else
        question node_name[:single_couple_lone_parent?]
      end
    end
  end
end

#Q5n
money_question node_name[:widow_pension_amount?] do

  calculate :total_benefits do |response|
    total_benefits + response.to_f
  end

  next_node do
    case benefit_types.shift
    when :widowed_mother then question node_name[:widowed_mother_amount?]
    when :widowed_parent then question node_name[:widowed_parent_amount?]
    when :widows_aged then question node_name[:widows_aged_amount?]
    else
      if housing_benefit == 'yes'
        question node_name[:housing_benefit_amount?]
      else
        question node_name[:single_couple_lone_parent?]
      end
    end
  end
end

#Q5l
money_question node_name[:widowed_mother_amount?] do

  calculate :total_benefits do |response|
    total_benefits + response.to_f
  end

  next_node do
    case benefit_types.shift
    when :widowed_parent then question node_name[:widowed_parent_amount?]
    when :widows_aged then question node_name[:widows_aged_amount?]
    else
      if housing_benefit == 'yes'
        question node_name[:housing_benefit_amount?]
      else
        question node_name[:single_couple_lone_parent?]
      end
    end
  end
end

#Q5m
money_question node_name[:widowed_parent_amount?] do

  calculate :total_benefits do |response|
    total_benefits + response.to_f
  end

  next_node do
    case benefit_types.shift
    when :widows_aged then question node_name[:widows_aged_amount?]
    else
      if housing_benefit == 'yes'
        question node_name[:housing_benefit_amount?]
      else
        question node_name[:single_couple_lone_parent?]
      end
    end
  end
end

#Q5o
money_question node_name[:widows_aged_amount?] do

  calculate :total_benefits do |response|
    total_benefits + response.to_f
  end

  next_node do
    if housing_benefit == 'yes'
      question node_name[:housing_benefit_amount?]
    else
      question node_name[:single_couple_lone_parent?]
    end
  end
end

#Q5p
money_question node_name[:housing_benefit_amount?] do
  save_input_as :housing_benefit_amount

  calculate :total_benefits do |response|
    total_benefits + response.to_f
  end

  next_node do
    question node_name[:single_couple_lone_parent?]
  end
end

#Q6
multiple_choice node_name[:single_couple_lone_parent?] do
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
      outcome node_name[:outcome_affected_greater_than_cap]
    else
      outcome node_name[:outcome_not_affected_less_than_cap]
    end
  end
end

##OUTCOMES

## Outcome 1
outcome node_name[:outcome_not_affected_exemptions]

## Outcome 2
outcome node_name[:outcome_not_affected_no_housing_benefit]

## Outcome 3
outcome node_name[:outcome_affected_greater_than_cap] do
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
outcome node_name[:outcome_not_affected_less_than_cap] do
  precalculate :total_benefits do
    sprintf("%.2f", total_benefits)
  end
end

## Outcome 5
outcome node_name[:outcome_not_affected]
