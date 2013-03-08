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
  calculate :vehicle_tax_amount do
    responses.last
  end
end

#Q4 - is vehicle green?
multiple_choice :is_vehicle_green? do
  option :yes
  option :no

  calculate :vehicle_is_green do
    responses.last == "yes"
  end

  next_node :price_of_vehicle?
end

#Q5 - price of vehicle
value_question :price_of_vehicle? do
  # if green => take user input and store as [green_cost]
  # if dirty  => take 18% of user input and store as [dirty_cost]
  # if input > 250k store as [over_van_limit]
  calculate :vehicle_price do
    responses.last.gsub(",", "").to_f
  end

  calculate :green_vehicle_price do
    vehicle_is_green ? vehicle_price : nil
  end

  calculate :dirty_vehicle_price do
    vehicle_is_green ? nil : vehicle_price * 0.18
  end

  calculate :is_over_limit do
    vehicle_price > 250000.0
  end


  next_node :vehicle_private_use_time?

end

#Q6 - vehicle private use time
value_question :vehicle_private_use_time? do

end

#Q9 - how much do you claim?
value_question :current_claim_amount? do

end

#Q11 = how much do you deduct from premises for private use?
value_question :deduct_from_premises? do

end

outcome :you_cant_use_result


