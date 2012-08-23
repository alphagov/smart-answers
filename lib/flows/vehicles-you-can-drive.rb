satisfies_need 1625
section_slug ""
status :draft

## Q1
multiple_choice :what_type_of_vehicle? do
  option "car-or-light-vehicle" => :do_you_have_a_driving_licence? #Q2
  option :motorcycle => :do_you_have_a_full_motorcycle_licence? #Q4
  option :moped => :do_you_have_a_full_driving_licence? #Q9
  option "medium-sized-vehicle" => :do_you_have_a_full_cat_b_driving_licence? #Q12
  option "large-vehicle-or-lorry" => :how_old_are_you_lorry? #Q15
  option :minibus => :full_cat_b_car_licence_psv? #Q18
  option :bus => :full_cat_b_licence_bus? #Q21
#  option :agricultural_tractor => #Q23
#  option :other_specialist_vehicle => #Q25
#  option :quad_bike_or_trike => #Q28
end

## Cars, Light Vehicles
##
## Q2
multiple_choice :do_you_have_a_driving_licence? do
  option :yes => :you_may_already_be_elligible #A1
  option :no => :how_old_are_you? #Q3
end

## Q3
multiple_choice :how_old_are_you? do
  option "under-16" => :not_old_enough #A2
  option "16" => :mobility_rate_clause #A3
  option "17-or-over" => :elligible_for_provisional_licence #A4
end

## Motorcycles
##
## Q4
multiple_choice :do_you_have_a_full_motorcycle_licence? do
  option :yes => :how_old_are_you_mb? #Q5
  option :no => :how_old_are_you_mb_no_licence? #Q8
end

## Q5
multiple_choice :how_old_are_you_mb? do
  option "17-20" => :had_mb_licence_for_more_than_2_years_17_20? #Q6
  option "21" => :had_mb_licence_for_more_2_years_21? #Q7
  option "22-or-over" => :motorcycle_elligibility_over_22 #A9
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
  option "under-17" => :motorcycle_elligibility_no_licence_under_17 # A10
  option "17-20" => :motorcycle_elligibility_no_licence_17_20 # A11
  option "21-or-over" => :motorcycle_elligibility_no_licence_21_and_over # A12
end

## Mopeds
##
## Q9
multiple_choice :do_you_have_a_full_driving_licence? do
  option :yes => :licence_issued_before_2001? # Q10
  option :no => :how_old_are_you_mpd? # Q11
end

## Q10
multiple_choice :licence_issued_before_2001? do
  option :yes => :moped_elligibility_licence_pre_2001 # A13
  option :no => :moped_elligibility_full_licence_post_2001 # A14
end

## Q11
multiple_choice :how_old_are_you_mpd? do
  option "under-16" => :moped_not_old_enough # A15
  option "16-or-over" => :moped_apply_for_provisional # A16
end

## Medium sized vehicles
##
## Q12
multiple_choice :do_you_have_a_full_cat_b_driving_licence? do
  option :yes => :when_was_licence_issued? # Q13
  option :no => :cat_b_licence_required # A20
end

## Q13
multiple_choice :when_was_licence_issued? do
  option "before-jan-1997" => :elligible_for_msv # A17
  option "from-jan-1997" => :how_old_are_you_msv? # Q14
end

## Q14
multiple_choice :how_old_are_you_msv? do
  option "under-18" => :not_elligible_for_msv_until_18 # A18
  option "18-or-over" => :apply_for_provisional_msv_entitlement # A19
end

## Lorries and large vehicles
##
## Q15
multiple_choice :how_old_are_you_lorry? do
  option "under-18" => :not_elligible_for_lorry_until_18 # A21
  option "18-20" => :limited_elligibility_lorry # A22
  option "21-or-over" => :do_you_have_a_full_cat_b_car_licence? # Q16
end

## Q16
multiple_choice :do_you_have_a_full_cat_b_car_licence? do
  option :yes => :when_was_cat_b_licence_issued? # Q17
  option :no => :cat_b_driving_licence_required # A25
end

## Q17
multiple_choice :when_was_cat_b_licence_issued? do
  option "before-jan-1997" => :apply_for_provisional_cat_c_entitlement # A23
  option "from-jan-1997" => :apply_for_conditional_provisional_cat_c_entitlement # A24
end

## Minibus PSV
##
## Q18
multiple_choice :full_cat_b_car_licence_psv? do
  option :yes => :when_was_licence_issued_psv? # Q19
  option :no => :psv_conditional_elligibility # A27
end

## Q19
multiple_choice :when_was_licence_issued_psv? do
  option "before-jan-1997" => :psv_elligible # A26
  option "from-jan-1997" => :how_old_are_you_psv? # Q20
end

## Q20
multiple_choice :how_old_are_you_psv? do
  option "under-21" => :psv_conditional_elligibility # A27
  option "21-or-over" => :psv_limited_elligibility # A28
end

# Bus
#
# Q21
multiple_choice :full_cat_b_licence_bus? do
  option :yes => :how_old_are_you_bus? # Q22
  option :no => :bus_apply_for_cat_b # A33
end

## Q22
multiple_choice :how_old_are_you_bus? do
  option "under-18" => :bus_exceptions_under_18 # A29
  option "18-19" => :bus_exceptions_18_19 # A30
  option "20" => :bus_exceptions_20# A31
  option "21-or-above" => :bus_apply_for_cat_d # A32 
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
outcome :moped_elligibility_licence_pre_2001 # A13
outcome :moped_elligibility_licence_post_2001 # A14
outcome :moped_not_old_enough # A15
outcome :moped_apply_for_provisional # A16
outcome :elligible_for_msv # A17
outcome :not_elligible_for_msv_until_18 # A18
outcome :apply_for_provisional_msv_entitlement # A19
outcome :cat_b_licence_required # A20
outcome :not_elligible_for_lorry_until_18 # A21
outcome :limited_elligibility_lorry # A22
outcome :apply_for_provisional_cat_c_entitlement # A23
outcome :apply_for_conditional_provisional_cat_c_entitlement # A24
outcome :cat_b_driving_licence_required # A25
outcome :psv_elligible # A26
outcome :psv_conditional_elligibility # A27
outcome :psv_limited_elligibility # A28
outcome :bus_exceptions_under_18 # A29
outcome :bus_exceptions_18_19 # A30
outcome :bus_exceptions_20 # A31
outcome :bus_apply_for_cat_d # A32
outcome :bus_apply_for_cat_b # A33
