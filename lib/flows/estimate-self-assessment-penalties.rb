status :draft
satisfies_need "B692"

calculator_dates = {
  :online_filing_deadline => {
    :"2010-11" => Date.new(2012, 1, 31),
    :"2011-12" => Date.new(2013, 1, 31),
    :"2012-13" => Date.new(2014, 1, 31)
  },
  :offline_filing_deadline => {
    :"2010-11" => Date.new(2011, 10, 31),
    :"2011-12" => Date.new(2012, 10, 31),
    :"2012-13" => Date.new(2013, 10, 31)
  },
  :payment_deadline => {
    :"2010-11" => Date.new(2012, 1, 31),
    :"2011-12" => Date.new(2013, 1, 31),
    :"2012-13" => Date.new(2014, 1, 31)
  },
  :penalty1date => {
    :"2010-11" => Date.new(2012, 3, 2),
    :"2011-12" => Date.new(2013, 3, 2),
    :"2012-13" => Date.new(2014, 3, 2)
  },
  :penalty2date => {
    :"2010-11" => Date.new(2012, 8, 2),
    :"2011-12" => Date.new(2013, 8, 2),
    :"2012-13" => Date.new(2014, 8, 2)
  },
  :penalty3date => {
    :"2010-11" => Date.new(2013, 2, 2),
    :"2011-12" => Date.new(2014, 2, 2),
    :"2012-13" => Date.new(2015, 2, 2)
  }
}

multiple_choice :which_year? do
  option :"2010-11"
  option :"2011-12"
  option :"2012-13"

  save_input_as :tax_year

  calculate :start_of_next_tax_year do
    if responses.last == '2010-11'
      Date.new(2011, 4, 6)
    elsif responses.last == '2011-12'
      Date.new(2012, 4, 6)
    else
      Date.new(2013, 4, 6)
    end
  end

  calculate :start_of_next_tax_year_formatted do
    start_of_next_tax_year.strftime("%e %B %Y")
  end

  next_node :how_submitted?
end

multiple_choice :how_submitted? do
  option :online => :when_submitted?
  option :paper => :when_submitted?

  save_input_as :submission_method
end

date_question :when_submitted? do
  save_input_as :filing_date

  next_node do |response|
    if Date.parse(response) < start_of_next_tax_year
      raise SmartAnswer::InvalidResponse 
    else
      :when_paid?
    end
  end
end

date_question :when_paid? do
  save_input_as :payment_date

  next_node do |response|
    if Date.parse(response) < start_of_next_tax_year
      raise SmartAnswer::InvalidResponse 
    else
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
    calculator.total_owed_plus_filing_penalty
  end

  calculate :interest do
    calculator.interest
  end

  calculate :late_payment_penalty do
    calculator.late_payment_penalty
  end

  calculate :late_filing_penalty_formatted do
    late_filing_penalty == 0 ? 'none' : late_filing_penalty
  end

  calculate :result_parts do
    if calculator.late_payment_penalty == 0
      PhraseList.new(:result_part2_no_penalty)
    else
      PhraseList.new(:result_part2_penalty)
    end
  end

  next_node :late
end


outcome :late
outcome :filed_and_paid_on_time
