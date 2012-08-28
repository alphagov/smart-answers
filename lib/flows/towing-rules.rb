satisfies_need 9999
section_slug "family"
subsection_slug "driving"
status :draft

## Cars and light vehicles
##
## Q1
multiple_choice :towing_vehicle_type? do
  option "car-or-light-vehicle" => :existing_towing_entitlements? #Q2
  option "medium-sized-vehicle" => :medium_sized_vehicle_licenceholder? #Q8
#  option "large-vehicle" => #Q20
#  option "minibus" => #Q25
#  option "bus" => #Q36
end

## Q2
multiple_choice :existing_towing_entitlements? do
  option :yes => :full_entitlement #A3
  option :no => :date_licence_was_issued? #Q4
end

## Q4
multiple_choice :date_licence_was_issued? do
  option "before-jan-1997" => :car_light_vehicle_entitlement #A5
  option "from-jan-1997" => :limited_trailer_entitlement #A6
end

## Medium sized vehicles
##
## Q8
multiple_choice :medium_sized_vehicle_licenceholder? do
  option :yes => :how_old_are_you_msv? #Q9
  option :no => :existing_large_vehicle_towing_entitlements? #Q12
end

## Q9
multiple_choice :how_old_are_you_msv? do
  option "under-21" => :limited_conditional_trailer_entitlement_msv #A10
  option "21-or-over" => :limited_trailer_entitlement_msv #A11
end

## Q12
multiple_choice :existing_large_vehicle_towing_entitlements? do
  option :yes => :included_entitlement_msv #A13
  option :no => :date_licence_was_issued_msv? #Q14
end

## Q14
multiple_choice :date_licence_was_issued_msv? do
  option "before-jan-1997" => :full_entitlement_msv #A15
  option "from-jan-1997" => :how_old_are_you_msv_2? #Q16  
end

## Q16
multiple_choice :how_old_are_you_msv_2? do
  option "under-18" => :too_young_msv #A17
  option "21" => :apply_for_provisional_with_exceptions_msv #A18
  option "21-or-over" => :apply_for_provisional_msv #19
end

## Large vehicles
##
## Q20


outcome :full_entitlement # A3
outcome :car_light_vehicle_entitlement #A5
outcome :limited_trailer_entitlement #A6
outcome :limited_conditional_trailer_entitlement_msv #A10
outcome :limited_trailer_entitlement_msv #A11
outcome :included_entitlement_msv #A13
outcome :full_entitlement_msv #A15
outcome :too_young_msv #A17
outcome :apply_for_provisional_with_exceptions_msv #A18
outcome :apply_for_provisional_msv #A19

