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
            PhraseList.new(:going_abroad_country_question_title)
          else
            PhraseList.new(:already_abroad_country_question_title)
          end
        end

        calculate :why_abroad_question_title do
          if going_or_already_abroad == "going_abroad"
            PhraseList.new(:why_going_abroad_title)
          else
            PhraseList.new(:why_already_abroad_title)
          end
        end

        calculate :going_abroad do
          going_or_already_abroad == 'going_abroad'
        end

        calculate :already_abroad do
          going_or_already_abroad == 'already_abroad'
        end

        calculate :already_abroad_text_two do |response|
          PhraseList.new(:already_abroad_text_two) if already_abroad
        end

        next_node :which_benefit?
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
            PhraseList.new(:disability_benefits_how_long_question_title)
          else
            if going_or_already_abroad == "going_abroad"
              PhraseList.new(:going_abroad_how_long_question_title)
            else
              PhraseList.new(:already_abroad_how_long_question_title)
            end
          end
        end

        permitted_next_nodes = [
          :db_how_long_abroad?,
          :eligible_for_tax_credits?,
          :esa_how_long_abroad?,
          :iidb_already_claiming?,
          :is_already_abroad_outcome,
          :is_how_long_abroad?,
          :jsa_how_long_abroad?,
          :pension_already_abroad_outcome,
          :pension_going_abroad_outcome,
          :which_country?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          if %w{winter_fuel_payment maternity_benefits child_benefit ssp bereavement_benefits}.include?(response)
            :which_country?
          elsif response == 'iidb'
            :iidb_already_claiming?
          elsif response == 'esa'
            :esa_how_long_abroad?
          elsif response == 'disability_benefits'
            :db_how_long_abroad?
          elsif response == 'tax_credits'
            :eligible_for_tax_credits?
          elsif going_abroad
            if response == 'jsa'
              :jsa_how_long_abroad? # Q3 going_abroad
            elsif response == 'pension'
              :pension_going_abroad_outcome # A2 going_abroad
            elsif response == 'income_support'
              :is_how_long_abroad? # Q32 going_abroad
            end
          elsif already_abroad
            if response == 'jsa'
              :which_country?
            elsif response == 'pension'
              :pension_already_abroad_outcome # A2 already_abroad
            elsif response == 'income_support'
              :is_already_abroad_outcome #A40 already_abroad
            end
          end
        end
      end

      ## Country Question - Shared
      country_select :which_country?,additional_countries: additional_countries, exclude_countries: exclude_countries do

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

        permitted_next_nodes = [
          :bb_already_abroad_eea_outcome,
          :bb_already_abroad_other_outcome,
          :bb_already_abroad_ss_outcome,
          :bb_going_abroad_eea_outcome,
          :bb_going_abroad_other_outcome,
          :bb_going_abroad_ss_outcome,
          :child_benefit_fy_already_abroad_outcome,
          :child_benefit_fy_going_abroad_outcome,
          :child_benefit_jtu_outcome,
          :child_benefit_not_entitled_outcome,
          :child_benefit_ss_outcome,
          :db_already_abroad_other_outcome,
          :db_claiming_benefits?,
          :db_going_abroad_other_outcome,
          :do_either_of_the_following_apply?,
          :employer_paying_ni?,
          :esa_already_abroad_eea_outcome,
          :esa_already_abroad_other_outcome,
          :esa_already_abroad_ss_outcome,
          :esa_going_abroad_eea_outcome,
          :esa_going_abroad_other_outcome,
          :iidb_already_abroad_eea_outcome,
          :iidb_already_abroad_other_outcome,
          :iidb_already_abroad_ss_outcome,
          :iidb_going_abroad_eea_outcome,
          :iidb_going_abroad_other_outcome,
          :iidb_going_abroad_ss_outcome,
          :jsa_eea_already_abroad_outcome,
          :jsa_eea_going_abroad_outcome,
          :jsa_not_entitled_outcome,
          :jsa_social_security_already_abroad_outcome,
          :jsa_social_security_going_abroad_outcome,
          :tax_credits_currently_claiming?,
          :tax_credits_unlikely_outcome,
          :wfp_eea_eligible_outcome,
          :wfp_going_abroad_outcome,
          :wfp_not_eligible_outcome,
          :working_for_a_uk_employer?,
          :working_for_uk_employer_ssp?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case benefit
          when 'jsa'
            if already_abroad && responded_with_eea_country
              :jsa_eea_already_abroad_outcome # A3 already_abroad
            elsif already_abroad && social_security_countries_jsa
              :jsa_social_security_already_abroad_outcome # A4 already_abroad
            elsif going_abroad && responded_with_eea_country
              :jsa_eea_going_abroad_outcome # A5 going_abroad
            elsif going_abroad && social_security_countries_jsa
              :jsa_social_security_going_abroad_outcome # A6 going_abroad
            else
              :jsa_not_entitled_outcome # A7 going_abroad and A5 already_abroad
            end
          when 'maternity_benefits'
            if responded_with_eea_country
              :working_for_a_uk_employer? # Q8 going_abroad and Q7 already_abroad
            else
              :employer_paying_ni? # Q10, Q11, Q16 going_abroad and Q9, Q10, Q15 already_abroad
            end
          when 'winter_fuel_payment'
            if responded_with_eea_country
              if going_abroad
                :wfp_going_abroad_outcome # A9 going_abroad
              else
                :wfp_eea_eligible_outcome # A7 already_abroad
              end
            else
              :wfp_not_eligible_outcome # A8 going_abroad and A6 already_abroad
            end
          when 'child_benefit'
            if responded_with_eea_country
              :do_either_of_the_following_apply? # Q13 going_abroad and Q12 already_abroad
            elsif responded_with_former_yugoslavia
              if going_abroad
                :child_benefit_fy_going_abroad_outcome # A14 going_abroad
              else
                :child_benefit_fy_already_abroad_outcome # A12 already_abroad
              end
            elsif %w(barbados canada guernsey israel jersey mauritius new-zealand).include?(response)
              :child_benefit_ss_outcome # A15 going_abroad and A13 already_abroad
            elsif %w(jamaica turkey usa).include?(response)
              :child_benefit_jtu_outcome # A14 already_abroad
            else
              :child_benefit_not_entitled_outcome # A18 going_abroad and A16 already_abroad
            end
          when 'iidb'
            if going_abroad
              if responded_with_eea_country
                :iidb_going_abroad_eea_outcome # A32 going_abroad
              elsif social_security_countries_iidb
                :iidb_going_abroad_ss_outcome # A33 going_abroad
              else
                :iidb_going_abroad_other_outcome # A34 going_abroad
              end
            elsif already_abroad
              if responded_with_eea_country
                :iidb_already_abroad_eea_outcome # A31 already_abroad
              elsif social_security_countries_iidb
                :iidb_already_abroad_ss_outcome # A32 already_abroad
              else
                :iidb_already_abroad_other_outcome # A33 already_abroad
              end
            end
          when 'disability_benefits'
            if responded_with_eea_country
              :db_claiming_benefits? # Q30 going_abroad and Q29 already_abroad
            elsif going_abroad
              :db_going_abroad_other_outcome # A36 going_abroad
            else
              :db_already_abroad_other_outcome # A35 already_abroad
            end
          when 'ssp'
            if responded_with_eea_country
              :working_for_uk_employer_ssp? # Q15 going_abroad and Q14 already_abroad
            else
              :employer_paying_ni? # Q10, Q11, Q16 going_abroad and Q9, Q10, Q15 already_abroad
            end
          when 'tax_credits'
            if responded_with_eea_country
              :tax_credits_currently_claiming? # Q20 already_abroad
            else
              :tax_credits_unlikely_outcome # A21 already_abroad and A23 going_abroad
            end
          when 'esa'
            if going_abroad
              if responded_with_eea_country
                :esa_going_abroad_eea_outcome # A29 going_abroad
              elsif responded_with_former_yugoslavia
                :esa_going_abroad_eea_outcome
              elsif %w(barbados guernsey israel jersey jamaica turkey usa).include?(response)
                :esa_going_abroad_eea_outcome
              else
                :esa_going_abroad_other_outcome # A30 going_abroad
              end
            elsif already_abroad
              if responded_with_eea_country
                :esa_already_abroad_eea_outcome # A27 already_abroad
              elsif responded_with_former_yugoslavia
                :esa_already_abroad_ss_outcome # A28 already_abroad
              elsif %w(barbados jersey guernsey jamaica turkey usa).include?(response)
                :esa_already_abroad_ss_outcome
              else
                :esa_already_abroad_other_outcome # A29 already_abroad
              end
            end
          when 'bereavement_benefits'
            if going_abroad
              if responded_with_eea_country
                :bb_going_abroad_eea_outcome # A39 going_abroad
              elsif social_security_countries_bereavement_benefits
                :bb_going_abroad_ss_outcome # A40 going_abroad
              else
                :bb_going_abroad_other_outcome # A38 going_abroad
              end
            elsif already_abroad
              if responded_with_eea_country
                :bb_already_abroad_eea_outcome # A37 already_abroad
              elsif social_security_countries_bereavement_benefits
                :bb_already_abroad_ss_outcome # A38 already_abroad
              else
                :bb_already_abroad_other_outcome # A39 already_abroad
              end
            end
          end
        end
      end

      # Q8 going_abroad and Q7 already_abroad
      multiple_choice :working_for_a_uk_employer? do
        option :yes
        option :no

        permitted_next_nodes = [
          :eligible_for_smp?,
          :maternity_benefits_maternity_allowance_outcome
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'yes'
            :eligible_for_smp? # Q9 going_abroad and Q8 already_abroad
          when 'no'
            :maternity_benefits_maternity_allowance_outcome # A10 going_abroad and A8 already_abroad
          end
        end
      end

      # Q9 going_abroad and Q8 already_abroad
      multiple_choice :eligible_for_smp? do
        option :yes
        option :no

        permitted_next_nodes = [
          :maternity_benefits_eea_entitled_outcome,
          :maternity_benefits_maternity_allowance_outcome
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'yes'
            :maternity_benefits_eea_entitled_outcome # A11 going_abroad and A9 already_abroad
          when 'no'
            :maternity_benefits_maternity_allowance_outcome # A10 going_abroad and A8 already_abroad
          end
        end
      end

      # Q10, Q11, Q16 going_abroad and Q9, Q10, Q15 already_abroad
      multiple_choice :employer_paying_ni? do
        option :yes
        option :no

        permitted_next_nodes = [
          :eligible_for_smp?,
          :maternity_benefits_not_entitled_outcome,
          :maternity_benefits_social_security_already_abroad_outcome,
          :maternity_benefits_social_security_going_abroad_outcome,
          :ssp_already_abroad_entitled_outcome,
          :ssp_already_abroad_not_entitled_outcome,
          :ssp_going_abroad_entitled_outcome,
          :ssp_going_abroad_not_entitled_outcome
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          # SSP benefits
          if benefit == 'ssp'
            if going_abroad
              if response == 'yes'
                :ssp_going_abroad_entitled_outcome # A19 going_abroad
              else
                :ssp_going_abroad_not_entitled_outcome # A20 going_abroad
              end
            elsif already_abroad
              if response == 'yes'
                :ssp_already_abroad_entitled_outcome # A17 already_abroad
              else
                :ssp_already_abroad_not_entitled_outcome # A18 already_abroad
              end
            end
          else
            #not SSP benefits
            if response == 'yes'
              :eligible_for_smp? # Q9 going_abroad and Q8 already_abroad
            elsif (countries_of_former_yugoslavia + %w(barbados guernsey jersey israel turkey)).include?(country)
              if already_abroad
                :maternity_benefits_social_security_already_abroad_outcome # A10 already_abroad
              else
                :maternity_benefits_social_security_going_abroad_outcome # A12 going_abroad
              end
            else
              :maternity_benefits_not_entitled_outcome # A13 going_abroad and A11 already_abroad
            end
          end
        end
      end

      # Q13 going_abroad and Q12 already_abroad
      multiple_choice :do_either_of_the_following_apply? do
        option :yes
        option :no

        permitted_next_nodes = [
          :child_benefit_entitled_outcome,
          :child_benefit_not_entitled_outcome
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'yes'
            :child_benefit_entitled_outcome # A17 going_abroad and A15 already_abroad
          when 'no'
            :child_benefit_not_entitled_outcome # A18 going_abroad and A16 already_abroad
          end
        end
      end

      # Q15 going_abroad and Q14 already_abroad
      multiple_choice :working_for_uk_employer_ssp? do
        option :yes
        option :no

        permitted_next_nodes = [
          :ssp_already_abroad_entitled_outcome,
          :ssp_already_abroad_not_entitled_outcome,
          :ssp_going_abroad_entitled_outcome,
          :ssp_going_abroad_not_entitled_outcome
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          if going_abroad
            if response == 'yes'
              :ssp_going_abroad_entitled_outcome # A19 going_abroad
            else
              :ssp_going_abroad_not_entitled_outcome # A20 going_abroad
            end
          elsif already_abroad
            if response == 'yes'
              :ssp_already_abroad_entitled_outcome # A17 already_abroad
            else
              :ssp_already_abroad_not_entitled_outcome # A18 already_abroad
            end
          end
        end
      end

      # Q17 going_abroad and Q16 already_abroad
      multiple_choice :eligible_for_tax_credits? do
        option :crown_servant
        option :cross_border_worker
        option :none_of_the_above

        permitted_next_nodes = [
          :tax_credits_crown_servant_outcome,
          :tax_credits_cross_border_worker_outcome,
          :tax_credits_how_long_abroad?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'crown_servant'
            :tax_credits_crown_servant_outcome # A19 already_abroad
          when 'cross_border_worker'
            :tax_credits_cross_border_worker_outcome # A20 already_abroad
          when 'none_of_the_above'
            :tax_credits_how_long_abroad? # Q18 going_abroad and Q17 already_abroad
          end
        end
      end

      # Q19 going_abroad and Q18 already_abroad
      multiple_choice :tax_credits_children? do
        option :yes
        option :no

        permitted_next_nodes = [
          :which_country?,
          :tax_credits_unlikely_outcome
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'yes'
            :which_country? # Q17
          when 'no'
            :tax_credits_unlikely_outcome # A21 already_abroad and A23 going_abroad
          end
        end
      end

      # Q20 already_abroad
      multiple_choice :tax_credits_currently_claiming? do
        option :yes
        option :no

        permitted_next_nodes = [
          :tax_credits_eea_entitled_outcome,
          :tax_credits_unlikely_outcome
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'yes'
            :tax_credits_eea_entitled_outcome # A22 already_abroad and A24 going_abroad
          when 'no'
            :tax_credits_unlikely_outcome # A21 already_abroad and A23 going_abroad
          end
        end
      end

      # Q23 going_abroad and Q22 already_abroad
      multiple_choice :tax_credits_why_going_abroad? do
        option :tax_credits_holiday
        option :tax_credits_medical_treatment
        option :tax_credits_death

        permitted_next_nodes = [
          :tax_credits_holiday_outcome,
          :tax_credits_medical_death_outcome
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'tax_credits_holiday'
            :tax_credits_holiday_outcome # A23 already_abroad and A25 going_abroad and A26 going_abroad
          when 'tax_credits_medical_treatment', 'tax_credits_death'
            :tax_credits_medical_death_outcome #A24 already_abroad
          end
        end
      end

      # Q26 going_abroad and Q25 already_abroad
      multiple_choice :iidb_already_claiming? do
        option :yes
        option :no

        permitted_next_nodes = [
          :which_country?,
          :iidb_maybe_outcome
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'yes'
            :which_country? # Shared question
          when 'no'
            :iidb_maybe_outcome # A30 already_abroad and A31 going_abroad
          end
        end
      end

      # Q30 going_abroad and Q29 already_abroad
      multiple_choice :db_claiming_benefits? do
        option :yes
        option :no

        permitted_next_nodes = [
          :db_already_abroad_eea_outcome,
          :db_already_abroad_other_outcome,
          :db_going_abroad_eea_outcome,
          :db_going_abroad_other_outcome
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          if going_abroad
            if response == 'yes'
              :db_going_abroad_eea_outcome # A37 going_abroad
            else
              :db_going_abroad_other_outcome # A36 going_abroad
            end
          elsif already_abroad
            if response == 'yes'
              :db_already_abroad_eea_outcome # A36 already_abroad
            else
              :db_already_abroad_other_outcome # A35 already_abroad
            end
          end
        end
      end

      # Q33 going_abroad
      multiple_choice :is_claiming_benefits? do
        option :yes
        option :no

        permitted_next_nodes = [
          :is_claiming_benefits_outcome,
          :is_either_of_the_following?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'yes'
            :is_claiming_benefits_outcome # A43 going_abroad
          when 'no'
            :is_either_of_the_following? # Q34 going_abroad
          end
        end
      end

      # Q34 going_abroad
      multiple_choice :is_either_of_the_following? do
        option :yes
        option :no

        permitted_next_nodes = [
          :is_abroad_for_treatment?,
          :is_any_of_the_following_apply?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'yes'
            :is_abroad_for_treatment? # Q35 going_abroad
          when 'no'
            :is_any_of_the_following_apply? # Q37 going_abroad
          end
        end
      end

      # Q35 going_abroad
      multiple_choice :is_abroad_for_treatment? do
        option :yes
        option :no

        permitted_next_nodes = [
          :is_abroad_for_treatment_outcome,
          :is_work_or_sick_pay?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'yes'
            :is_abroad_for_treatment_outcome # A44 going_abroad
          when 'no'
            :is_work_or_sick_pay? # Q36 going_abroad
          end
        end
      end

      # Q36 going_abroad
      multiple_choice :is_work_or_sick_pay? do
        option :yes
        option :no

        permitted_next_nodes = [
          :is_abroad_for_treatment_outcome,
          :is_not_eligible_outcome
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'yes'
            :is_abroad_for_treatment_outcome # A44 going_abroad
          when 'no'
            :is_not_eligible_outcome # A45 going_abroad
          end
        end
      end

      # Q37 going_abroad
      multiple_choice :is_any_of_the_following_apply? do
        option :yes
        option :no

        permitted_next_nodes = [
          :is_not_eligible_outcome,
          :is_abroad_for_treatment_outcome
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'yes'
            :is_not_eligible_outcome # A45 going_abroad
          when 'no'
            :is_abroad_for_treatment_outcome # A44 going_abroad
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

        permitted_next_nodes = [
          :jsa_less_than_a_year_medical_outcome,
          :jsa_less_than_a_year_other_outcome,
          :which_country?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'less_than_a_year_medical'
            :jsa_less_than_a_year_medical_outcome # A3 going_abroad
          when 'less_than_a_year_other'
            :jsa_less_than_a_year_other_outcome # A4 going_abroad
          when 'more_than_a_year'
            :which_country?
          end
        end
      end
      # Going abroad Q18 (tax credits) and Q17 already_abroad
      multiple_choice :tax_credits_how_long_abroad? do
        option :tax_credits_up_to_a_year
        option :tax_credits_more_than_a_year

        permitted_next_nodes = [
          :tax_credits_why_going_abroad?,
          :tax_credits_children?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'tax_credits_up_to_a_year'
            :tax_credits_why_going_abroad? #Q23 going_abroad and Q22 already_abroad
          when 'tax_credits_more_than_a_year'
            :tax_credits_children? # Q19 going_abroad and Q18 already_abroad
          end
        end
      end

      # Going abroad Q24 going_abroad (ESA) and Q23 already_abroad
      multiple_choice :esa_how_long_abroad? do
        option :esa_under_a_year_medical
        option :esa_under_a_year_other
        option :esa_more_than_a_year

        permitted_next_nodes = [
          :esa_already_abroad_under_a_year_medical_outcome,
          :esa_already_abroad_under_a_year_other_outcome,
          :esa_going_abroad_under_a_year_medical_outcome,
          :esa_going_abroad_under_a_year_other_outcome,
          :which_country?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          if going_abroad && response == 'esa_under_a_year_medical'
            :esa_going_abroad_under_a_year_medical_outcome # A27 going_abroad
          elsif going_abroad && response == 'esa_under_a_year_other'
            :esa_going_abroad_under_a_year_other_outcome # A28 going_abroad
          elsif already_abroad && response == 'esa_under_a_year_medical'
            :esa_already_abroad_under_a_year_medical_outcome # A25 already_abroad
          elsif already_abroad && response == 'esa_under_a_year_other'
            :esa_already_abroad_under_a_year_other_outcome # A26 already_abroad
          else
            :which_country?
          end
        end
      end

      # Going abroad Q28 going_abroad (Disability Benefits) and Q27 already_abroad
      multiple_choice :db_how_long_abroad? do
        option :temporary
        option :permanent

        permitted_next_nodes = [
          :db_already_abroad_temporary_outcome,
          :db_going_abroad_temporary_outcome,
          :which_country?
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          if response == 'permanent'
            :which_country? # Q25
          elsif going_abroad
            :db_going_abroad_temporary_outcome # A35 going_abroad
          else
            :db_already_abroad_temporary_outcome # A34 already_abroad
          end
        end
      end

      # Going abroad Q32 going_abroad (Income Support)
      multiple_choice :is_how_long_abroad? do
        option :is_under_a_year_medical
        option :is_under_a_year_other
        option :is_more_than_a_year

        permitted_next_nodes = [
          :is_under_a_year_medical_outcome,
          :is_claiming_benefits?,
          :is_more_than_a_year_outcome
        ]
        next_node(permitted: permitted_next_nodes) do |response|
          case response
          when 'is_under_a_year_medical'
            :is_under_a_year_medical_outcome # A42 going_abroad
          when 'is_under_a_year_other'
            :is_claiming_benefits? # Q33 going_abroad
          when 'is_more_than_a_year'
            :is_more_than_a_year_outcome # A41 going_abroad
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
