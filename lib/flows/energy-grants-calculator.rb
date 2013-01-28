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
    elsif dob < 60.years.ago(Date.today + 1)
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

  calculate :benefits do
    responses.last.split(',')
  end

  next_node do |response|
    choices = response.split(',')
    no_disability_answers = ['pension_credit','esa','child_tax_credit']
    
    if response == 'none'
      :no_benefits
    elsif (choices - no_disability_answers).empty?
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
  option :pensioner_premium

  calculate :benefits_1 do
    choices = responses.last.split(',')
    (choices & %w(disabled disabled_child child_under_5 pensioner_premium)).any?
  end
  calculate :benefits_2 do
    responses.last.split(',').include?('child_under_16')
  end

  next_node do |response|
    if response == 'none'
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
    if circumstances.include?('property') or circumstances.include?('permission')
      phrases << :renewable_heat_premium   
    end
    phrases << :feed_in_tariffs if circumstances.include?('own_energy')
    if benefits.include?('pension_credit') or benefits_1 or benefits.include?('esa')
      phrases << :warm_home_discount << :cold_weather_payment << :energy_company_obligation
    end
    if benefits.include?('child_tax_credit') or benefits_2 or
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
    if circumstances.include?('property') or circumstances.include?('permission')
      phrases << :renewable_heat_premium   
    end
    phrases << :feed_in_tariffs if circumstances.include?('own_energy')
    if benefits.include?('pension_credit') or benefits.include?('esa')
      phrases << :warm_home_discount << :cold_weather_payment << :energy_company_obligation
    end
    phrases << :energy_company_obligation if benefits.include?('child_tax_credit')
    if benefits.include?('working_tax_credit') and age_variant == :over_60
      phrases << :energy_company_obligation
    end
    PhraseList.new(*phrases.uniq)
  end
end
