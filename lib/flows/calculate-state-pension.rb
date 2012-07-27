status :draft
section_slug "money-and-tax"
subsection_slug "pension"
satisfies_need "99999"

multiple_choice :gender? do
  save_input_as :gender

  option :male
  option :female

  next_node :dob?
end

date_question :dob? do
  from { 100.years.ago }
  to { Date.today }

  save_input_as :dob

  next_node :qualifying_years?
end

value_question :qualifying_years? do
  save_input_as :qualifying_years

  calculate :calculator do
    Calculators::StatePensionAmountCalculator.new(gender: gender, dob: dob, qualifying_years: qualifying_years)
  end

  calculate :what_you_get do
    sprintf("%.2f", calculator.what_you_get)
  end

  calculate :state_pension_year do
    calculator.state_pension_year
  end

  calculate :you_get_future do
    sprintf("%.2f", calculator.you_get_future)
  end

  next_node :answer
end

outcome :answer