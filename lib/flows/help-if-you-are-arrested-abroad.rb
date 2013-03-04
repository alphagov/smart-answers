NO_PRISONER_PACKS = %w(british-consulate-general-cape-town)

prisoner_packs = YAML::load( File.open( Rails.root.join('lib', 'data', 'prisoner_packs.yml') ))


#Q1
country_select :which_country? do
  save_input_as :country

  calculate :country_name do
    country_list = YAML::load( File.open( Rails.root.join('lib', 'data', 'countries.yml') ))
    country_list.select {|c| c[:slug] == country }.first[:name]
  end

  calculate :pack_url do
    if NO_PRISONER_PACKS.include?(country)
      ""
    else
      prisoner_packs.select { |c| c[:slug] == country }.first[:pack] || ""
    end
  end

  next_node do |response|
    if response == "iran"
      :answer_three_iran
    elsif response == "syria"
      :answer_four_syria
    elsif NO_PRISONER_PACKS.include?(response)
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
