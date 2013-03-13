status :draft

data_query = SmartAnswer::Calculators::MarriageOverseasDataQuery.new


#Question
country_select :choose_embassy_country? do
  save_input_as :embassy_country

  calculate :embassy_country_name do
    SmartAnswer::Question::CountrySelect.countries.find { |c| c[:slug] == responses.last }[:name]
  end
  calculate :country_name_lowercase_prefix do
    case embassy_country
    when 'bahamas','gambia','british-virgin-islands','cayman-islands','falkland-islands','turks-and-caicos-islands','dominican-republic','russian-federation'
      "the #{embassy_country_name}"
    when 'korea'
      "South #{embassy_country_name}"
    else
      "#{embassy_country_name}"
    end

  end

  calculate :embassy_address do
    data = data_query.find_embassy_data(embassy_country)
    data.first['address'] if data
  end

  calculate :embassy_email_data do
    data = data_query.find_embassy_data(embassy_country)
    data.first['email']
  end

  calculate :embassy_website_data do
    data = data_query.find_embassy_data(embassy_country)
    data.first['website'] if data
  end

  calculate :embassy_office_hours_data do
    data = data_query.find_embassy_data(embassy_country)
    data.first['office_hours'] if data
  end

  calculate :embassy_phone_data do
    data = data_query.find_embassy_data(embassy_country)
    data.first['phone'] if data
  end

  calculate :embassy_website do
    unless embassy_website_data.nil?
      "Website: #{embassy_website_data}"
    end
  end

  calculate :embassy_phone do
    unless embassy_phone_data.nil?
      "Telephone: #{embassy_phone_data}"
    end
  end
  calculate :embassy_email do
    unless embassy_email_data.nil?
      "Email: #{embassy_email_data}"
    end
  end
  calculate :embassy_office_hours do
    unless embassy_office_hours_data.nil?
      "Office hours:\n#{embassy_office_hours_data}"
    end
  end



  next_node :embassy_outcome
end

outcome :embassy_outcome