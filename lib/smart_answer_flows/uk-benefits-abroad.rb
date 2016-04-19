module SmartAnswer
  class UkBenefitsAbroadFlow < Flow
    def define
      content_id "e1eaf183-1211-4fd7-b439-5c94498814ef"
      name 'uk-benefits-abroad'
      status :published
      satisfies_need "100490"

      exclude_countries = %w(british-antarctic-territory french-guiana guadeloupe holy-see martinique mayotte reunion st-maarten)
      additional_countries = [OpenStruct.new(slug: "jersey", name: "Jersey"), OpenStruct.new(slug: "guernsey", name: "Guernsey")]

      countries_of_former_yugoslavia = %w(bosnia-and-herzegovina kosovo macedonia montenegro serbia).freeze

      # Q1
      multiple_choice :going_or_already_abroad? do
        option :going_abroad
        option :already_abroad
        save_input_as :going_or_already_abroad

        calculate :country_question_title do
          if going_or_already_abroad == "going_abroad"
            "Which country are you moving to?"
          else
            "Which country are you living in?"
          end
        end

        calculate :why_abroad_question_title do
          if going_or_already_abroad == "going_abroad"
            "Why are you going abroad?"
          else
            "Why have you gone abroad?"
          end
        end

        calculate :going_abroad do
          going_or_already_abroad == 'going_abroad'
        end

        calculate :already_abroad do
          going_or_already_abroad == 'already_abroad'
        end

        calculate :already_abroad_text_two do
          " or permanently" if already_abroad
        end

        next_node do
          question :which_benefit?
        end
      end

      # Q2 going_abroad and Q3 already_abroad
      multiple_choice :which_benefit? do
        option :jsa
        option :pension
        option :winter_fuel_payment
        option :maternity_benefits
        option :child_benefit
        option :iidb
        option :ssp
        option :esa
        option :disability_benefits
        option :bereavement_benefits
        option :tax_credits
        option :income_support

        save_input_as :benefit

        calculate :how_long_question_titles do
          if benefit == "disability_benefits"
            "How long will you be abroad for?"
          else
            if going_or_already_abroad == "going_abroad"
              "How long are you going abroad for?"
            else
              "How long will you be living abroad for?"
            end
          end
        end

        next_node do |response|
          if %w{winter_fuel_payment maternity_benefits child_benefit ssp bereavement_benefits}.include?(response)
            question :which_country?
          elsif response == 'iidb'
            question :iidb_already_claiming?
          elsif response == 'esa'
            question :esa_how_long_abroad?
          elsif response == 'disability_benefits'
            question :db_how_long_abroad?
          elsif response == 'tax_credits'
            question :eligible_for_tax_credits?
          elsif going_abroad
            if response == 'jsa'
              question :jsa_how_long_abroad? # Q3 going_abroad
            elsif response == 'pension'
              outcome :pension_going_abroad_outcome # A2 going_abroad
            elsif response == 'income_support'
              question :is_how_long_abroad? # Q32 going_abroad
            end
          elsif already_abroad
            if response == 'jsa'
              question :which_country?
            elsif response == 'pension'
              outcome :pension_already_abroad_outcome # A2 already_abroad
            elsif response == 'income_support'
              outcome :is_already_abroad_outcome #A40 already_abroad
            end
          end
        end
      end

      ## Country Question - Shared
      country_select :which_country?, additional_countries: additional_countries, exclude_countries: exclude_countries do
        save_input_as :country

        calculate :country_name do
          (WorldLocation.all + additional_countries).find { |c| c.slug == country }.name
        end

        next_node_calculation :responded_with_eea_country do |response|
          %w(austria belgium bulgaria croatia cyprus czech-republic denmark estonia
             finland france germany gibraltar greece hungary iceland ireland italy
             latvia liechtenstein lithuania luxembourg malta netherlands norway
             poland portugal romania slovakia slovenia spain sweden switzerland).include?(response)
        end

        next_node_calculation :responded_with_former_yugoslavia do |response|
          countries_of_former_yugoslavia.include?(response)
        end

        next_node_calculation :social_security_countries_jsa do |response|
          (countries_of_former_yugoslavia + %w(guernsey jersey new-zealand)).include?(response)
        end

        next_node_calculation :social_security_countries_iidb do |response|
          (countries_of_former_yugoslavia +
          %w(barbados bermuda guernsey jersey israel jamaica mauritius philippines turkey)).include?(response)
        end

        next_node_calculation :social_security_countries_bereavement_benefits do |response|
          (countries_of_former_yugoslavia +
          %w(barbados bermuda canada guernsey jersey israel jamaica mauritius new-zealand philippines turkey usa)).include?(response)
        end

        next_node do |response|
          case benefit
          when 'jsa'
            if already_abroad && responded_with_eea_country
              outcome :jsa_eea_already_abroad_outcome # A3 already_abroad
            elsif already_abroad && social_security_countries_jsa
              outcome :jsa_social_security_already_abroad_outcome # A4 already_abroad
            elsif going_abroad && responded_with_eea_country
              outcome :jsa_eea_going_abroad_outcome # A5 going_abroad
            elsif going_abroad && social_security_countries_jsa
              outcome :jsa_social_security_going_abroad_outcome # A6 going_abroad
            else
              outcome :jsa_not_entitled_outcome # A7 going_abroad and A5 already_abroad
            end
          when 'maternity_benefits'
            if responded_with_eea_country
              question :working_for_a_uk_employer? # Q8 going_abroad and Q7 already_abroad
            else
              question :employer_paying_ni? # Q10, Q11, Q16 going_abroad and Q9, Q10, Q15 already_abroad
            end
          when 'winter_fuel_payment'
            if responded_with_eea_country
              if going_abroad
                outcome :wfp_going_abroad_outcome # A9 going_abroad
              else
                outcome :wfp_eea_eligible_outcome # A7 already_abroad
              end
            else
              outcome :wfp_not_eligible_outcome # A8 going_abroad and A6 already_abroad
            end
          when 'child_benefit'
            if responded_with_eea_country
              question :do_either_of_the_following_apply? # Q13 going_abroad and Q12 already_abroad
            elsif responded_with_former_yugoslavia
              if going_abroad
                outcome :child_benefit_fy_going_abroad_outcome # A14 going_abroad
              else
                outcome :child_benefit_fy_already_abroad_outcome # A12 already_abroad
              end
            elsif %w(barbados canada guernsey israel jersey mauritius new-zealand).include?(response)
              outcome :child_benefit_ss_outcome # A15 going_abroad and A13 already_abroad
            elsif %w(jamaica turkey usa).include?(response)
              outcome :child_benefit_jtu_outcome # A14 already_abroad
            else
              outcome :child_benefit_not_entitled_outcome # A18 going_abroad and A16 already_abroad
            end
          when 'iidb'
            if going_abroad
              if responded_with_eea_country
                outcome :iidb_going_abroad_eea_outcome # A32 going_abroad
              elsif social_security_countries_iidb
                outcome :iidb_going_abroad_ss_outcome # A33 going_abroad
              else
                outcome :iidb_going_abroad_other_outcome # A34 going_abroad
              end
            elsif already_abroad
              if responded_with_eea_country
                outcome :iidb_already_abroad_eea_outcome # A31 already_abroad
              elsif social_security_countries_iidb
                outcome :iidb_already_abroad_ss_outcome # A32 already_abroad
              else
                outcome :iidb_already_abroad_other_outcome # A33 already_abroad
              end
            end
          when 'disability_benefits'
            if responded_with_eea_country
              question :db_claiming_benefits? # Q30 going_abroad and Q29 already_abroad
            elsif going_abroad
              outcome :db_going_abroad_other_outcome # A36 going_abroad
            else
              outcome :db_already_abroad_other_outcome # A35 already_abroad
            end
          when 'ssp'
            if responded_with_eea_country
              question :working_for_uk_employer_ssp? # Q15 going_abroad and Q14 already_abroad
            else
              question :employer_paying_ni? # Q10, Q11, Q16 going_abroad and Q9, Q10, Q15 already_abroad
            end
          when 'tax_credits'
            if responded_with_eea_country
              question :tax_credits_currently_claiming? # Q20 already_abroad
            else
              outcome :tax_credits_unlikely_outcome # A21 already_abroad and A23 going_abroad
            end
          when 'esa'
            if going_abroad
              if responded_with_eea_country
                outcome :esa_going_abroad_eea_outcome # A29 going_abroad
              elsif responded_with_former_yugoslavia
                outcome :esa_going_abroad_eea_outcome
              elsif %w(barbados guernsey israel jersey jamaica turkey usa).include?(response)
                outcome :esa_going_abroad_eea_outcome
              else
                outcome :esa_going_abroad_other_outcome # A30 going_abroad
              end
            elsif already_abroad
              if responded_with_eea_country
                outcome :esa_already_abroad_eea_outcome # A27 already_abroad
              elsif responded_with_former_yugoslavia
                outcome :esa_already_abroad_ss_outcome # A28 already_abroad
              elsif %w(barbados jersey guernsey jamaica turkey usa).include?(response)
                outcome :esa_already_abroad_ss_outcome
              else
                outcome :esa_already_abroad_other_outcome # A29 already_abroad
              end
            end
          when 'bereavement_benefits'
            if going_abroad
              if responded_with_eea_country
                outcome :bb_going_abroad_eea_outcome # A39 going_abroad
              elsif social_security_countries_bereavement_benefits
                outcome :bb_going_abroad_ss_outcome # A40 going_abroad
              else
                outcome :bb_going_abroad_other_outcome # A38 going_abroad
              end
            elsif already_abroad
              if responded_with_eea_country
                outcome :bb_already_abroad_eea_outcome # A37 already_abroad
              elsif social_security_countries_bereavement_benefits
                outcome :bb_already_abroad_ss_outcome # A38 already_abroad
              else
                outcome :bb_already_abroad_other_outcome # A39 already_abroad
              end
            end
          end
        end
      end

      # Q8 going_abroad and Q7 already_abroad
      multiple_choice :working_for_a_uk_employer? do
        option :yes
        option :no

        next_node do |response|
          case response
          when 'yes'
            question :eligible_for_smp? # Q9 going_abroad and Q8 already_abroad
          when 'no'
            outcome :maternity_benefits_maternity_allowance_outcome # A10 going_abroad and A8 already_abroad
          end
        end
      end

      # Q9 going_abroad and Q8 already_abroad
      multiple_choice :eligible_for_smp? do
        option :yes
        option :no

        next_node do |response|
          case response
          when 'yes'
            outcome :maternity_benefits_eea_entitled_outcome # A11 going_abroad and A9 already_abroad
          when 'no'
            outcome :maternity_benefits_maternity_allowance_outcome # A10 going_abroad and A8 already_abroad
          end
        end
      end

      # Q10, Q11, Q16 going_abroad and Q9, Q10, Q15 already_abroad
      multiple_choice :employer_paying_ni? do
        option :yes
        option :no

        next_node do |response|
          # SSP benefits
          if benefit == 'ssp'
            if going_abroad
              if response == 'yes'
                outcome :ssp_going_abroad_entitled_outcome # A19 going_abroad
              else
                outcome :ssp_going_abroad_not_entitled_outcome # A20 going_abroad
              end
            elsif already_abroad
              if response == 'yes'
                outcome :ssp_already_abroad_entitled_outcome # A17 already_abroad
              else
                outcome :ssp_already_abroad_not_entitled_outcome # A18 already_abroad
              end
            end
          else
            #not SSP benefits
            if response == 'yes'
              question :eligible_for_smp? # Q9 going_abroad and Q8 already_abroad
            elsif (countries_of_former_yugoslavia + %w(barbados guernsey jersey israel turkey)).include?(country)
              if already_abroad
                outcome :maternity_benefits_social_security_already_abroad_outcome # A10 already_abroad
              else
                outcome :maternity_benefits_social_security_going_abroad_outcome # A12 going_abroad
              end
            else
              outcome :maternity_benefits_not_entitled_outcome # A13 going_abroad and A11 already_abroad
            end
          end
        end
      end

      # Q13 going_abroad and Q12 already_abroad
      multiple_choice :do_either_of_the_following_apply? do
        option :yes
        option :no

        next_node do |response|
          case response
          when 'yes'
            outcome :child_benefit_entitled_outcome # A17 going_abroad and A15 already_abroad
          when 'no'
            outcome :child_benefit_not_entitled_outcome # A18 going_abroad and A16 already_abroad
          end
        end
      end

      # Q15 going_abroad and Q14 already_abroad
      multiple_choice :working_for_uk_employer_ssp? do
        option :yes
        option :no

        next_node do |response|
          if going_abroad
            if response == 'yes'
              outcome :ssp_going_abroad_entitled_outcome # A19 going_abroad
            else
              outcome :ssp_going_abroad_not_entitled_outcome # A20 going_abroad
            end
          elsif already_abroad
            if response == 'yes'
              outcome :ssp_already_abroad_entitled_outcome # A17 already_abroad
            else
              outcome :ssp_already_abroad_not_entitled_outcome # A18 already_abroad
            end
          end
        end
      end

      # Q17 going_abroad and Q16 already_abroad
      multiple_choice :eligible_for_tax_credits? do
        option :crown_servant
        option :cross_border_worker
        option :none_of_the_above

        next_node do |response|
          case response
          when 'crown_servant'
            outcome :tax_credits_crown_servant_outcome # A19 already_abroad
          when 'cross_border_worker'
            outcome :tax_credits_cross_border_worker_outcome # A20 already_abroad
          when 'none_of_the_above'
            question :tax_credits_how_long_abroad? # Q18 going_abroad and Q17 already_abroad
          end
        end
      end

      # Q19 going_abroad and Q18 already_abroad
      multiple_choice :tax_credits_children? do
        option :yes
        option :no

        next_node do |response|
          case response
          when 'yes'
            question :which_country? # Q17
          when 'no'
            outcome :tax_credits_unlikely_outcome # A21 already_abroad and A23 going_abroad
          end
        end
      end

      # Q20 already_abroad
      multiple_choice :tax_credits_currently_claiming? do
        option :yes
        option :no

        next_node do |response|
          case response
          when 'yes'
            outcome :tax_credits_eea_entitled_outcome # A22 already_abroad and A24 going_abroad
          when 'no'
            outcome :tax_credits_unlikely_outcome # A21 already_abroad and A23 going_abroad
          end
        end
      end

      # Q23 going_abroad and Q22 already_abroad
      multiple_choice :tax_credits_why_going_abroad? do
        option :tax_credits_holiday
        option :tax_credits_medical_treatment
        option :tax_credits_death

        next_node do |response|
          case response
          when 'tax_credits_holiday'
            outcome :tax_credits_holiday_outcome # A23 already_abroad and A25 going_abroad and A26 going_abroad
          when 'tax_credits_medical_treatment', 'tax_credits_death'
            outcome :tax_credits_medical_death_outcome #A24 already_abroad
          end
        end
      end

      # Q26 going_abroad and Q25 already_abroad
      multiple_choice :iidb_already_claiming? do
        option :yes
        option :no

        next_node do |response|
          case response
          when 'yes'
            question :which_country? # Shared question
          when 'no'
            outcome :iidb_maybe_outcome # A30 already_abroad and A31 going_abroad
          end
        end
      end

      # Q30 going_abroad and Q29 already_abroad
      multiple_choice :db_claiming_benefits? do
        option :yes
        option :no

        next_node do |response|
          if going_abroad
            if response == 'yes'
              outcome :db_going_abroad_eea_outcome # A37 going_abroad
            else
              outcome :db_going_abroad_other_outcome # A36 going_abroad
            end
          elsif already_abroad
            if response == 'yes'
              outcome :db_already_abroad_eea_outcome # A36 already_abroad
            else
              outcome :db_already_abroad_other_outcome # A35 already_abroad
            end
          end
        end
      end

      # Q33 going_abroad
      multiple_choice :is_claiming_benefits? do
        option :yes
        option :no

        next_node do |response|
          case response
          when 'yes'
            outcome :is_claiming_benefits_outcome # A43 going_abroad
          when 'no'
            question :is_either_of_the_following? # Q34 going_abroad
          end
        end
      end

      # Q34 going_abroad
      multiple_choice :is_either_of_the_following? do
        option :yes
        option :no

        next_node do |response|
          case response
          when 'yes'
            question :is_abroad_for_treatment? # Q35 going_abroad
          when 'no'
            question :is_any_of_the_following_apply? # Q37 going_abroad
          end
        end
      end

      # Q35 going_abroad
      multiple_choice :is_abroad_for_treatment? do
        option :yes
        option :no

        next_node do |response|
          case response
          when 'yes'
            outcome :is_abroad_for_treatment_outcome # A44 going_abroad
          when 'no'
            question :is_work_or_sick_pay? # Q36 going_abroad
          end
        end
      end

      # Q36 going_abroad
      multiple_choice :is_work_or_sick_pay? do
        option :yes
        option :no

        next_node do |response|
          case response
          when 'yes'
            outcome :is_abroad_for_treatment_outcome # A44 going_abroad
          when 'no'
            outcome :is_not_eligible_outcome # A45 going_abroad
          end
        end
      end

      # Q37 going_abroad
      multiple_choice :is_any_of_the_following_apply? do
        option :yes
        option :no

        next_node do |response|
          case response
          when 'yes'
            outcome :is_not_eligible_outcome # A45 going_abroad
          when 'no'
            outcome :is_abroad_for_treatment_outcome # A44 going_abroad
          end
        end
      end

      # Going abroad questions
      # Going abroad Q3 going_abroad
      multiple_choice :jsa_how_long_abroad? do
        option :less_than_a_year_medical
        option :less_than_a_year_other
        option :more_than_a_year

        save_input_as :how_long_abroad_jsa

        next_node do |response|
          case response
          when 'less_than_a_year_medical'
            outcome :jsa_less_than_a_year_medical_outcome # A3 going_abroad
          when 'less_than_a_year_other'
            outcome :jsa_less_than_a_year_other_outcome # A4 going_abroad
          when 'more_than_a_year'
            question :which_country?
          end
        end
      end
      # Going abroad Q18 (tax credits) and Q17 already_abroad
      multiple_choice :tax_credits_how_long_abroad? do
        option :tax_credits_up_to_a_year
        option :tax_credits_more_than_a_year

        next_node do |response|
          case response
          when 'tax_credits_up_to_a_year'
            question :tax_credits_why_going_abroad? #Q23 going_abroad and Q22 already_abroad
          when 'tax_credits_more_than_a_year'
            question :tax_credits_children? # Q19 going_abroad and Q18 already_abroad
          end
        end
      end

      # Going abroad Q24 going_abroad (ESA) and Q23 already_abroad
      multiple_choice :esa_how_long_abroad? do
        option :esa_under_a_year_medical
        option :esa_under_a_year_other
        option :esa_more_than_a_year

        next_node do |response|
          if going_abroad && response == 'esa_under_a_year_medical'
            outcome :esa_going_abroad_under_a_year_medical_outcome # A27 going_abroad
          elsif going_abroad && response == 'esa_under_a_year_other'
            outcome :esa_going_abroad_under_a_year_other_outcome # A28 going_abroad
          elsif already_abroad && response == 'esa_under_a_year_medical'
            outcome :esa_already_abroad_under_a_year_medical_outcome # A25 already_abroad
          elsif already_abroad && response == 'esa_under_a_year_other'
            outcome :esa_already_abroad_under_a_year_other_outcome # A26 already_abroad
          else
            question :which_country?
          end
        end
      end

      # Going abroad Q28 going_abroad (Disability Benefits) and Q27 already_abroad
      multiple_choice :db_how_long_abroad? do
        option :temporary
        option :permanent

        next_node do |response|
          if response == 'permanent'
            question :which_country? # Q25
          elsif going_abroad
            outcome :db_going_abroad_temporary_outcome # A35 going_abroad
          else
            outcome :db_already_abroad_temporary_outcome # A34 already_abroad
          end
        end
      end

      # Going abroad Q32 going_abroad (Income Support)
      multiple_choice :is_how_long_abroad? do
        option :is_under_a_year_medical
        option :is_under_a_year_other
        option :is_more_than_a_year

        next_node do |response|
          case response
          when 'is_under_a_year_medical'
            outcome :is_under_a_year_medical_outcome # A42 going_abroad
          when 'is_under_a_year_other'
            question :is_claiming_benefits? # Q33 going_abroad
          when 'is_more_than_a_year'
            outcome :is_more_than_a_year_outcome # A41 going_abroad
          end
        end
      end

      outcome :pension_going_abroad_outcome # A2 going_abroad
      outcome :jsa_less_than_a_year_medical_outcome # A3 going_abroad
      outcome :jsa_less_than_a_year_other_outcome # A4 going_abroad
      outcome :jsa_eea_going_abroad_outcome # A5 going_abroad
      outcome :jsa_social_security_going_abroad_outcome # A6 going_abroad
      outcome :jsa_not_entitled_outcome # A7 going_abroad and A5 already_abroad
      outcome :wfp_not_eligible_outcome # A8 going_abroad and A6 already_abroad
      outcome :wfp_going_abroad_outcome # A9 going_abroad
      outcome :maternity_benefits_maternity_allowance_outcome # A10 going_abroad and A8 already_abroad
      outcome :maternity_benefits_social_security_going_abroad_outcome # A12 going_abroad
      outcome :maternity_benefits_not_entitled_outcome # A13 going_abroad and A11 already_abroad
      outcome :child_benefit_fy_going_abroad_outcome # A14 going_abroad
      outcome :child_benefit_ss_outcome # A15 going_abroad and A13 already_abroad
      outcome :child_benefit_entitled_outcome # A17 going_abroad and A15 already_abroad
      outcome :child_benefit_not_entitled_outcome # A18 going_abroad and A16 already_abroad
      outcome :ssp_going_abroad_entitled_outcome # A19 going_abroad
      outcome :ssp_going_abroad_not_entitled_outcome # A20 going_abroad

      outcome :jsa_eea_already_abroad_outcome # A3 already_abroad
      outcome :jsa_social_security_already_abroad_outcome # A4 already_abroad
      outcome :pension_already_abroad_outcome # A2 already_abroad
      outcome :wfp_eea_eligible_outcome # A7 already_abroad
      outcome :maternity_benefits_eea_entitled_outcome # A11 going_abroad and A9 already_abroad
      outcome :maternity_benefits_social_security_already_abroad_outcome # A10 already_abroad
      outcome :child_benefit_fy_already_abroad_outcome # A12 already_abroad
      outcome :child_benefit_jtu_outcome # A14 already_abroad
      outcome :ssp_already_abroad_entitled_outcome # A17 already_abroad
      outcome :ssp_already_abroad_not_entitled_outcome # A18 already_abroad
      outcome :tax_credits_crown_servant_outcome # A19 already_abroad
      outcome :tax_credits_cross_border_worker_outcome # A20 already_abroad and A22 going_abroad
      outcome :tax_credits_unlikely_outcome #A21 already_abroad and A23 going_abroad
      outcome :tax_credits_eea_entitled_outcome # A22 already_abroad and A24 going_abroad
      outcome :tax_credits_holiday_outcome # A23 already_abroad and A25 going_abroad and A26 going_abroad
      outcome :esa_going_abroad_under_a_year_medical_outcome # A27 going_abroad
      outcome :esa_going_abroad_under_a_year_other_outcome # A28 going_abroad
      outcome :esa_going_abroad_eea_outcome # A29 going_abroad
      outcome :esa_going_abroad_other_outcome # A30 going_abroad
      outcome :iidb_going_abroad_eea_outcome # A32 going_abroad
      outcome :iidb_going_abroad_ss_outcome # A33 going_abroad
      outcome :iidb_going_abroad_other_outcome # A34 going_abroad
      outcome :db_going_abroad_temporary_outcome # A35 going_abroad
      outcome :db_going_abroad_other_outcome # A36 going_abroad
      outcome :db_going_abroad_eea_outcome # A37 going_abroad
      outcome :bb_going_abroad_other_outcome # A38 going_abroad
      outcome :bb_going_abroad_eea_outcome # A39 going_abroad
      outcome :bb_going_abroad_ss_outcome # A40 going_abroad
      outcome :is_more_than_a_year_outcome # A41 going_abroad
      outcome :is_under_a_year_medical_outcome # A42 going_abroad
      outcome :is_claiming_benefits_outcome # A43 going_abroad
      outcome :is_abroad_for_treatment_outcome # A44 going_abroad
      outcome :is_not_eligible_outcome # A45 going_abroad

      outcome :tax_credits_medical_death_outcome # A24 already_abroad
      outcome :esa_already_abroad_under_a_year_medical_outcome # A25 already_abroad
      outcome :esa_already_abroad_under_a_year_other_outcome # A26 already_abroad
      outcome :esa_already_abroad_eea_outcome # A27 already_abroad
      outcome :esa_already_abroad_ss_outcome # A28 already_abroad
      outcome :esa_already_abroad_other_outcome # A29 already_abroad
      outcome :iidb_maybe_outcome # A 30 already_abroad and A31 going_abroad
      outcome :iidb_already_abroad_eea_outcome # A31 already_abroad
      outcome :iidb_already_abroad_ss_outcome # A32 already_abroad
      outcome :iidb_already_abroad_other_outcome # A33 already_abroad
      outcome :db_already_abroad_temporary_outcome # A34 already_abroad
      outcome :db_already_abroad_other_outcome # A35 already_abroad
      outcome :db_already_abroad_eea_outcome # A36 already_abroad
      outcome :bb_already_abroad_eea_outcome # A37 already_abroad
      outcome :bb_already_abroad_ss_outcome  # A38 already_abroad
      outcome :bb_already_abroad_other_outcome # A39 already_abroad
      outcome :is_already_abroad_outcome # A40 already_abroad
    end
  end
end
