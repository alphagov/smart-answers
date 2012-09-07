status :draft
section_slug "money-and-tax"

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

  next_node :what_is_your_estimated_income_for_the_year_before_tax?
end

# Question 2
money_question :what_is_your_estimated_income_for_the_year_before_tax? do
  calculate :total_income do
    responses.last.to_f.round
  end

  next_node do |response|
    if response.to_f <= 50000
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
  save_input_as :net_savings_interest

  calculate :adjusted_net_income do
    total_income - gross_pension_contributions.to_f - (net_pension_contributions.to_f * 1.2) + (responses.last.to_f * 1.2)
  end

  next_node :how_much_do_you_expect_to_give_to_charity_this_year?
end

# Question 6
money_question :how_much_do_you_expect_to_give_to_charity_this_year? do
  save_input_as :gift_aided_donations

  calculate :adjusted_net_income do
    adjusted_net_income - (gift_aided_donations * 1.2)
  end

  next_node do |response|
    if (adjusted_net_income - (response.to_f * 1.2)) < 50000
      :dont_need_to_pay
    else
      :how_many_children_claiming_for?
    end
  end
end

# Question 7
value_question :how_many_children_claiming_for? do
  calculate :number_of_children do
    responses.last.to_i
  end

  next_node :do_you_expect_to_start_or_stop_claiming?
end

# Question 8
multiple_choice :do_you_expect_to_start_or_stop_claiming? do

  calculate :calculator do
    if number_of_children < 1 and responses.last == "no"
      raise SmartAnswer::InvalidResponse, "You cannot claim child benefit if you do not have a child and are not expecting to start claiming for one in this tax year."
    end

    calculator = Calculators::ChildBenefitTaxCalculator.new(
      :child_benefit_start_date => start_of_tax_year,
      :child_benefit_end_date => end_of_tax_year,
      :children_claiming => number_of_children,
      :income => adjusted_net_income
    )
  end

  calculate :benefit_tax do
    calculator.formatted_benefit_tax
  end

  calculate :benefit_claimed_weeks do
    calculator.benefit_claimed_weeks
  end

  calculate :percentage_tax_charge do
    calculator.percent_tax_charge
  end

  calculate :benefit_claimed_amount do
    calculator.formatted_benefit_claimed_amount
  end

  calculate :benefit_taxable_weeks do
    calculator.benefit_taxable_weeks
  end

  calculate :benefit_taxable_amount do
    calculator.formatted_benefit_taxable_amount
  end

  calculate :result_for_tax_year do
    if tax_year == "2012-13"
      PhraseList.new("2012-13".to_sym)
    else
      PhraseList.new("2013-14".to_sym)
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
    if num_children < 0 or num_children > 3 or (num_children + number_of_children) < 1
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

    calculate "#{ordinal_string}_new_child_arrival_date".to_sym do
      start_date = Date.parse(responses.last)
      if !(start_of_tax_year..end_of_tax_year).include_with_range? start_date
        puts "Error - #{start_date} is not in range #{start_of_tax_year}..#{end_of_tax_year}"
        raise SmartAnswer::InvalidResponse, "Please enter a date within the selected tax year"
      end
      start_date
    end

    calculate "#{ordinal_string}_new_child_claim_period".to_sym do
      calculator = Calculators::ChildBenefitTaxCalculator.new(
        :child_benefit_start_date => self.call("#{ordinal_string}_new_child_arrival_date"),
        :end_of_tax_year => end_of_tax_year
      )
      calculator.benefit_claimed_weeks
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

# Question 9B

# Question 9C

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
      start_date = Date.parse(responses.last)
      if !(start_of_tax_year..end_of_tax_year).include_with_range? start_date
        puts "Error - #{start_date} is not in range #{start_of_tax_year}..#{end_of_tax_year}"
        raise SmartAnswer::InvalidResponse, "Please enter a date within the selected tax year"
      end
      start_date
    end

    next_node do |response|
      if num_children_starting > index+1
        "when_do_you_expect_to_stop_claiming_for_the_#{(index+2).ordinalize}_child?".to_sym
      else
        :estimated_tax_charge
      end
    end
  end
end




  # calculate :calculator do
  #   Calculators::ChildBenefitTaxCalculator.new(
  #     :child_benefit_start_date => child_benefit_start_date,
  #     :child_benefit_end_date => child_benefit_end_date,
  #     :children_claiming => children_claiming,
  #     :income => income
  #   )
  # end

  # calculate :formatted_benefit_tax do
  #   calculator.formatted_benefit_tax
  # end

  # calculate :formatted_benefit_taxable_amount do
  #   calculator.formatted_benefit_taxable_amount
  # end

  # calculate :benefit_taxable_weeks do
  #   calculator.benefit_taxable_weeks
  # end

  # calculate :percent_tax_charge do
  #   calculator.percent_tax_charge
  # end

  # calculate :formatted_benefit_claimed_amount do
  #   calculator.formatted_benefit_claimed_amount
  # end

  # calculate :benefit_claimed_weeks do
  #   calculator.benefit_claimed_weeks
  # end


outcome :estimated_tax_charge
outcome :dont_need_to_pay
