status :draft
# Q1
multiple_choice :have_you_adopted_the_child? do
  option :yes => :no_registration_result 
  option :no => :who_has_british_nationality? 
end
# Q2
multiple_choice :who_has_british_nationality? do
  option :mother => :country_of_birth?
  option :father => :country_of_birth?
  option :mother_and_father => :country_of_birth?
  option :neither => :no_registration_result

  save_input_as :british_national_parent

end
# Q3
country_select :country_of_birth? do
  save_input_as :country_of_birth

  next_node do |response|
    if response == 'australia' # TODO Registrations data to be used here.
      :commonwealth_result
    else
      :married_couple_or_civil_partnership?
    end
  end
end
# Q4
multiple_choice :married_couple_or_civil_partnership? do
  option :yes => :childs_date_of_birth?
  option :no => :childs_date_of_birth?
end
# Q5
date_question :childs_date_of_birth? do
  next_node :where_are_you_now?
end
# Q6
multiple_choice :where_are_you_now? do
  option :same_country
  option :another_country
  option :in_the_uk 

  next_node do |response|
    case response
    when 'same_country' then :embassy_result
    when 'another_country' then :which_country?
    else 
      :fco_result
    end
  end
end
# Q7
country_select :which_country? do
  save_input_as :current_location
end

outcome :embassy_result
outcome :fco_result
outcome :commonwealth_result
outcome :no_registration_result
