status :draft
satisfies_need ''

data_query = Calculators::StatePensionTopUpDataQuery.new()

date_question :dob_age? do
  from { 120.years.ago }
  to { Date.today }

  save_input_as :date_of_birth

	next_node do |response|
    dob = Date.parse(response)
		if (dob < (Date.parse('2017-03-31') - 100.years))
			:outcome_no
		elsif (dob > (Date.parse('2017-03-31') - 63.years))
      :outcome_pension_age_not_reached
    else
			:how_much_extra_per_week?
		end
	end
end

money_question :how_much_extra_per_week? do
	save_input_as :money_wanted

	next_node :age_when_paying?
end

date_question :age_when_paying? do
  from { Date.parse('1 Oct 2015') }
  to { Date.parse('31 March 2017') }

  save_input_as :age_at_date_of_payment

  next_node do |response|
    date_paying = Date.parse(response)
    dob = Date.parse(date_of_birth)

    if date_paying < Date.parse('2015-10-01') or date_paying > Date.parse('2017-03-31')
      raise SmartAnswer::InvalidResponse
    elsif (date_paying.year - dob.year) > 100
      :outcome_no
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
      :outcome_result
    end
  end
end

outcome :outcome_result do

  precalculate :rate_at_time_of_paying do
    data_query.age_and_rates(age_at_date_of_payment)
  end

end

outcome :outcome_no
outcome :outcome_pension_age_not_reached