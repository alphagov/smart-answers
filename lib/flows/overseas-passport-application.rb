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
    if ['australia', 'new-zealand'].include?(current_location)
      application_action == 'applying' ? :which_best_describes_you? : :replacing_old_passport?
    elsif ['IPS_application_1', 'IPS_application_2', 'IPS_application_3'].include?(application_type) and
      application_action == 'applying'
        :country_of_birth?
    else
      :result
    end
  end
end

# Q4
country_select :country_of_birth? do
  save_input_as :birth_location

  next_node :result
end

# QAUS1
multiple_choice :replacing_old_passport? do
  option :yes => :which_best_describes_you?
  option :no => :australian_result
end

# QAUS2
multiple_choice :which_best_describes_you? do
end

outcome :result
outcome :australian_result
