require Rails.root.join("lib/data/passport_data_query")

status :draft

# Q1
country_select :which_country_are_you_in? do
  save_input_as :current_location

  calculate :passport_data do
    PassportDataQuery.find(responses.last)
  end

  calculate :application_type do
    passport_data[:type]
  end

  calculate :application_suffix do
    if application_type =~ /^IPS_application_\d$/
      application_type.split('_').slice(1,2).join('_')
    else
      nil
    end
  end

  next_node :renewing_replacing_applying?
end

# Q2
multiple_choice :renewing_replacing_applying? do
  option :renewing_new
  option :renewing_old
  option :applying
  option :replacing

  save_input_as :application_action

  next_node :child_or_adult_passport?
end

# Q3
multiple_choice :child_or_adult_passport? do
  option :child
  option :adult

  save_input_as :child_or_adult

  next_node do |response|
    case application_type
    when 'Australia_Post', 'New_Zealand'
      :which_best_describes_you?
    when /^ips_application_\d$/
      application_action == 'applying' ? :country_of_birth? : application_type.to_sym
    else
      :result
    end
  end
end

# Q4
country_select :country_of_birth? do
  save_input_as :birth_location

  calculate :application_group do
    PassportDataQuery.find(responses.last)[:group]
  end

  next_node do |response|
    if application_type =~ /^ips_application_\d$/
      application_type.to_sym
    else
      :result # TODO: lots of bespoke outcomes
    end
  end
end

# QAUS1
multiple_choice :which_best_describes_you? do
  option "born-in-uk-pre-1983"
  option "born-in-uk-post-dec-1982-father"
  option "born-in-uk-post-dec-1982-mother"
  option "born-outside-uk-parents-married"

  save_input_as :aus_checklist_variant

  next_node :australian_result
end

outcome :result
outcome :ips_application_1
outcome :ips_application_2
outcome :ips_application_3
outcome :australian_result
