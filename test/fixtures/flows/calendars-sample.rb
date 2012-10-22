status :draft

multiple_choice :choose_your_blind_date do
  option :contestant_a => :date_one
  option :contestant_b => :date_two
  option :contestant_c => :date_three

  save_input_as :cillas_choice
end

outcome :date_one

outcome :date_two do
  calendar do
    date :event_four, Date.parse("1 January 2012")
    date :event_five, Date.parse("1 February 2012")..Date.parse("5 February 2012")
    date :event_six, Date.parse("24 March 2012")
  end
end

outcome :date_three do
  calendar do
    date :event_seven, Date.parse("12 January 2013")
    date :event_eight, Date.parse("1 February 2013")..Date.parse("5 February 2013")
    date :event_nine, Date.parse("16 March 2013")
  end
end
