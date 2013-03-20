status :published

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
    arrested_calc.generate_url_for_download(country, "pdf", "Prisoner pack for #{country_name}")
  end

  calculate :doc do
    arrested_calc.generate_url_for_download(country, "doc", "Prisoner pack for #{country_name}")
  end

  calculate :benefits do
    arrested_calc.generate_url_for_download(country, "benefits", "Benefits or legal aid in #{country_name}")
  end

  calculate :prison do
    arrested_calc.generate_url_for_download(country, "prison", "Information on prisons and prison procedures in #{country_name}")
  end

  calculate :judicial do
    arrested_calc.generate_url_for_download(country, "judicial", "Information on the judicial system and procedures in #{country_name}")
  end

  calculate :police do
    arrested_calc.generate_url_for_download(country, "police", "Information on the police and police procedures in #{country_name}")
  end

  calculate :consul do
    arrested_calc.generate_url_for_download(country, "consul", "Consul help available in #{country_name}")
  end

  calculate :has_extra_downloads do
    [police, judicial, consul, prison, benefits, doc, pdf].select { |x|
      x != ""
    }.length > 0
  end

  next_node do |response|
    if response == "iran"
      :answer_two_iran
    elsif response == "syria"
      :answer_three_syria
    else
      :answer_one_generic
    end
  end

end

outcome :answer_one_generic do
  precalculate :intro do
    PhraseList.new(:common_intro)
  end

  precalculate :generic_downloads do
    PhraseList.new(:common_downloads)
  end

  precalculate :country_downloads do
    has_extra_downloads ? PhraseList.new(:specific_downloads) : PhraseList.new
  end

  precalculate :after_downloads do
    PhraseList.new(:fco_cant_do, :dual_nationals_other_help, :further_links)
  end

end

outcome :answer_two_iran do
  precalculate :downloads do
    PhraseList.new(:common_downloads)
  end

  precalculate :further_help_links do
    PhraseList.new(:further_links)
  end
end

outcome :answer_three_syria do
  precalculate :downloads do
    PhraseList.new(:common_downloads)
  end

  precalculate :further_help_links do
    PhraseList.new(:further_links)
  end
end
