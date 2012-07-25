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

  calculate :calculator do
    Calculators::StatePensionAmountCalculator.new(gender: gender, dob: dob, qualifying_years: nil)
  end

  calculate :state_pension_age do
    calculator.state_pension_age
  end

  next_node :answer
end

outcome :answer