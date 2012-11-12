status :draft

date_question :when_are_you_starting? do
  save_input_as :start_date

  next_node :when_are_you_stopping?
end

date_question :when_are_you_stopping? do
  save_input_as :stop_date

  next_node :do_you_want_a_calendar?
end

multiple_choice :do_you_want_a_calendar? do
  option :yes => :date_ranges
  option :no => :no_calendar
end

outcome :date_ranges do
  calendar do |response|
    date :start_stop, Date.parse(response.start_date)..Date.parse(response.stop_date)
    date :something_else, Date.parse("16 March 2013")
  end
end

outcome :no_calendar
