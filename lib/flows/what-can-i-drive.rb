satisfies_need 9999
section_slug "family"
subsection_slug "driving"
status :draft

multiple_choice :what_do_you_want_to_drive? do
  option :car     => :car_do_you_have_a_licence?
  option :moped   => :moped_do_you_have_a_car_licence?
  option :medium  => :medium_do_you_have_a_car_licence?
  option :large   => :large_do_you_have_a_car_licence?
  option :minibus => :minibus_do_you_have_a_car_licence?
  option :bus     => :bus_do_you_have_a_car_licence?
  option :tractor => :tractor_do_you_have_a_licence?
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

multiple_choice :medium_do_you_have_a_car_licence? do
  option :yes => :medium_how_old_are_you?
  option :no  => :medium_no_need_car_licence
end

multiple_choice :medium_how_old_are_you? do
  option :age_17_under  => :medium_no_under_17
  option :age_17        => :medium_no_unless_armed_forces
  option :age_18_to_20  => :medium_yes_c1
  option :age_21_over   => :medium_yes_c1_plus_e
end

multiple_choice :large_do_you_have_a_car_licence? do
  option :yes => :large_how_old_are_you?
  option :no  => :large_no_need_car_licence
end

multiple_choice :large_how_old_are_you? do
  option :age_17_under  => :large_no_under_17
  option :age_17        => :large_no_unless_armed_forces
  option :age_18_to_20  => :large_yes_with_special_circumstances
  option :age_21_over   => :large_yes
end

multiple_choice :minibus_do_you_have_a_car_licence? do
  option :yes => :minibus_how_old_are_you?
  option :no  => :minibus_no_need_car_licence
end

multiple_choice :minibus_how_old_are_you? do
  option :age_17_under  => :minibus_no_under_17
  option :age_17        => :minibus_no_unless_armed_forces
  option :age_18_to_19  => :minibus_yes_special_18_to_19
  option :age_20        => :minibus_yes_special_20
  option :age_21_over   => :minibus_yes
end

multiple_choice :bus_do_you_have_a_car_licence? do
  option :yes => :bus_how_old_are_you?
  option :no  => :bus_no_need_car_licence
end

multiple_choice :bus_how_old_are_you? do
  option :age_17_under  => :bus_no_under_17
  option :age_17        => :bus_no_unless_armed_forces
  option :age_18_to_19  => :bus_yes_special_18_to_19
  option :age_20        => :bus_yes_special_20
  option :age_21_over   => :bus_yes
end

multiple_choice :tractor_do_you_have_a_licence? do
  option :yes => :tractor_yes_except
  option :no  => :tractor_how_old_are_you?
end

multiple_choice :tractor_how_old_are_you? do
  option :age_16_under  => :tractor_no_under_16
  option :age_16        => :tractor_yes_16
  option :age_17_over   => :tractor_yes
end

outcome :car_yes_have_licence
outcome :car_no_under_16
outcome :car_yes
outcome :car_yes_with_dla

outcome :moped_yes_licence_ok
outcome :moped_yes_with_cbt
outcome :moped_no_under_16
outcome :moped_yes

outcome :medium_no_need_car_licence
outcome :medium_no_under_17
outcome :medium_no_unless_armed_forces
outcome :medium_yes_c1
outcome :medium_yes_c1_plus_e

outcome :large_no_need_car_licence
outcome :large_no_under_17
outcome :large_no_unless_armed_forces
outcome :large_yes_with_special_circumstances
outcome :large_yes

outcome :minibus_no_need_car_licence
outcome :minibus_no_under_17
outcome :minibus_no_unless_armed_forces
outcome :minibus_yes_special_18_to_19
outcome :minibus_yes_special_20
outcome :minibus_yes

outcome :bus_no_need_car_licence
outcome :bus_no_under_17
outcome :bus_no_unless_armed_forces
outcome :bus_yes_special_18_to_19
outcome :bus_yes_special_20
outcome :bus_yes

outcome :tractor_yes_except
outcome :tractor_no_under_16
outcome :tractor_yes_16
outcome :tractor_yes