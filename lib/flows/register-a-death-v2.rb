status :draft

data_query = SmartAnswer::Calculators::RegistrationsDataQuery.new

multiple_choice :where_did_the_death_happen? do
  save_input_as :where_death_happened
  option :uk
  option :overseas
  next_node :was_death_expected?
end

multiple_choice :was_death_expected? do
  save_input_as :death_expected
  option :yes
  option :no

  next_node do |response|
    if where_did_the_death_happen == 'uk'
      :uk_result
    else
      :which_country?
    end
  end
end

country_select :which_country? do
  calculate :country do
    SmartAnswer::Question::CountrySelect.countries.find { |c| c[:slug] == responses.last }[:name]
  end
  next_node do |response|
    if data_query.commonwealth_country?(response)
      :commonwealth_result
    else
      :where_do_you_want_to_register_the_death?
    end
  end
end

multiple_choice :where_do_you_want_to_register_the_death? do
  option :embassy => :embassy_result
  option :fco_uk => :fco_result
end

outcome :commonwealth_result
outcome :uk_result
outcome :fco_result
outcome :embassy_result
