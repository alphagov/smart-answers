status :draft

data_query = SmartAnswer::Calculators::MarriageAbroadDataQuery.new
i18n_prefix = "flow.find-a-british-embassy"

#Question
country_select :choose_embassy_country do
  save_input_as :embassy_country

  calculate :embassy_country_name do
    SmartAnswer::Question::CountrySelect.countries.find { |c| c[:slug] == responses.last }[:name]
  end
  calculate :country_name_lowercase_prefix do
    case embassy_country
    when 'bahamas','british-virgin-islands','cayman-islands','czech-republic','dominican-republic','falkland-islands','gambia','maldives','marshall-islands','philippines','russian-federation','seychelles','solomon-islands','south-georgia-and-south-sandwich-islands','turks-and-caicos-islands','united-states'
      "the #{embassy_country_name}"
    when 'korea'
      "South #{embassy_country_name}"
    else
      embassy_country_name
    end
  end


  calculate :embassies_data do
    data_query.find_embassy_data(embassy_country)
  end

  calculate :embassies_details do
    details = []
    embassies_data.each do |e|
      details << I18n.translate!("#{i18n_prefix}.phrases.embassy_details",
                                embassy_location: e['location_name'],
                                address: e['address'], phone: e['phone'],
                                email: e['email'], office_hours: e['office_hours'])
    end if embassies_data
    details
  end

  calculate :embassies_details_single do
    bananas = []
    embassies_data.each do |e|
      bananas << I18n.translate!("#{i18n_prefix}.phrases.embassy_details",
                                embassy_location: e[''],
                                address: e['address'], phone: e['phone'],
                                email: e['email'], office_hours: e['office_hours'])
    end if embassies_data
    bananas
  end

  calculate :embassy_details do
    if embassies_details.count{'location_name'} == 1 
      embassies_details_single.first
    else
      embassies_details.join
    end
  end


  next_node :embassy_outcome
end

outcome :embassy_outcome
