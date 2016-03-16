module SmartAnswer
  class TowingRulesFlow < Flow
    def define
      content_id "7bab842c-a9aa-4369-b162-4e3e2a475245"
      name 'towing-rules'
      status :published
      satisfies_need "101014"

      ## Cars and light vehicles
      ##
      ## Q1
      multiple_choice :towing_vehicle_type? do
        option "car-or-light-vehicle"
        option "medium-sized-vehicle"
        option "large-vehicle"
        option "minibus"
        option "bus"

        next_node do |response|
          case response
          when 'car-or-light-vehicle'
            question :existing_towing_entitlements? #Q2
          when 'medium-sized-vehicle'
            question :medium_sized_vehicle_licenceholder? #Q8
          when 'large-vehicle'
            question :existing_large_vehicle_licence? #Q20
          when 'minibus'
            question :car_licence_before_jan_1997? #Q25
          when 'bus'
            question :bus_licenceholder? #Q36
          end
        end
      end

      ## Q2
      multiple_choice :existing_towing_entitlements? do
        option :yes
        option :no

        next_node do |response|
          case response
          when 'yes'
            question :how_long_entitlements? #Q2A
          when 'no'
            question :date_licence_was_issued? #Q5
          end
        end
      end

      ## Q2A
      multiple_choice :how_long_entitlements? do
        option "before-19-Jan-2013"
        option "after-19-Jan-2013"

        next_node do |response|
          case response
          when 'before-19-Jan-2013'
            outcome :car_light_vehicle_entitlement #A3
          when 'after-19-Jan-2013'
            outcome :full_entitlement #A4
          end
        end
      end

      ## Q5
      multiple_choice :date_licence_was_issued? do
        option "licence-issued-before-19-Jan-2013"
        option "licence-issued-after-19-Jan-2013"

        next_node do |response|
          case response
          when 'licence-issued-before-19-Jan-2013'
            outcome :limited_trailer_entitlement #A6
          when 'licence-issued-after-19-Jan-2013'
            outcome :limited_trailer_entitlement_2013 #A7
          end
        end
      end

      ## Medium sized vehicles
      ##
      ## Q8
      multiple_choice :medium_sized_vehicle_licenceholder? do
        option :yes
        option :no

        next_node do |response|
          case response
          when 'yes'
            question :how_old_are_you_msv? #Q9
          when 'no'
            question :existing_large_vehicle_towing_entitlements? #Q12
          end
        end
      end

      ## Q9
      multiple_choice :how_old_are_you_msv? do
        option "under-21"
        option "21-or-over"

        next_node do |response|
          case response
          when 'under-21'
            outcome :limited_conditional_trailer_entitlement_msv #A10
          when '21-or-over'
            outcome :limited_trailer_entitlement_msv #A11
          end
        end
      end

      ## Q12
      multiple_choice :existing_large_vehicle_towing_entitlements? do
        option :yes
        option :no

        next_node do |response|
          case response
          when 'yes'
            outcome :included_entitlement_msv #A13
          when 'no'
            question :date_licence_was_issued_msv? #Q14
          end
        end
      end

      ## Q14
      multiple_choice :date_licence_was_issued_msv? do
        option "before-jan-1997"
        option "from-jan-1997"

        next_node do |response|
          case response
          when 'before-jan-1997'
            outcome :full_entitlement_msv #A15
          when 'from-jan-1997'
            question :how_old_are_you_msv_2? #Q16
          end
        end
      end

      ## Q16
      multiple_choice :how_old_are_you_msv_2? do
        option "under-18"
        option "under-21"
        option "21-or-over"

        next_node do |response|
          case response
          when 'under-18'
            outcome :too_young_msv #A17
          when 'under-21'
            outcome :apply_for_provisional_with_exceptions_msv #A18
          when '21-or-over'
            outcome :apply_for_provisional_msv #19
          end
        end
      end

      ## Large vehicles
      ##
      ## Q20
      multiple_choice :existing_large_vehicle_licence? do
        option :yes
        option :no

        next_node do |response|
          case response
          when 'yes'
            outcome :full_cat_c_entitlement #A21
          when 'no'
            question :how_old_are_you_lv? #Q22
          end
        end
      end

      ## Q22
      multiple_choice :how_old_are_you_lv? do
        option "under-21"
        option "21-or-over"

        next_node do |response|
          case response
          when 'under-21'
            outcome :not_old_enough_lv #A23
          when '21-or-over'
            outcome :apply_for_provisional_lv #A24
          end
        end
      end

      ## Minibuses
      ##
      ## Q25
      multiple_choice :car_licence_before_jan_1997? do
        option :yes
        option :no

        next_node do |response|
          case response
          when 'yes'
            outcome :full_entitlement_minibus #A26
          when 'no'
            question :do_you_have_lv_or_bus_towing_entitlement? #Q27
          end
        end
      end

      ## Q27
      multiple_choice :do_you_have_lv_or_bus_towing_entitlement? do
        option :yes
        option :no

        next_node do |response|
          case response
          when 'yes'
            outcome :included_entitlement_minibus #A28
          when 'no'
            question :full_minibus_licence? #Q29
          end
        end
      end

      ## Q29
      multiple_choice :full_minibus_licence? do
        option :yes
        option :no

        next_node do |response|
          case response
          when 'yes'
            outcome :limited_towing_entitlement_minibus #A30
          when 'no'
            question :how_old_are_you_minibus? #Q31
          end
        end
      end

      ## Q31
      multiple_choice :how_old_are_you_minibus? do
        option "under-21"
        option "21-or-over"

        next_node do |response|
          case response
          when 'under-21'
            outcome :not_old_enough_minibus #A32
          when '21-or-over'
            outcome :limited_overall_entitlement_minibus #A34
          end
        end
      end

      ## Buses
      ##
      ## Q36
      multiple_choice :bus_licenceholder? do
        option :yes
        option :no

        next_node do |response|
          case response
          when 'yes'
            outcome :full_entitlement_bus #A37
          when 'no'
            question :how_old_are_you_bus? #Q38
          end
        end
      end

      ## Q38
      multiple_choice :how_old_are_you_bus? do
        option "under-21"
        option "21-or-over"

        next_node do |response|
          case response
          when 'under-21'
            outcome :not_old_enough_bus #A39
          when '21-or-over'
            outcome :apply_for_provisional_bus #A40
          end
        end
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
