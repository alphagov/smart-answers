satisfies_need 177
section "Education"

money_question :how_much_is_your_tution_fee_per_year? do
  next_node :how_much_do_your_parents_earn?
  save_input_as :tuition_fee_amount
end

multiple_choice :how_much_do_your_parents_earn? do
  option "less than 25k per yr"
  option "more than 43k per yr"
  next_node :where_will_you_live_when_studying?
end

multiple_choice :where_will_you_live_when_studying? do
  option "at home with my parents"
  option "away from home, outside of London"
  option "away from home, in London"

  calculate :maintenance_loan_amount do |response|
    case response
    when /at home/ then Money.new("4375")
    when /outside of London/ then Money.new("5500")
    when /in London/ then Money.new("7675")
    else
      Money.new("4375")
      # raise SmartAnswer::InvalidResponse
    end
  end
  next_node :do_you_have_any_children?
end

multiple_choice :do_you_have_any_children? do
  option :yes
  option :no
  next_node :do_you_have_any_adults_dependent_on_you_financially?
end

multiple_choice :do_you_have_any_adults_dependent_on_you_financially? do
  option :yes
  option :no
  next_node :are_you_disabled?
end

multiple_choice :are_you_disabled? do
  option :yes
  option :no
  next_node :are_you_in_financial_hardship?
end

multiple_choice :are_you_in_financial_hardship? do
  option :yes
  option :no
  next_node :will_you_be_studying_to_be_a_teacher?
end

multiple_choice :will_you_be_studying_to_be_a_teacher? do
  option :yes
  option :no
  next_node :will_you_be_studying_on_a_medical_or_social_work_course?
end

multiple_choice :will_you_be_studying_on_a_medical_or_social_work_course? do
  option :yes
  option :no
  next_node :done
end

outcome :done
