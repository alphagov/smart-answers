status :published
satisfies_need "2482"

# Q0
multiple_choice :work_out_income? do
  option :income_work_out
  option :just_how_much

  save_input_as :work_out_income

  next_node :which_tax_year?
end
    

# Question 1
multiple_choice :which_tax_year? do
  option "2012-13"
  option "2013-14"

  save_input_as :tax_year

  calculate :start_of_tax_year do
    case responses.last
    when "2012-13" then Date.new(2012, 4, 6)
    when "2013-14" then Date.new(2013, 4, 6)
    else
      raise SmartAnswer::InvalidResponse
    end
  end

  calculate :end_of_tax_year do
    case responses.last
    when "2012-13" then Date.new(2013, 4, 5)
    when "2013-14" then Date.new(2014, 4, 5)
    else
      raise SmartAnswer::InvalidResponse
    end
  end

  # next_node :what_is_your_estimated_income_for_the_year_before_tax?
    
  next_node do |response|
    if work_out_income == "income_work_out" 
      :what_is_your_estimated_income_for_the_year_before_tax?
    else
      :how_many_children_claiming_for?
    end
  end
end

# Question 2
money_question :what_is_your_estimated_income_for_the_year_before_tax? do
  calculate :total_income do
    responses.last.to_f
  end

  next_node do |response|
    if response.to_f <= 50099
      :dont_need_to_pay
    else
      :do_you_expect_to_pay_into_a_pension_this_year?
    end
  end
end

# Question 3
multiple_choice :do_you_expect_to_pay_into_a_pension_this_year? do
  option :yes => :how_much_pension_contributions_before_tax?
  option :no => :how_much_interest_from_savings_and_investments?

  calculate :gross_pension_contributions do
    0
  end

  calculate :net_pension_contributions do
    0
  end
end

# Question 3A
money_question :how_much_pension_contributions_before_tax? do
  save_input_as :gross_pension_contributions

  next_node :how_much_pension_contributions_claimed_back_by_provider?
end

# Question 4
money_question :how_much_pension_contributions_claimed_back_by_provider? do
  save_input_as :net_pension_contributions

  next_node :how_much_interest_from_savings_and_investments?
end

# Question 5
money_question :how_much_interest_from_savings_and_investments? do
  save_input_as :trading_losses
  calculate :total_deductions do
    gross_pension_contributions + (net_pension_contributions.to_f * 1.25) + trading_losses.to_f
  end

  calculate :adjusted_net_income do
    total_income - total_deductions
  end

  next_node :how_much_do_you_expect_to_give_to_charity_this_year?
end

# Question 6
money_question :how_much_do_you_expect_to_give_to_charity_this_year? do
  save_input_as :gift_aided_donations

  calculate :adjusted_net_income do
    adjusted_net_income - (gift_aided_donations * 1.25)
  end

  next_node do |response|
    if (adjusted_net_income - (response.to_f * 1.25)) <= 50099
      :dont_need_to_pay
    else
      :how_many_children_claiming_for?
    end
  end
end

# Question 7
value_question :how_many_children_claiming_for? do
  calculate :number_of_children do
    if ! (responses.last.to_s =~ /\A\d+\z/)
      raise SmartAnswer::InvalidResponse
    else
      responses.last.to_i
    end
  end

  next_node :do_you_expect_to_start_or_stop_claiming?
end

# Question 8
multiple_choice :do_you_expect_to_start_or_stop_claiming? do

  calculate :num_children_starting do
    0
  end

  calculate :num_children_stopping do
    0
  end

  calculate :calculator do
    if number_of_children < 1 and responses.last == "no"
      raise SmartAnswer::InvalidResponse, "You cannot claim child benefit if you do not have a child and are not expecting to start claiming for one in this tax year."
    end
  end

  option :yes => :how_many_children_to_start_claiming?
  option :no => :estimated_tax_charge

  save_input_as :children_starting_or_stopping
end

# Question 9
value_question :how_many_children_to_start_claiming? do
  calculate :num_children_starting do
    num_children = responses.last.to_i
    if ! (responses.last.to_s =~ /\A\d+\z/) or num_children < 0 or num_children > 3 or (num_children + number_of_children) < 1
      raise SmartAnswer::InvalidResponse, "This calculator can only deal with up to 3 new children."
    end
    num_children
  end

  next_node do |response|
    if response.to_i == 0
      :how_many_children_to_stop_claiming?
    else
      :when_will_the_1st_child_enter_the_household?
    end
  end
