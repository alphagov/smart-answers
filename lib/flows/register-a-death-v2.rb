status :draft

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
  next_node do |response|
    if response =~ /^(australia)$/ # TODO: This should match commonwealth countries (via query class)
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
