module SmartAnswer
  class LandlordImmigrationCheckFlow < Flow
    def define
      start_page_content_id "a6c2dbbb-a26e-4cc5-a244-48ef45523269"
      flow_content_id "61334174-53a3-4112-b6ea-1608d875ced8"
      name "landlord-immigration-check"
      status :published
      satisfies_need "102373"

      #Q0
      postcode_question :property? do
        on_response do |response|
          self.calculator = Calculators::LandlordImmigrationCheckCalculator.new
          calculator.postcode = response
        end

        next_node do
          if calculator.rules_apply?
            question :main_home?
          else
            outcome :outcome_check_not_needed
          end
        end
      end

      #Q1
      multiple_choice :main_home? do
        option "yes"
        option "no"

        next_node do |response|
          case response
          when "yes"
            question :tenant_over_18?
          when "no"
            question :property_type?
          end
        end
      end

      #Q2
      multiple_choice :tenant_over_18? do
        option "yes"
        option "no"

        next_node do |response|
          case response
          when "yes"
            question :what_nationality?
          when "no"
            outcome :outcome_check_not_needed_when_under_18
          end
        end
      end

      #Q3
      multiple_choice :property_type? do
        option "holiday_accommodation"
        option "social_housing"
        option "care_home"
        option "hostel_or_refuge"
        option "mobile_home"
        option "employee_accommodation"
        option "student_accommodation"
        option "7_year_lease_property"

        next_node do |response|
          case response
          when "holiday_accommodation"
            outcome :outcome_check_not_needed_if_holiday_or_under_3_months
          when "social_housing"
            outcome :outcome_check_not_needed
          when "care_home"
            outcome :outcome_check_not_needed_when_care_home
          when "hostel_or_refuge"
            outcome :outcome_check_not_needed_when_hostel_refuge
          when "mobile_home"
            outcome :outcome_check_not_needed_when_mobile_home
          when "employee_accommodation"
            outcome :outcome_check_not_needed_when_employee_home
          when "student_accommodation"
            outcome :outcome_check_may_be_needed_when_student
          when "7_year_lease_property"
            outcome :outcome_check_needed_if_break_clause
          end
        end
      end

      #Q3a
      multiple_choice :what_nationality? do
        option "british-or-irish"
        option "eea"
        option "non-eea"
        option "somewhere-else"

        on_response do |response|
          calculator.nationality = response
        end

        next_node do |response|
          case response
          when "british-or-irish"
            question :has_uk_passport?
          when "eea"
            question :has_eu_documents?
          when "non-eea"
            question :family_permit?
          when "somewhere-else"
            question :has_uk_passport?
          end
        end
      end

      #Q4
      multiple_choice :has_uk_passport? do
        option "yes"
        option "no"

        next_node do |response|
          case response
          when "yes"
            outcome :outcome_can_rent
          when "no"
            if calculator.from_somewhere_else?
              question :has_eu_documents?
            else
              question :has_other_documents?
            end
          end
        end
      end

      #Q5
      multiple_choice :family_permit? do
        option "yes"
        option "no"

        next_node do |response|
          case response
          when "yes"
            outcome :outcome_can_rent
          when "no"
            question :has_residence_card_or_eu_eea_swiss_family_member?
          end
        end
      end

      #Q7
      multiple_choice :has_eu_documents? do
        option "yes"
        option "no"

        next_node do |response|
          case response
          when "yes"
            outcome :outcome_can_rent
          when "no"
            if calculator.from_somewhere_else?
              question :family_permit?
            else
              question :has_other_documents?
            end
          end
        end
      end

      #Q9
      multiple_choice :has_documents? do
        option "yes"
        option "no"

        next_node do |response|
          case response
          when "yes"
            outcome :outcome_can_rent
          when "no"
            question :time_limited_to_remain?
          end
        end
      end

      #Q10
      multiple_choice :has_other_documents? do
        option "yes"
        option "no"

        next_node do |response|
          case response
          when "yes"
            outcome :outcome_can_rent
          when "no"
            if calculator.nationality == "non-eea" ||
                calculator.from_somewhere_else?
              question :waiting_for_documents?
            else
              outcome :outcome_can_not_rent
            end
          end
        end
      end

      #new Q14
      multiple_choice :waiting_for_documents? do
        option "yes"
        option "no"

        next_node do |response|
          case response
          when "yes"
            outcome :outcome_landlords_checking_service
          when "no"
            question :immigration_application?
          end
        end
      end

      #Q12
      multiple_choice :time_limited_to_remain? do
        option "yes"
        option "no"

        next_node do |response|
          case response
          when "yes"
            outcome :outcome_can_rent_but_check_will_be_needed_again
          when "no"
            outcome :has_other_documents?
          end
        end
      end

      #Q15
      multiple_choice :immigration_application? do
        option "yes"
        option "no"

        next_node do |response|
          case response
          when "yes"
            outcome :outcome_landlords_checking_service
          when "no"
            outcome :outcome_can_not_continue_renting
          end
        end
      end

      #Q13
      multiple_choice :has_residence_card_or_eu_eea_swiss_family_member? do
        option "yes"
        option "no"

        next_node do |response|
          case response
          when "yes"
            outcome :outcome_can_rent_but_check_will_be_needed_again
          when "no"
            outcome :has_documents?
          end
        end
      end

      outcome :outcome_can_not_rent
      outcome :outcome_can_not_continue_renting
      outcome :outcome_can_rent
      outcome :outcome_can_rent_but_check_will_be_needed_again
      outcome :outcome_check_may_be_needed_when_student
      outcome :outcome_check_needed_if_break_clause
      outcome :outcome_check_not_needed
      outcome :outcome_landlords_checking_service
      outcome :outcome_check_not_needed_if_holiday_or_under_3_months
      outcome :outcome_check_not_needed_when_care_home
      outcome :outcome_check_not_needed_when_employee_home
      outcome :outcome_check_not_needed_when_hostel_refuge
      outcome :outcome_check_not_needed_when_mobile_home
      outcome :outcome_check_not_needed_when_under_18
    end
  end
end
