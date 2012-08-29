status :draft
section_slug "money-and-tax"

## Q1
value_question :how_many_children_paid_for? do
  calculate :number_of_children do
    responses.last.to_i
  end
  next_node do |response|
    if response.to_i == 0
      raise SmartAnswer::InvalidResponse
    end
    :net_income_of_payee?
  end
end

## Q2
money_question :net_income_of_payee? do
  next_node do |response|
    if response <= 7
      :nil_rate_result
    elsif response <= 100
      :flat_rate_result
    else
      :how_many_children_in_payees_household?
    end
  end
end

## Q3
value_question :how_many_children_in_payees_household? do
  next_node :how_many_nights_children_stay_with_payee?
end

## Q4
multiple_choice :how_many_nights_children_stay_with_payee? do
  option "less-than-once-a-week"
  option "1-night-a-week"
  option "2-nights-a-week"
  option "3-nights-a-week"
  option "more-than-3-nights-a-week"
  next_node :reduced_and_basic_rates_result
end

outcome :nil_rate_result
outcome :flat_rate_result
outcome :reduced_and_basic_rates_result
