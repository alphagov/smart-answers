status :draft

multiple_choice :question_one? do
  option :foo
  option :bar

  next_node :done
end

outcome :done
