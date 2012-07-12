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
    if responses.last.to_i < 2 or (responses.last.to_i.to_s != responses.last)
      raise SmartAnswer::InvalidResponse, "You must have at least 1 child to claim Child Benefit."
    end
    responses.last.to_i
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
  calculate :child_benefit_start_date do
    if Date.parse(responses.last) <= Date.new(2012, 4, 6)
      raise SmartAnswer::InvalidResponse, "Please enter date after 6 April 2012"
    end
    Date.parse(responses.last)
  end

  next_node :do_you_expect_to_stop_claiming_by_5_april_2013?
end

multiple_choice :do_you_expect_to_stop_claiming_by_5_april_2013? do
  option "yes_s" => :when_do_you_expect_to_stop_claiming?
  option "no_s" => :estimated_tax_charge

  calculate :child_benefit_end_date do
    if responses.last == "no_s"
      Date.new(2013, 4, 5)
    else
      nil
    end
  end
end

date_question :when_do_you_expect_to_stop_claiming? do
  calculate :child_benefit_end_date do
    if Date.parse(responses.last) > Date.new(2013, 4, 5) or Date.parse(responses.last) < child_benefit_start_date
      raise SmartAnswer::InvalidResponse, "Please enter date before 5 April 2013"
    end
    Date.parse(responses.last)
  end

  next_node :estimated_tax_charge
end

outcome :estimated_tax_charge
outcome :dont_need_to_pay
