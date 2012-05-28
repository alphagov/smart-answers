status :draft

multiple_choice :has_your_passport_been_lost_or_stolen? do
  option :lost
  option :stolen

  next_node :adult_or_child_passport?

  save_input_as :lost_or_stolen
end

multiple_choice :adult_or_child_passport? do
  option :adult
  option :child

  save_input_as :age

  calculate :child_advice do 
    age == 'child' ? PhraseList.new(:child_forms) : PhraseList.new
  end

  next_node do 
    case lost_or_stolen
      when 'lost' then :where_was_your_passport_lost?
      when 'stolen' then :where_was_your_passport_stolen?
    end
  end
end

multiple_choice :where_was_your_passport_stolen? do
  option :in_the_uk => :contact_the_police
  option :abroad => :which_country?

  save_input_as :location
end

multiple_choice :where_was_your_passport_lost? do
  option :in_the_uk => :complete_LS01_form
  option :abroad => :which_country?

  save_input_as :location
end

country_select :which_country? do
  save_input_as :country

  calculate :country_name do
    country_list = YAML::load( File.open( Rails.root.join('lib', 'smart_answer', 'templates', 'countries.yml') ))
    country_list.select {|c| c[:slug] == country }.first[:name]
  end

  calculate :embassies do
    embassies = JSON.parse( File.read(Rails.root.join('lib','data','embassies.json')) )
    raise SmartAnswer::InvalidResponse.new unless embassies[country]
    embassies[country]
  end

  next_node :contact_the_embassy
end

outcome :contact_the_police do
  places :'police-stations'
end
outcome :contact_the_embassy do
  contact_list :embassies
end
outcome :complete_LS01_form