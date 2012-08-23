satisfies_need 1625
section_slug ""
status :draft

## Q1
multiple_choice :what_type_of_vehicle? do
  option :car_or_light_vehicle => :do_you_have_a_driving_licence? #Q2
  option :motorcycle => :do_you_have_a_full_motorcycle_licence? #Q4
#  option :moped => #Q9
#  option :medium_sized_vehicle => #Q12
#  option :large_vehicle_or_lorry => #Q15
#  option :minibus => #Q18
#  option :bus => #Q21
#  option :agricultural_tractor => #Q23
#  option :other_specialist_vehicle => #Q25
#  option :quad_bike_or_trike => #Q28
end

## Q2
multiple_choice :do_you_have_a_driving_licence? do
  option :yes => :you_may_already_be_elligible #A1
  option :no => :how_old_are_you? #Q3
end

## Q3
multiple_choice :how_old_are_you? do
  option "under_16" => :not_old_enough #A2
  option "16" => :mobility_rate_clause #A3
  option "17_or_over" => :elligible_for_provisional_licence #A4
end

## Q4
multiple_choice :do_you_have_a_full_motorcycle_licence? do
  option :yes => :how_old_are_you_mb? #Q5
  option :no => :how_old_are_you_mb_no_licence? #Q8
end

## Q5
multiple_choice :how_old_are_you_mb? do
  option "17-20" => :had_mb_licence_for_more_than_2_years_17_20? #Q6
  option "21" => :had_mb_licence_for_more_2_years_21? #Q7
  option "22_or_over" => :motorcycle_elligibility_over_22 #A9
end

## Q6
multiple_choice :had_mb_licence_for_more_than_2_years_17_20? do
  option :yes => :ellibile_for_any_motorcycle #A5
  option :no => :elligible_for_same_motorcycle #A6
end

## Q7
multiple_choice :had_mb_licence_for_more_2_years_21? do
  option :yes => :elligible_for_any_motorcycle_21 # A7
  option :no => :elligible_for_same_motorcycle_21 # A8
end

## Q8
multiple_choice :how_old_are_you_mb_no_licence? do
  option "under_17" => :motorcycle_elligibility_no_licence_under_17 # A10
  option "17-20" => :motorcycle_elligibility_no_licence_17_20 # A11
  option "21_or_over" => :motorcycle_elligibility_no_licence_21_and_over # A12
end


outcome :you_may_already_be_elligible # A1
outcome :not_old_enough # A2
outcome :mobility_rate_clause # A3
outcome :elligible_for_provisional_licence # A4
outcome :ellibile_for_any_motorcycle # A5
outcome :elligible_for_same_motorcycle # A6
outcome :elligible_for_any_motorcycle_21 # A7
outcome :elligible_for_same_motorcycle_21 # A8
outcome :motorcycle_elligibility_over_22 # A9
outcome :motorcycle_elligibility_no_licence_under_17 # A10
outcome :motorcycle_elligibility_no_licence_17_20 # A11
outcome :motorcycle_elligibility_no_licence_21_and_over # A12

