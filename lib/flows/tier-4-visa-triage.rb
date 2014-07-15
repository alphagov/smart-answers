status :draft
satisfies_need "00000"

# Q1
multiple_choice :extending_or_switching? do
  option :extend_general
  option :switch_general
  option :extend_child
  option :switch_child

  save_input_as :type_of_visa

  next_node(:sponsor_number?)
end

#Q2
value_question :sponsor_number? do
  save_input_as :sponsor_number
  next_node(:outcome1)
end

outcome :outcome1
outcome :outcome2
