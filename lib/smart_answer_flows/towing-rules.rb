module SmartAnswer
  class TowingRulesFlow < Flow
    def define
      name 'towing-rules'
      status :published
      satisfies_need "101014"

      ## Cars and light vehicles
      ##
      ## Q1
      multiple_choice :towing_vehicle_type? do
        option "car-or-light-vehicle" => :existing_towing_entitlements? #Q2
        option "medium-sized-vehicle" => :medium_sized_vehicle_licenceholder? #Q8
        option "large-vehicle" => :existing_large_vehicle_licence? #Q20
        option "minibus" => :car_licence_before_jan_1997? #Q25
        option "bus" => :bus_licenceholder? #Q36
      end

      ## Q2
      multiple_choice :existing_towing_entitlements? do
        option yes: :how_long_entitlements? #Q2A
        option no: :date_licence_was_issued? #Q5
      end

      ## Q2A
      multiple_choice :how_long_entitlements? do
        option :"before-19-Jan-2013" => :car_light_vehicle_entitlement #A3
        option :"after-19-Jan-2013" => :full_entitlement #A4
      end

      ## Q5
      multiple_choice :date_licence_was_issued? do
        option :"licence-issued-before-19-Jan-2013" => :limited_trailer_entitlement #A6
        option :"licence-issued-after-19-Jan-2013" => :limited_trailer_entitlement_2013 #A7
      end

      ## Medium sized vehicles
      ##
      ## Q8
      multiple_choice :medium_sized_vehicle_licenceholder? do
        option yes: :how_old_are_you_msv? #Q9
        option no: :existing_large_vehicle_towing_entitlements? #Q12
      end

      ## Q9
      multiple_choice :how_old_are_you_msv? do
        option "under-21" => :limited_conditional_trailer_entitlement_msv #A10
        option "21-or-over" => :limited_trailer_entitlement_msv #A11
      end

      ## Q12
      multiple_choice :existing_large_vehicle_towing_entitlements? do
        option yes: :included_entitlement_msv #A13
        option no: :date_licence_was_issued_msv? #Q14
      end

      ## Q14
      multiple_choice :date_licence_was_issued_msv? do
        option "before-jan-1997" => :full_entitlement_msv #A15
        option "from-jan-1997" => :how_old_are_you_msv_2? #Q16
      end

      ## Q16
      multiple_choice :how_old_are_you_msv_2? do
        option "under-18" => :too_young_msv #A17
        option "under-21" => :apply_for_provisional_with_exceptions_msv #A18
        option "21-or-over" => :apply_for_provisional_msv #19
      end

      ## Large vehicles
      ##
      ## Q20
      multiple_choice :existing_large_vehicle_licence? do
        option yes: :full_cat_c_entitlement #A21
        option no: :how_old_are_you_lv? #Q22
      end

      ## Q22
      multiple_choice :how_old_are_you_lv? do
        option "under-21" => :not_old_enough_lv #A23
        option "21-or-over" => :apply_for_provisional_lv #A24
      end

      ## Minibuses
      ##
      ## Q25
      multiple_choice :car_licence_before_jan_1997? do
        option yes: :full_entitlement_minibus #A26
        option no: :do_you_have_lv_or_bus_towing_entitlement? #Q27
      end

      ## Q27
      multiple_choice :do_you_have_lv_or_bus_towing_entitlement? do
        option yes: :included_entitlement_minibus #A28
        option no: :full_minibus_licence? #Q29
      end

      ## Q29
      multiple_choice :full_minibus_licence? do
        option yes: :limited_towing_entitlement_minibus #A30
        option no: :how_old_are_you_minibus? #Q31
      end

      ## Q31
      multiple_choice :how_old_are_you_minibus? do
        option "under-21" => :not_old_enough_minibus #A32
        option "21-or-over" => :limited_overall_entitlement_minibus #A34
      end

      ## Buses
      ##
      ## Q36
      multiple_choice :bus_licenceholder? do
        option yes: :full_entitlement_bus #A37
        option no: :how_old_are_you_bus? #Q38
      end

      ## Q38
      multiple_choice :how_old_are_you_bus? do
        option "under-21" => :not_old_enough_bus #A39
        option "21-or-over" => :apply_for_provisional_bus #A40
      end

      outcome :car_light_vehicle_entitlement # A3
      outcome :full_entitlement #A4
      outcome :limited_trailer_entitlement #A6
      outcome :limited_trailer_entitlement_2013 # A7
      outcome :limited_conditional_trailer_entitlement_msv #A10
      outcome :limited_trailer_entitlement_msv #A11
      outcome :included_entitlement_msv #A13
      outcome :full_entitlement_msv #A15
      outcome :too_young_msv #A17
      outcome :apply_for_provisional_with_exceptions_msv #A18
      outcome :apply_for_provisional_msv #A19
      outcome :full_cat_c_entitlement # A21
      outcome :not_old_enough_lv #A23
      outcome :apply_for_provisional_lv #A24
      outcome :full_entitlement_minibus #A26
      outcome :included_entitlement_minibus #A28
      outcome :limited_towing_entitlement_minibus #A30
      outcome :not_old_enough_minibus #A32
      outcome :limited_overall_entitlement_minibus #A34
      outcome :full_entitlement_bus #A37
      outcome :not_old_enough_bus # A39
      outcome :apply_for_provisional_bus #A40
    end
  end
end
