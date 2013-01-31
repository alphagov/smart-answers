status :draft

country_select :which_country_do_you_live_in? do
  save_input_as :country
  next_node :which_country_were_you_born_in?
end

country_select :which_country_were_you_born_in?, :include_uk => true do
  save_input_as :country_of_birth
  next_node :ok
end

outcome :ok
