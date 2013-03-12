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
        :current_claim_amount_home?
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
money_question :how_much_write_off_tax? do
  save_input_as :vehicle_tax_amount

  next_node do
    list_of_expenses.include?("car_or_van") ? :drive_business_miles_car_van? : :drive_business_miles_motorcycle?
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
money_question :price_of_vehicle? do
  # if green => take user input and store as [green_cost]
  # if dirty  => take 18% of user input and store as [dirty_cost]
  # if input > 250k store as [over_van_limit]
  save_input_as :vehicle_price

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
  # deduct percentage amount from [green_cost] or [dirty_cost] and store as [green_write_off] or [dirty_write_off]
  calculate :private_use_percent do
    responses.last.gsub("%", "").to_f
  end
  calculate :green_vehicle_write_off do
    vehicle_is_green ? Money.new(green_vehicle_price * ( private_use_percent / 100 )) : nil
  end

  calculate :dirty_vehicle_write_off do
    vehicle_is_green ? nil : Money.new(dirty_vehicle_price * ( private_use_percent / 100 ))
  end

  next_node do
    list_of_expenses.include?("car_or_van") ?
      :drive_business_miles_car_van? : :drive_business_miles_motorcycle?
  end
end

#Q7 - miles to drive for business car_or_van
value_question :drive_business_miles_car_van? do
  # Calculation:
  # [user input 1-10,000] x 0.45
  # [user input > 10,001]  x 0.25
  calculate :simple_vehicle_costs do
    answer = responses.last.gsub(",", "").to_f
    if answer <= 10000
      Money.new(answer * 0.45)
    else
      answer_over_amount = (answer - 10000) * 0.25
      Money.new(4500.0 + answer_over_amount)
    end
  end
  next_node do
    if list_of_expenses.include?("motorcycle")
      :drive_business_miles_motorcycle?
    else
      if list_of_expenses.include?("using_home_for_business")
        :current_claim_amount_home?
      else
        :you_can_use_result
      end
    end
  end
end

#Q8 - miles to drive for business motorcycle
value_question :drive_business_miles_motorcycle? do
  calculate :simple_motorcycle_costs do
    Money.new(responses.last.gsub(",","").to_f * 0.24)
  end
  next_node do
    if list_of_expenses.include?("using_home_for_business")
      :current_claim_amount_home?
    elsif list_of_expenses.include?("live_on_business_premises")
      :deduct_from_premises?
    else
      :you_can_use_result
    end
  end
end

#Q9 - how much do you claim?
money_question :current_claim_amount_home? do
  save_input_as :home_costs

  next_node :hours_work_home?

end

#Q10 - hours for home work
value_question :hours_work_home? do
  calculate :hours_worked_home do
    responses.last.gsub(",","").to_f
  end

  calculate :simple_home_costs do
    amount = case hours_worked_home
    when 0..24 then 0
    when 25..50 then hours_worked_home * 10
    when 51..100 then hours_worked_home * 18
    else hours_worked_home * 26
    end
    Money.new(amount)
  end

  next_node do
    list_of_expenses.include?("live_on_business_premises") ? :deduct_from_premises? : :you_can_use_result
  end
end

#Q11 = how much do you deduct from premises for private use?
money_question :deduct_from_premises? do
  save_input_as :business_premises_cost

  next_node :people_live_on_premises?
end

#Q12 - people who live on business premises?
value_question :people_live_on_premises? do
  calculate :live_on_premises do
    responses.last.to_i
  end

  calculate :simple_business_costs do
    amount = case live_on_premises
    when 0 then 0
    when 1 then 350
    when 2 then 1000
    else live_on_premises * 650
    end

    Money.new(amount)
  end

  next_node :you_can_use_result
end


outcome :you_cant_use_result
outcome :you_can_use_result do
  precalculate :simple_costs do

    vehicle = simple_vehicle_costs.to_f || 0
    motorcycle = simple_motorcycle_costs.to_f || 0
    home = simple_home_costs.to_f || 0
    business = simple_business_costs.to_f || 0

    Money.new(vehicle + motorcycle + home + business)
  end

  precalculate :current_scheme_costs do
    vehicle = vehicle_tax_amount.to_f || 0
    green = green_vehicle_write_off.to_f || 0
    dirty = dirty_vehicle_write_off.to_f || 0
    home = home_costs.to_f || 0
    business = business_premises_cost.to_f || 0
    Money.new(vehicle + green + dirty + home + business)
  end

  precalculate :can_use_simple do
    simple_costs > current_scheme_costs
  end

  precalculate :result_title do
    PhraseList.new( can_use_simple ? :simplified_title : :current_title )
  end

  precalculate :simplified_bullets do
    bullets = PhraseList.new
    bullets << :simple_vehicle_costs_bullet unless simple_vehicle_costs.to_f == 0.0
    bullets << :simple_motorcycle_costs_bullet unless simple_motorcycle_costs.to_f == 0.0
    bullets << :simple_home_costs_bullet unless simple_home_costs.to_f == 0.0
    bullets << :simple_business_costs_bullet unless simple_business_costs.to_f == 0.0
  end

  precalculate :current_scheme_bullets do
    bullets = PhraseList.new
    bullets << :current_vehicle_cost_bullet unless vehicle_tax_amount.to_f == 0.0
    bullets << :current_green_vehicle_write_off_bullet unless green_vehicle_write_off.to_f == 0.0
    bullets << :current_dirty_vehicle_write_off_bullet unless dirty_vehicle_write_off.to_f == 0.0
    bullets << :current_home_costs_bullet unless home_costs.to_f == 0.0
    bullets << :current_business_costs_bullet unless business_premises_cost.to_f == 0.0
  end

  precalculate :over_van_limit_message do
    is_over_limit ? PhraseList.new(:over_van_limit) : PhraseList.new
  end

end


