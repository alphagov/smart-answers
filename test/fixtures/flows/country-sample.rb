status :draft

country_select :which_country_do_you_live_in? do
  save_input_as :country
  next_node :ok
end

outcome :ok