end

# Question 9A, 9B, 9C

(1..3).map(&:ordinalize).each_with_index do |ordinal_string, index|
  date_question "when_will_the_#{ordinal_string}_child_enter_the_household?".to_sym do
    from { Date.new(2012, 4, 6) }
    to { Date.new(2014, 4, 5) }

    calculate "#{ordinal_string}_child_start_date".to_sym do
      start_date = Date.parse(responses.last)
      if !(start_of_tax_year..end_of_tax_year).include_with_range? start_date
        puts "Error - #{start_date} is not in range #{start_of_tax_year}..#{end_of_tax_year}"
        raise SmartAnswer::InvalidResponse, "Please enter a date within the selected tax year"
      end
      start_date
    end

    next_node do |response|
      if num_children_starting > index+1
        "when_will_the_#{(index+2).ordinalize}_child_enter_the_household?".to_sym
      else
        :how_many_children_to_stop_claiming?
      end
    end
  end
end


# Question 10
value_question :how_many_children_to_stop_claiming? do
  calculate :num_children_stopping do
    num_children_stopping = responses.last.to_i
    if num_children_stopping < 0 or num_children_stopping > 3
      raise SmartAnswer::InvalidResponse, "This calculator can only deal with stopping claims for 3 new children in a year."
    elsif num_children_stopping > number_of_children
      raise SmartAnswer::InvalidResponse, "You cannot stop claiming benefit for more children than you're claiming for."
    end
    num_children_stopping
  end

  next_node do |response|
    if response.to_i == 0
      :estimated_tax_charge
    else
      :when_do_you_expect_to_stop_claiming_for_the_1st_child?
    end
  end
end

# Question 10A, 10B, 10C

(1..3).map(&:ordinalize).each_with_index do |ordinal_string, index|
  date_question "when_do_you_expect_to_stop_claiming_for_the_#{ordinal_string}_child?".to_sym do
    from { Date.new(2012, 4, 6) }
    to { Date.new(2014, 4, 5) }

    calculate "#{ordinal_string}_child_stop_date".to_sym do
      stop_date = Date.parse(responses.last)
      if !(start_of_tax_year..end_of_tax_year).include_with_range? stop_date
        raise SmartAnswer::InvalidResponse, "Please enter a date within the selected tax year"
      end
      stop_date
    end

    next_node do |response|
      if num_children_stopping > index+1
        "when_do_you_expect_to_stop_claiming_for_the_#{(index+2).ordinalize}_child?".to_sym
      else
        :estimated_tax_charge
      end
    end
  end
end




outcome :estimated_tax_charge do
  precalculate :claim_periods do
    claim_periods = []

    # Children starting
    (1..3).map(&:ordinalize).each do |method|
      method = (method + "_child_start_date").to_sym
      start_date = self.send(method)
      claim_periods << (start_date..end_of_tax_year) unless start_date.nil?
    end

    # Children stopping
    (1..3).map(&:ordinalize).each do |method|
      method = (method + "_child_stop_date").to_sym
      stop_date = self.send(method)
      claim_periods << (start_of_tax_year..stop_date) unless stop_date.nil?
    end

    # Total children
    (number_of_children - num_children_stopping).times do
      claim_periods << (start_of_tax_year..end_of_tax_year)
    end

    claim_periods
  end

  precalculate :calculator do
    calculator = Calculators::ChildBenefitTaxCalculator.new(
      :start_of_tax_year => start_of_tax_year,
      :end_of_tax_year => end_of_tax_year,
      :children_claiming => number_of_children,
      :claim_periods => claim_periods,
      :income => ( work_out_income == "income_work_out" ? adjusted_net_income : 60001 )
    )
  end

  precalculate :benefit_tax do
    calculator.formatted_benefit_tax
  end

  precalculate :percentage_tax_charge do
    calculator.percent_tax_charge
  end

  precalculate :benefit_claimed_amount do
    calculator.formatted_benefit_claimed_amount
  end

  precalculate :benefit_taxable_weeks do
    calculator.benefit_taxable_weeks
  end

  precalculate :benefit_taxable_amount do
    calculator.formatted_benefit_taxable_amount
  end

end
outcome :dont_need_to_pay
