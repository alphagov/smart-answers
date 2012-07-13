status :draft
section_slug "money-and-tax"

money_question :what_is_your_estimated_income_for_the_year? do
  calculate :income do
    responses.last.to_f.round(-2)
  end

  next_node do |response|
    if response.to_f.round(-2) <= 50000
      :dont_need_to_pay
    else
      :how_many_children_claiming_for?
    end
  end
end

value_question :how_many_children_claiming_for? do
  calculate :children_claiming do
    num_children = responses.last.to_i
    if num_children < 1 or (num_children.to_s != responses.last)
      raise SmartAnswer::InvalidResponse, "You must have at least 1 child to claim Child Benefit."
    end
    num_children
  end

  next_node :when_did_you_start_claiming?
end


multiple_choice :when_did_you_start_claiming? do
  option "on_or_before" => :do_you_expect_to_stop_claiming_by_5_april_2013?
  option "after" => :what_date_did_you_start_claiming?

  calculate :child_benefit_start_date do
    if responses.last == "on_or_before"
      Date.new(2012, 4, 6)
    else
      nil
    end
  end
end

date_question :what_date_did_you_start_claiming? do
  from { Date.new(2012, 4, 7) }
  to { Date.today }

  calculate :child_benefit_start_date do
    start_date = Date.parse(responses.last)
    if start_date <= Date.new(2012, 4, 6)
      raise SmartAnswer::InvalidResponse, "Please enter date after 6 April 2012"
    end
    start_date
  end

  next_node :do_you_expect_to_stop_claiming_by_5_april_2013?
end

multiple_choice :do_you_expect_to_stop_claiming_by_5_april_2013? do
  option :yes => :when_do_you_expect_to_stop_claiming?
  option :no => :estimated_tax_charge

  calculate :child_benefit_end_date do
    if responses.last == "no"
      Date.new(2013, 4, 5)
    else
      nil
    end
  end
  
  calculate :calculator do
    Calculators::ChildBenefitTaxCalculator.new(
      :child_benefit_start_date => child_benefit_start_date,
      :child_benefit_end_date => child_benefit_end_date,
      :children_claiming => children_claiming,
      :income => income
    ) if responses.last == 'no'
  end

  calculate :formatted_benefit_tax do
    calculator.formatted_benefit_tax if calculator
  end

  calculate :formatted_benefit_taxable_amount do
    calculator.formatted_benefit_taxable_amount if calculator
  end
  
  calculate :benefit_taxable_weeks do
    calculator.benefit_taxable_weeks if calculator
  end

  calculate :percent_tax_charge do
    calculator.percent_tax_charge if calculator
  end

  calculate :formatted_benefit_claimed_amount do
    calculator.formatted_benefit_claimed_amount if calculator
  end

  calculate :benefit_claimed_weeks do
    calculator.benefit_claimed_weeks if calculator
  end
end

date_question :when_do_you_expect_to_stop_claiming? do
  from { Date.today }
  to { Date.new(2013, 4, 4) }

  calculate :child_benefit_end_date do
    end_date = Date.parse(responses.last)
    if end_date > Date.new(2013, 4, 5) or end_date < child_benefit_start_date
      raise SmartAnswer::InvalidResponse, "Please enter date before 5 April 2013"
    end
    end_date
  end

  next_node :estimated_tax_charge

  calculate :calculator do
    Calculators::ChildBenefitTaxCalculator.new(
      :child_benefit_start_date => child_benefit_start_date,
      :child_benefit_end_date => child_benefit_end_date,
      :children_claiming => children_claiming,
      :income => income
    )
  end

  calculate :formatted_benefit_tax do
    calculator.formatted_benefit_tax
  end

  calculate :formatted_benefit_taxable_amount do
    calculator.formatted_benefit_taxable_amount
  end
  
  calculate :benefit_taxable_weeks do
    calculator.benefit_taxable_weeks
  end

  calculate :percent_tax_charge do
    calculator.percent_tax_charge
  end

  calculate :formatted_benefit_claimed_amount do
    calculator.formatted_benefit_claimed_amount
  end

  calculate :benefit_claimed_weeks do
    calculator.benefit_claimed_weeks
  end
end

outcome :estimated_tax_charge
outcome :dont_need_to_pay
