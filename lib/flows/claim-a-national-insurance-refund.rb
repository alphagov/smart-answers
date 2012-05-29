satisfies_need "B148"
status :draft

multiple_choice :which_class? do
  save_input_as :ni_class

  option :class_1 => :outcome_1
  option :class_2 => :did_you_pay_when_you_didnt_need_to?
  option :class_3 => :outcome_2
  option :class_4 => :did_you_pay_when_you_didnt_need_to?
end

multiple_choice :did_you_pay_when_you_didnt_need_to? do
  option :yes
  option :no

  next_node do |response|
    case [ni_class.to_s, response.to_s]
    when ['class_2', 'yes']
      :outcome_5
    when ['class_2', 'no']
      :outcome_1a
    when ['class_4', 'yes']
      :outcome_3
    when ['class_4', 'no']
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
