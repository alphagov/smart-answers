status :draft
satisfies_need '100865'

data_query = Calculators::StatePensionTopupDataQuery.new()

date_question :dob_age? do
  from { 101.years.ago }
  to { Date.today }

  save_input_as :date_of_birth

	next_node do |response|
    dob = Date.parse(response)
		if (dob < (Date.parse('2017-03-31') - 100.years))
			:outcome_age_limit_reached
		elsif (dob > (Date.parse('2017-03-31') - 63.years))
      :outcome_pension_age_not_reached
    else
			:how_much_extra_per_week?
		end
	end
end


money_question :how_much_extra_per_week? do
	save_input_as :money_wanted
  
  calculate :integer_value do
    money = responses.last.to_f
    if (money % 1 != 0) or (money > 25 or money < 1)
      raise SmartAnswer::InvalidResponse
    end
  end
  next_node :date_of_lump_sum_payment?
end

date_question :date_of_lump_sum_payment? do
  from { Date.parse('12 Oct 2015') }
  to { Date.parse('31 March 2017') }

  save_input_as :age_at_date_of_payment

  next_node do |response|
    date_paying = Date.parse(response)
    dob = Date.parse(date_of_birth)

    if date_paying < Date.parse('2015-10-12') or date_paying > Date.parse('2017-03-31')
      raise SmartAnswer::InvalidResponse
    elsif (date_paying.year - dob.year) > 100
      :outcome_age_limit_reached
    else
      :gender?
    end
  end
end

multiple_choice :gender? do
  option :male
  option :female

  save_input_as :gender

  calculate :age_at_date_of_payment do
    date_paying = Date.parse(age_at_date_of_payment)
    dob = Date.parse(date_of_birth)
    age_when_paying = (date_paying.year - dob.year)
    age_when_paying
  end

  next_node do |response|
    
    dob = Date.parse(date_of_birth)
    dop = Date.parse(age_at_date_of_payment)
    if (response == "male") and ((dop.year - dob.year) < 65)
      :outcome_pension_age_not_reached
    else
      :outcome_qualified_for_top_up_calculations
    end
  end
end

outcome :outcome_qualified_for_top_up_calculations do
  precalculate :weekly_amount do 
    sprintf("%.0f",money_wanted)
  end
  precalculate :rate_at_time_of_paying do
    money = money_wanted.to_f
    total = data_query.age_and_rates(age_at_date_of_payment) * money
    
    total_money = SmartAnswer::Money.new(total)
  end
end
outcome :outcome_age_limit_reached
outcome :outcome_pension_age_not_reached