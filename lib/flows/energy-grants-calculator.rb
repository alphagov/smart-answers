status :draft

# Q1
checkbox_question :what_are_your_circumstances? do
  option :benefits
  option :property
  option :permission
  option :own_energy

  calculate :circumstances do
    responses.last.split(",")
  end

  next_node :dob?
end

# Q2
date_question :dob? do
  from { 100.years.ago }
  to { Date.today } 
  calculate :age_variant do
    dob = Date.parse(responses.last)
    if dob < Date.new(1951,7,5)
      :winter_fuel_payment
    elsif dob < 60.years.ago(Date.today)
      :over_60
    end
  end
  next_node do
    if circumstances.include?('benefits')
      :which_benefits?
    else
      :no_benefits
    end
  end
end

# Q3
checkbox_question :which_benefits? do
  option :pension_credit
  option :income_support
  option :jsa
  option :esa
  option :child_tax_credit
  option :working_tax_credit
  option :none_of_these

  calculate :benefits do
    responses.last.split(',')
  end

  next_node do |response|
    choices = response.split(',')
    no_disability_answers = ['pension_credit','esa','child_tax_credit']
    
    if choices.include?('none_of_these')
      :no_benefits
    elsif (no_disability_answers + choices).uniq == no_disability_answers
      :on_benefits_no_disability_or_children
    else
      :disabled_or_have_children?
    end
  end
end

# Q4
checkbox_question :disabled_or_have_children? do
  option :disabled
  option :disabled_child
  option :child_under_5
  option :child_under_16
  option :none_of_these

  calculate :income_support_variant do
    choices = responses.last.split(',')
    if choices.include?('child_under_16')
      :income_support_2
    elsif choices.include?('none_of_these')
      nil
    else
      :income_support_1
    end
  end

  next_node do |response|
    if response.split(",").include?('none_of_these')
      :on_benefits_no_disability_or_children
    else
      :on_benefits
    end
  end
end


# Result 1 - (Not receiving benefits).
outcome :no_benefits do
  precalculate :eligibilities do
    phrases = PhraseList.new
    phrases << :winter_fuel_payments if age_variant == :winter_fuel_payment
    phrases << :green_deal
    if circumstances.include?('property') or circumstances.include?('permission')
      phrases << :renewable_heat_premium   
    end
    phrases << :feed_in_tariffs if circumstances.include?('own_energy')
    phrases
  end
end

# Result 2 - (Receiving benefits)
outcome :on_benefits do
  precalculate :eligibilities do
    phrases = [] 
    phrases << :winter_fuel_payments if age_variant == :winter_fuel_payment
    if benefits.include?('pension_credit') or income_support_variant == :income_support_1
      phrases << :warm_home_discount << :cold_weather_payment << :energy_company_obligation
    end
    if benefits.include?('esa')
      phrases << :cold_weather_payment << :energy_company_obligation
    end
    if benefits.include?('child_tax_credit') or income_support_variant == :income_support_2 or
      (benefits.include?('working_tax_credit') and age_variant == :over_60)
        phrases << :energy_company_obligation
    end
    PhraseList.new(*phrases.uniq)
  end
end

# Result 3 = (Receiving benefits no disability or children)
outcome :on_benefits_no_disability_or_children do
  precalculate :eligibilities do
  phrases = []
    phrases << :winter_fuel_payments if age_variant == :winter_fuel_payment
    if benefits.include?('pension_credit')
      phrases << :warm_home_discount << :cold_weather_payment << :energy_company_obligation
    end
    if benefits.include?('esa')
      phrases << :cold_weather_payment << :energy_company_obligation
    end
    phrases << :energy_company_obligation if benefits.include?('child_tax_credit')
    if benefits.include?('working_tax_credit') and age_variant == :over_60
      phrases << :energy_company_obligation
    end
    PhraseList.new(*phrases.uniq)
  end
end
