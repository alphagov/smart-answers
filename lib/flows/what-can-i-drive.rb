satisfies_need 9999
section_slug "family"
subsection_slug "driving"
status :draft

multiple_choice :what_do_you_want_to_drive? do
  option :car   => :car_do_you_have_a_licence?
  option :moped => :moped_do_you_have_a_car_licence?
end

multiple_choice :car_do_you_have_a_licence? do
  option :yes => :car_yes_have_licence
  option :no  => :car_how_old_are_you?
end

multiple_choice :car_how_old_are_you? do
  option :age_16_under  => :car_no_under_16
  option :age_16        => :car_are_you_getting_dla?
  option :age_17_over   => :car_yes
end

multiple_choice :car_are_you_getting_dla? do
  option :yes => :car_yes_with_dla
  option :no  => :car_no_under_16
end

multiple_choice :moped_do_you_have_a_car_licence? do
  option :yes => :moped_when_was_licence_issued?
  option :no  => :moped_how_old_are_you?
end

multiple_choice :moped_when_was_licence_issued? do
  option :yes => :moped_yes_licence_ok
  option :no  => :moped_yes_with_cbt
end

multiple_choice :moped_how_old_are_you? do
  option :age_16_under  => :moped_no_under_16
  option :age_16_over   => :moped_yes
end

outcome :car_yes_have_licence
outcome :car_no_under_16
outcome :car_yes
outcome :car_yes_with_dla

outcome :moped_yes_licence_ok
outcome :moped_yes_with_cbt
outcome :moped_no_under_16
outcome :moped_yes