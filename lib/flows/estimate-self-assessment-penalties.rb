status :draft
satisfies_need "B692"
section_slug "money-and-tax"

calculator_dates = {
  :online_filing_deadline => {
    :"2011-12" => Date.new(2012, 1, 31),
    :"2012-13" => Date.new(2013, 1, 31)
  },
  :offline_filing_deadline => {
    :"2011-12" => Date.new(2011, 10, 31),
    :"2012-13" => Date.new(2012, 10, 31)
  },
  :payment_deadline => Date.new(2012, 1, 31),
  :penalty1date => Date.new(2012, 3, 2),
  :penalty2date => Date.new(2012, 8, 2),
  :penalty3date => Date.new(2013, 2, 2)
}

multiple_choice :which_year? do
  option :"2011-12"
  option :"2012-13"

  save_input_as :tax_year

  next_node :how_submitted?
end

multiple_choice :how_submitted? do
  option :online => :when_submitted?
  option :paper => :when_submitted?

  save_input_as :submission_method
end

date_question :when_submitted? do
  save_input_as :filing_date

  next_node :when_paid?
end

date_question :when_paid? do
  save_input_as :payment_date

  next_node do |response|
    calculator = Calculators::SelfAssessmentPenalties.new(
      :submission_method => submission_method,
      :filing_date => filing_date,
      :payment_date => response,
      :dates => calculator_dates,
      :tax_year => tax_year
    )
    if calculator.paid_on_time?
      :filed_and_paid_on_time
    else
      :how_much_tax?
    end
  end
end

money_question :how_much_tax? do
  save_input_as :estimated_bill

  calculate :calculator do
    Calculators::SelfAssessmentPenalties.new(
      :submission_method => submission_method,
      :filing_date => filing_date,
      :payment_date => payment_date,
      :estimated_bill => responses.last,
      :dates => calculator_dates,
      :tax_year => tax_year
    )
  end

  calculate :late_filing_penalty do
    calculator.late_filing_penalty
  end

  calculate :total_owed do
    calculator.total_owed
  end

  calculate :interest do
    calculator.interest
  end

  calculate :late_payment_penalty do
    calculator.late_payment_penalty
  end

  calculate :result_parts do
    phrase_list = PhraseList.new(calculator.late_filing_penalty == 0 ? :result_part1_no_penalty : :result_part1_penalty)
    if calculator.late_payment_penalty == 0
      phrase_list << :result_part2_no_penalty
    else
      phrase_list << :result_part2_penalty
    end
    phrase_list
  end

  next_node :late
end


outcome :late
outcome :filed_and_paid_on_time
