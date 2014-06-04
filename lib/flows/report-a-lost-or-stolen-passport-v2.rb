status :draft
satisfies_need "100221"

exclude_countries = %w(holy-see british-antarctic-territory)

multiple_choice :where_was_the_passport_lost_or_stolen? do
  option in_the_uk: :adult_or_child_passport?
  option abroad: :adult_or_child_passport?

  save_input_as :location
end

multiple_choice :adult_or_child_passport? do
  option :adult
  option :child

  save_input_as :age

  calculate :child_advice do
    age == 'child' ? PhraseList.new(:child_forms) : PhraseList.new
  end

  next_node do
    case location
      when 'in_the_uk' then :complete_LS01_form
      when 'abroad' then :which_country?
    end
  end
end

country_select :which_country?, exclude_countries: exclude_countries do
  save_input_as :country

  calculate :overseas_passports_embassies do
    location = WorldLocation.find(country)
    raise InvalidResponse unless location
    if location.fco_organisation
      location.fco_organisation.offices_with_service 'Lost or Stolen Passports'
    else
      []
    end
  end
  next_node :contact_the_embassy
end

outcome :contact_the_embassy
outcome :complete_LS01_form
