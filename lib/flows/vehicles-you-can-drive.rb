satisfies_need 1625
status :draft

## Q1
multiple_choice :what_type_of_vehicle? do
  option "car-or-light-vehicle" => :how_old_are_you? #Q3
  option :motorcycle => :do_you_have_a_full_motorcycle_licence? #Q4
  option :moped => :do_you_have_a_full_driving_licence? #Q9
  option "medium-sized-vehicle" => :do_you_have_a_full_cat_b_driving_licence? #Q12
  option "large-vehicle-or-lorry" => :how_old_are_you_lorry? #Q15
  option :minibus => :full_cat_b_car_licence_psv? #Q18
  option :bus => :full_cat_b_licence_bus? #Q21
  option :tractor => :full_cat_b_licence_tractor? #Q23
  option "specialist-vehicle" => :full_cat_b_licence_sv? #Q25
  option "quad-bike" => :full_cat_b_licence_quad? #Q28
end

## Cars, Light Vehicles
##

## Q3
multiple_choice :how_old_are_you? do
  option "under-16" => :not_old_enough #A2
  option "16" => :mobility_rate_clause #A3
  option "17-or-over" => :entitled_for_provisional_licence #A4
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
  option "22-or-over" => :motorcycle_entitlement_over_22 #A9
end

## Q6
multiple_choice :had_mb_licence_for_more_than_2_years_17_20? do
  option :yes => :entitled_for_any_motorcycle #A5
  option :no => :entitled_for_same_motorcycle #A6
end

## Q7
multiple_choice :had_mb_licence_for_more_2_years_21? do
  option :yes => :entitled_for_any_motorcycle_21 # A7
  option :no => :entitled_for_same_motorcycle_21 # A8
end

## Q8
multiple_choice :how_old_are_you_mb_no_licence? do
  option "under-17" => :motorcycle_entitlement_no_licence_under_17 # A10
  option "17-20" => :motorcycle_entitlement_no_licence_17_20 # A11
  option "21-or-over" => :motorcycle_entitlement_no_licence_21_and_over # A12
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
  option :yes => :moped_entitlement_licence_pre_2001 # A13
  option :no => :moped_entitlement_licence_post_2001 # A14
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
  option "before-jan-1997" => :entitled_for_msv # A17
  option "from-jan-1997" => :how_old_are_you_msv? # Q14
end

## Q14
multiple_choice :how_old_are_you_msv? do
  option "under-18" => :not_entitled_for_msv_until_18 # A18
  option "18-or-over" => :apply_for_provisional_msv_entitlement # A19
end

## Lorries and large vehicles
##
## Q15
multiple_choice :how_old_are_you_lorry? do
  option "under-18" => :not_entitled_for_lorry_until_18 # A21
  option "18-20" => :limited_entitlement_lorry # A22
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
  option :no => :psv_conditional_entitlement # A27
end

## Q19
multiple_choice :when_was_licence_issued_psv? do
  option "before-jan-1997" => :psv_entitled # A26
  option "from-jan-1997" => :how_old_are_you_psv? # Q20
end

## Q20
multiple_choice :how_old_are_you_psv? do
  option "under-21" => :psv_conditional_entitlement # A27
  option "21-or-over" => :psv_limited_entitlement # A28
end

## Bus
##
## Q21
multiple_choice :full_cat_b_licence_bus? do
  option :yes => :how_old_are_you_bus? # Q22
  option :no => :bus_apply_for_cat_b # A33
end

## Q22
multiple_choice :how_old_are_you_bus? do
  option "under-21" => :bus_exceptions_under_21 # A29
  option "21-or-above" => :bus_apply_for_cat_d # A32 
end

## Tractor
##
## Q23
multiple_choice :full_cat_b_licence_tractor? do
  option :yes => :tractor_entitled # A34
  option :no => :how_old_are_you_tractor? # Q24
end

