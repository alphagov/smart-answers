satisfies_need "B148"

multiple_choice :which_class? do
  save_input_as :ni_class

  option :class_1 => :outcome_1
  option :class_2 => :why_are_you_applying_for_a_refund_class2?
  option :class_3 => :outcome_2
  option :class_4 => :why_are_you_applying_for_a_refund_class4?
end

multiple_choice :why_are_you_applying_for_a_refund_class2? do
  option :shouldnt_have_paid
  option :paid_too_much
  option :low_earnings_exemption

  next_node do |response|
    case [response.to_s]
    when ['shouldnt_have_paid']
      :outcome_5
    when ['paid_too_much']
      :outcome_1a
    when ['low_earnings_exemption']
      :outcome_6
    end
  end
end

multiple_choice :why_are_you_applying_for_a_refund_class4? do
  option :shouldnt_have_paid
  option :paid_too_much

  next_node do |response|
    case [response.to_s]
    when ['shouldnt_have_paid']
      :outcome_3
    when ['paid_too_much']
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
outcome :outcome_6
