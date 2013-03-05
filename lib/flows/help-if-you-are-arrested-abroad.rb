arrested_calc = SmartAnswer::Calculators::ArrestedAbroad.new
prisoner_packs = arrested_calc.data

#Q1
country_select :which_country? do
  save_input_as :country

  calculate :country_name do
    country_list = YAML::load( File.open( Rails.root.join('lib', 'data', 'countries.yml') ))
    country_list.select {|c| c[:slug] == country }.first[:name]
  end

  calculate :pdf do
    arrested_calc.generate_url_for_download(country, "pdf", "Prisoner pack (PDF)")
  end

  calculate :doc do
    arrested_calc.generate_url_for_download(country, "doc", "Prisoner pack (Doc)")
  end

  calculate :lawyer do
    arrested_calc.generate_url_for_download(country, "lawyer", "Information on lawyers")
  end

  calculate :translator do
    arrested_calc.generate_url_for_download(country, "translator", "Translators and interpreters")
  end

  calculate :benefits do
    arrested_calc.generate_url_for_download(country, "benefits", "Benefits or legal aid available")
  end

  calculate :prison do
    arrested_calc.generate_url_for_download(country, "prison", "Prison information")
  end

  calculate :consul do
    arrested_calc.generate_url_for_download(country, "consul", "Consul help")
  end

  calculate :judicial do
    arrested_calc.generate_url_for_download(country, "judicial", "Judicial system")
  end

  calculate :police do
    arrested_calc.generate_url_for_download(country, "police", "Police information")
  end

  next_node do |response|
    if response == "iran"
      :answer_three_iran
    elsif response == "syria"
      :answer_four_syria
    elsif arrested_calc.no_prisoner_packs.include?(response)
      :answer_one_no_pack
    else
      :answer_two_has_pack
    end
  end

end

outcome :answer_one_no_pack
outcome :answer_two_has_pack
outcome :answer_three_iran
outcome :answer_four_syria
