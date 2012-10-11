satisfies_need "B1024"
status :draft


#Q1
multiple_choice :willing_to_offer_personal_assets? do
  option :yes
  option :no
  
  calculate :personal_assets do
    responses.last == 'yes'
  end

  next_node :own_business_property?
end

#Q2
multiple_choice :own_business_property? do
  option :yes
  option :no
  
  calculate :business_property do
    responses.last == 'yes'
  end

  next_node :give_up_shares?
end

#Q3
multiple_choice :give_up_shares? do
  option :yes
  option :no
  
  calculate :shares do
    responses.last == 'yes'
  end

  next_node :min_amount_funding?
end

#Q4
money_question :min_amount_funding? do
  
  calculate :min_funding do
    raise SmartAnswer::InvalidResponse if responses.last < 1
    Money.new(responses.last)
  end

  next_node :max_amount_funding?
end

#Q5
money_question :max_amount_funding? do
  
  calculate :max_funding do
    raise SmartAnswer::InvalidResponse if responses.last < min_funding.value
    Money.new(responses.last)
  end

  next_node :last_year_revenue?
end

#Q6 - revenue bands should be winder in subsequent versions, thic matches BL tool
money_question :last_year_revenue? do
  
  calculate :revenue_band do
    revenue = Money.new(responses.last)
    if revenue.value < 10000
      1
    else
      2
    end
  end
    
  next_node :how_many_people_are_in_your_business?
end

#Q7 - 
multiple_choice :how_many_people_are_in_your_business? do
  option :under_two_hundred_fifty
  option :two_hundred_fifty_or_over
  
  
  calculate :people_band do
    if responses.last == 'under_two_hundred_fifty'
      1
    else
      2
    end
  end

  next_node :done
end


outcome :done do
  precalculate :response_title do
    ''  
  end

  precalculate :should_consider_types do
    result = PhraseList.new(:heading_should)
    result << :info_shares
    result << :info_loans
    result << :info_grants
    result << :info_leasing
    result
  end

  precalculate :could_consider_types do
    result = PhraseList.new (:heading_maybe)
    result << :info_overdrafts
    result << :info_invoice_financing
    result
  end
end