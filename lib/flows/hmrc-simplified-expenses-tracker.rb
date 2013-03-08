status :draft

#Q1 - new or existing business
multiple_choice :new_or_existing_business? do
  option :new
  option :existing

  save_input_as :new_or_existing_business

  calculate :is_new_business do
    new_or_existing_business == "new"
  end

  calculate :is_existing_business do
    !is_new_business
  end

  next_node :type_of_expense?
end

#Q2 - type of expense
checkbox_question :type_of_expense? do
  option :car_or_van
  option :motorcycle
  option :using_home_for_business
  option :live_on_business_premises
  option :none_of_these

  calculate :list_of_expenses do
    responses.last.split(",")
  end

  next_node do |response|
    next_question = nil
    responses = response.split(",")
    if (responses & ["car_or_van", "motorcycle"]).size > 0
      is_existing_business ? :how_much_write_off_tax? : :is_vehicle_green?
    else
      if responses.include?("using_home_for_business")
        :current_claim_amount?
      elsif responses.include?("live_on_business_premises")
        :deduct_from_premises?
      else
        # at this point they must have only picked none_of_these
        :you_cant_use_result
      end
    end
  end
end

#Q3 - write off tax
value_question :how_much_write_off_tax? do

end

#Q4 - is vehicle green?
multiple_choice :is_vehicle_green? do
  option :yes
  option :no
end

#Q9 - how much do you claim?
value_question :current_claim_amount? do

end

#Q11 = how much do you deduct from premises for private use?
value_question :deduct_from_premises? do

end

outcome :you_cant_use_result


