status :draft

salary_question :how_much_do_you_earn? do
  save_input_as :salary
  calculate :annual_salary do
    Money.new(salary.per_week * 52)
  end
  next_node :what_size_bonus_do_you_want?
end

money_question :what_size_bonus_do_you_want? do
  save_input_as :requested_bonus
  next_node :ok
end

outcome :ok