## Q24
multiple_choice :how_old_are_you_tractor? do
  option "under-16" => :tractor_not_old_enough # A35
  option "16" => :tractor_apply_for_provisional_conditional_licence # A36
  option "17-or-over" => :tractor_apply_for_provisional_entitlement # A37
end

## Specialist vehicles
##
## Q25
multiple_choice :full_cat_b_licence_sv? do
  option :yes => :how_old_are_you_licence_sv? # Q26
  option :no => :how_old_are_you_no_licence_sv? # Q27
end

## Q26
multiple_choice :how_old_are_you_licence_sv? do
  option "17-20" => :sv_entitled_cat_k # A38
  option "21-or-over" => :sv_entitled_cat_k_provisional_g_h # A39
end

## Q27
multiple_choice :how_old_are_you_no_licence_sv? do
  option "under-16" => :sv_not_old_enough # A40
  option "16" => :sv_entitled_cat_k_mower # A41
  option "17-20" => :sv_entitled_cat_k_conditional_g_h # A42
  option "21-or-over" => :sv_entitled_no_licence # A43
end

## Q28
multiple_choice :full_cat_b_licence_quad? do
  option :yes => :quad_entitled # A44
  option :no => :how_old_are_you_quad? # Q29
end

## Q29
multiple_choice :how_old_are_you_quad? do
  option "under-16" => :quad_not_old_enough # A45
  option "16" => :quad_disability_conditional_entitlement # A46
  option "17-or-over" => :quad_apply_for_provisional_entitlement # A47
end

outcome :not_old_enough # A2
outcome :mobility_rate_clause # A3
outcome :entitled_for_provisional_licence # A4
outcome :entitled_for_any_motorcycle # A5
outcome :entitled_for_same_motorcycle # A6
outcome :entitled_for_any_motorcycle_21 # A7
outcome :entitled_for_same_motorcycle_21 # A8
outcome :motorcycle_entitlement_over_22 # A9
outcome :motorcycle_entitlement_no_licence_under_17 # A10
outcome :motorcycle_entitlement_no_licence_17_20 # A11
outcome :motorcycle_entitlement_no_licence_21_and_over # A12
outcome :moped_entitlement_licence_pre_2001 # A13
outcome :moped_entitlement_licence_post_2001 # A14
outcome :moped_not_old_enough # A15
outcome :moped_apply_for_provisional # A16
outcome :entitled_for_msv # A17
outcome :not_entitled_for_msv_until_18 # A18
outcome :apply_for_provisional_msv_entitlement # A19
outcome :cat_b_licence_required # A20
outcome :not_entitled_for_lorry_until_18 # A21
outcome :limited_entitlement_lorry # A22
outcome :apply_for_provisional_cat_c_entitlement # A23
outcome :apply_for_conditional_provisional_cat_c_entitlement # A24
outcome :cat_b_driving_licence_required # A25
outcome :psv_entitled # A26
outcome :psv_conditional_entitlement # A27
outcome :psv_limited_entitlement # A28
outcome :bus_exceptions_under_21 # A29
outcome :bus_apply_for_cat_d # A32
outcome :bus_apply_for_cat_b # A33
outcome :tractor_entitled # A34
outcome :tractor_not_old_enough # A35
outcome :tractor_apply_for_provisional_conditional_licence # A36
outcome :tractor_apply_for_provisional_entitlement # A37
outcome :sv_entitled_cat_k # A38
outcome :sv_entitled_cat_k_provisional_g_h # A39
outcome :sv_not_old_enough # A40
outcome :sv_entitled_cat_k_mower # A41
outcome :sv_entitled_cat_k_conditional_g_h # A42
outcome :sv_entitled_no_licence # A43
outcome :quad_entitled # A44
outcome :quad_not_old_enough # A45
outcome :quad_disability_conditional_entitlement # A46
outcome :quad_apply_for_provisional_entitlement # A47
