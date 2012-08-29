status :draft
section_slug "money-and-tax"
subsection_slug "tax"
satisfies_need "2013"

# Q1
multiple_choice :what_would_you_like_to_check? do
  option "current_payment" => :are_you_an_apprentice?
  option "past_payment" => :past_payment_date?
  save_input_as :current_or_past_payments
end
