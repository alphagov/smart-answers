satisfies_need "B148"
status :draft
section_slug "money-and-tax"

multiple_choice :which_class? do
  save_input_as :ni_class

  option :class_1 => :outcome_1
  option :class_2 => :why_are_you_applying_for_a_refund?
  option :class_3 => :outcome_2
  option :class_4 => :why_are_you_applying_for_a_refund?
end

multiple_choice :why_are_you_applying_for_a_refund? do
  option :shouldnt_have_paid
  option :paid_too_much

  next_node do |response|
    case [ni_class.to_s, response.to_s]
    when ['class_2', 'shouldnt_have_paid']
      :outcome_5
    when ['class_2', 'paid_too_much']
      :outcome_1a
    when ['class_4', 'shouldnt_have_paid']
      :outcome_3
    when ['class_4', 'paid_too_much']
      :outcome_4
    end
  end
end

outcome :outcome_1
outcome :outcome_1a
outcome :outcome_2
outcome :outcome_3
outcome :outcome_4
outcome :outcome_5
