status :draft

value_question :what_is_your_name? do
  save_input_as :name
  next_node :foo
end

multiple_choice :what_is_your_quest? do
  option :to_find_the_holy_grail
  option :to_rescue_the_princess

  next_node do |response|
    if name == 'robin' and response == 'to_find_the_holy_grail'
      :what_is_the_capital_of_assyria?
    else
      :what_is_your_favorite_colour?
    end
  end
end

value_question :what_is_the_capital_of_assyria? do
  save_input_as :capital_of_assyria
  next_node :auuuuuuuugh
end

multiple_choice :what_is_your_favorite_colour? do
  option :blue => :where_is_the_grail?
  option :blue_no_yellow => :auuuuuuuugh
  option :red => :where_is_the_grail?
end

country_select :where_is_the_grail? do
  save_input_as :country
  next_node :when_will_you_find_it?
end

date_question :when_will_you_find_it? do
  next_node :what_is_it_worth?
end

money_question :what_is_it_worth? do
  next_node :what_do_you_earn?
end

salary_question :what_do_you_earn? do
  next_node :done
end

outcome :done
outcome :auuuuuuuugh
