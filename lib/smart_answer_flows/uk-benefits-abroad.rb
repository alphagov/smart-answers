module SmartAnswer
  class UkBenefitsAbroadFlow < Flow
    def define
      name 'uk-benefits-abroad'
      status :published
      satisfies_need "100490"

      exclude_countries = %w(british-antarctic-territory french-guiana guadeloupe holy-see martinique mayotte reunion st-maarten)
      additional_countries = [OpenStruct.new(slug: "jersey", name: "Jersey"), OpenStruct.new(slug: "guernsey", name: "Guernsey")]

      going_abroad = SmartAnswer::Predicate::VariableMatches.new(:going_or_already_abroad, 'going_abroad', nil, 'going abroad')
      already_abroad = SmartAnswer::Predicate::VariableMatches.new(:going_or_already_abroad, 'already_abroad', nil, 'already abroad')
      responded_with_eea_country = SmartAnswer::Predicate::RespondedWith.new(
        %w(austria belgium bulgaria croatia cyprus czech-republic denmark estonia
          finland france germany gibraltar greece hungary iceland ireland italy
          latvia liechtenstein lithuania luxembourg malta netherlands norway
          poland portugal romania slovakia slovenia spain sweden switzerland),
        "EEA country"
      )
      countries_of_former_yugoslavia = %w(bosnia-and-herzegovina kosovo macedonia montenegro serbia).freeze
      responded_with_former_yugoslavia = SmartAnswer::Predicate::RespondedWith.new(
        countries_of_former_yugoslavia,
        "former Yugoslavia"
      )
      social_security_countries_jsa = responded_with_former_yugoslavia | SmartAnswer::Predicate::RespondedWith.new(%w(guernsey jersey new-zealand))
      social_security_countries_iidb = responded_with_former_yugoslavia | SmartAnswer::Predicate::RespondedWith.new(%w(barbados bermuda guernsey jersey israel jamaica mauritius philippines turkey))
      social_security_countries_bereavement_benefits = responded_with_former_yugoslavia | SmartAnswer::Predicate::RespondedWith.new(%w(barbados bermuda canada guernsey jersey israel jamaica mauritius new-zealand philippines turkey usa))

      # Q1
      multiple_choice :going_or_already_abroad? do
        option :going_abroad
        option :already_abroad
        save_input_as :going_or_already_abroad

        calculate :country_question_title do
          PhraseList.new(:"#{going_or_already_abroad}_country_question_title")
        end
        calculate :why_abroad_question_title do
          PhraseList.new(:"why_#{going_or_already_abroad}_title")
        end


        calculate :already_abroad_text do |response|
          if response == 'already_abroad'
            PhraseList.new(:already_abroad_text)
            end
        end

        calculate :already_abroad_text_two do |response|
          if response == 'already_abroad'
            PhraseList.new(:already_abroad_text_two)
          end
        end

        calculate :iidb_maybe do |response|
          if response == 'already_abroad'
            PhraseList.new(:iidb_maybe_text)
          end
        end

        next_node do
          :which_benefit?
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
            PhraseList.new(:"#{benefit}_how_long_question_title")
          else
            PhraseList.new(:"#{going_or_already_abroad}_how_long_question_title")
          end
        end

        next_node do |response|
          if response == "winter_fuel_payment"
            :which_country?
          elsif response == "maternity_benefits"
            :which_country?
          elsif response == "child_benefit"
            :which_country?
          elsif response == "iidb"
            :iidb_already_claiming?
          elsif response == "ssp"
            :which_country?
          elsif response == "esa"
            :esa_how_long_abroad?
          elsif response == "disability_benefits"
            :db_how_long_abroad?
          elsif response == "bereavement_benefits"
            :which_country?
          elsif response == "tax_credits"
            :eligible_for_tax_credits?
          elsif ['going_abroad'].include?(going_or_already_abroad)
            if response == "jsa"
              :jsa_how_long_abroad?
            elsif response == "pension"
              :pension_going_abroad_outcome
            elsif response == "income_support"
              :is_how_long_abroad?
            end
          elsif ['already_abroad'].include?(going_or_already_abroad)
            if response == "jsa"
              :which_country?
            elsif response == "pension"
              :pension_already_abroad_outcome
            elsif response == "income_support"
              :is_already_abroad_outcome
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

      #jsa
        next_node do |response|
          if ['jsa'].include?(benefit)
            if ['already_abroad'].include?(going_or_already_abroad)
              if responded_with_eea_country.call(nil, response)
                :jsa_eea_already_abroad_outcome
              elsif social_security_countries_jsa.call(nil, response)
                :jsa_social_security_already_abroad_outcome
              else
                :jsa_not_entitled_outcome
              end
            elsif ['going_abroad'].include?(going_or_already_abroad)
              if responded_with_eea_country.call(nil, response)
                :jsa_eea_going_abroad_outcome
              elsif social_security_countries_jsa.call(nil, response)
                :jsa_social_security_going_abroad_outcome
              else
                :jsa_not_entitled_outcome
              end
            end
          elsif ['maternity_benefits'].include?(benefit)
            if responded_with_eea_country.call(nil, response)
              :working_for_a_uk_employer?
            else
              :employer_paying_ni?
            end
          elsif ['winter_fuel_payment'].include?(benefit)
            if responded_with_eea_country.call(nil, response)
              if ['going_abroad'].include?(going_or_already_abroad)
                :wfp_going_abroad_outcome
              else
                :wfp_eea_eligible_outcome
              end
            else
              :wfp_not_eligible_outcome
            end
          elsif ['child_benefit'].include?(benefit)
            if responded_with_eea_country.call(nil, response)
              :do_either_of_the_following_apply?
            elsif responded_with_former_yugoslavia.call(nil, response)
              if ['going_abroad'].include?(going_or_already_abroad)
                :child_benefit_fy_going_abroad_outcome
              else
                :child_benefit_fy_already_abroad_outcome
              end
            elsif %w(barbados canada guernsey israel jersey mauritius new-zealand).include?(response)
              :child_benefit_ss_outcome
            elsif %w(jamaica turkey usa).include?(response)
              :child_benefit_jtu_outcome
            else
              :child_benefit_not_entitled_outcome
            end
          elsif ['iidb'].include?(benefit)
            if ['going_abroad'].include?(going_or_already_abroad)
              if responded_with_eea_country.call(nil, response)
                :iidb_going_abroad_eea_outcome
              elsif social_security_countries_iidb.call(nil, response)
                :iidb_going_abroad_ss_outcome
              else
                :iidb_going_abroad_other_outcome
              end
            elsif ['already_abroad'].include?(going_or_already_abroad)
              if responded_with_eea_country.call(nil, response)
                :iidb_already_abroad_eea_outcome
              elsif social_security_countries_iidb.call(nil, response)
                :iidb_already_abroad_ss_outcome
              else
                :iidb_already_abroad_other_outcome
              end
            end
          elsif ['disability_benefits'].include?(benefit)
            if responded_with_eea_country.call(nil, response)
              :db_claiming_benefits?
            elsif ['going_abroad'].include?(going_or_already_abroad)
              :db_going_abroad_other_outcome
            else
              :db_already_abroad_other_outcome
            end
          elsif ['ssp'].include?(benefit)
            if responded_with_eea_country.call(nil, response)
              :working_for_uk_employer_ssp?
            else
              :employer_paying_ni?
            end
          elsif ['tax_credits'].include?(benefit)
            if responded_with_eea_country.call(nil, response)
              :tax_credits_currently_claiming?
            else
              :tax_credits_unlikely_outcome
            end
          elsif ['esa'].include?(benefit)
            if ['going_abroad'].include?(going_or_already_abroad)
              if responded_with_eea_country.call(nil, response)
                :esa_going_abroad_eea_outcome
              elsif responded_with_former_yugoslavia.call(nil, response)
                :esa_going_abroad_eea_outcome
              elsif %w(barbados guernsey israel jersey jamaica turkey usa).include?(response)
                :esa_going_abroad_eea_outcome
              else
                :esa_going_abroad_other_outcome
              end
            elsif ['already_abroad'].include?(going_or_already_abroad)
              if responded_with_eea_country.call(nil, response)
                :esa_already_abroad_eea_outcome
              elsif responded_with_former_yugoslavia.call(nil, response)
                :esa_already_abroad_ss_outcome
              elsif %w(barbados jersey guernsey jamaica turkey usa).include?(response)
                :esa_already_abroad_ss_outcome
              else
                :esa_already_abroad_other_outcome
              end
            end
          elsif ['bereavement_benefits'].include?(benefit)
            if ['going_abroad'].include?(going_or_already_abroad)
              if responded_with_eea_country.call(nil, response)
                :bb_going_abroad_eea_outcome
              elsif social_security_countries_bereavement_benefits.call(nil, response)
                :bb_going_abroad_ss_outcome
              else
                :bb_going_abroad_other_outcome
              end
            elsif ['already_abroad'].include?(going_or_already_abroad)
              if responded_with_eea_country.call(nil, response)
                :bb_already_abroad_eea_outcome
              elsif social_security_countries_bereavement_benefits.call(nil, response)
                :bb_already_abroad_ss_outcome
              else
                :bb_already_abroad_other_outcome
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
          if response == "yes"
            :eligible_for_smp?
          elsif response == "no"
            :maternity_benefits_maternity_allowance_outcome
          end
        end
      end

      # Q9 going_abroad and Q8 already_abroad
      multiple_choice :eligible_for_smp? do
        option :yes
        option :no

        next_node do |response|
          if response == "yes"
            :maternity_benefits_eea_entitled_outcome
          elsif response == "no"
            :maternity_benefits_maternity_allowance_outcome
          end
        end
      end

      # Q10, Q11, Q16 going_abroad and Q9, Q10, Q15 already_abroad
      multiple_choice :employer_paying_ni? do
        option :yes
        option :no

        next_node do |response|
          if ['ssp'].include?(benefit)
            if ['going_abroad'].include?(going_or_already_abroad)
              if response == "yes"
                :ssp_going_abroad_entitled_outcome
              else
                :ssp_going_abroad_not_entitled_outcome
              end
            elsif ['already_abroad'].include?(going_or_already_abroad)
              if response == "yes"
                :ssp_already_abroad_entitled_outcome
              else
                :ssp_already_abroad_not_entitled_outcome
              end
            end
          elsif response == "yes"
            :eligible_for_smp?
          elsif (countries_of_former_yugoslavia + %w(barbados guernsey jersey israel turkey)).include?(country)
            if ['already_abroad'].include?(going_or_already_abroad)
              :maternity_benefits_social_security_already_abroad_outcome
            else
              :maternity_benefits_social_security_going_abroad_outcome
            end
          else
            :maternity_benefits_not_entitled_outcome
          end
        end
      end

      # Q13 going_abroad and Q12 already_abroad
      multiple_choice :do_either_of_the_following_apply? do
        option :yes
        option :no

        next_node do |response|
          if response == "yes"
            :child_benefit_entitled_outcome
          elsif response == "no"
            :child_benefit_not_entitled_outcome
          end
        end
      end

      # Q15 going_abroad and Q14 already_abroad
      multiple_choice :working_for_uk_employer_ssp? do
        option :yes
        option :no

        next_node do |response|
          if ['going_abroad'].include?(going_or_already_abroad)
            if response == "yes"
              :ssp_going_abroad_entitled_outcome
            else
              :ssp_going_abroad_not_entitled_outcome
            end
          elsif ['already_abroad'].include?(going_or_already_abroad)
            if response == "yes"
              :ssp_already_abroad_entitled_outcome
            else
              :ssp_already_abroad_not_entitled_outcome
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
          if response == "crown_servant"
            :tax_credits_crown_servant_outcome
          elsif response == "cross_border_worker"
            :tax_credits_cross_border_worker_outcome
          elsif response == "none_of_the_above"
            :tax_credits_how_long_abroad?
          end
        end
      end

      # Q19 going_abroad and Q18 already_abroad
      multiple_choice :tax_credits_children? do
        option :yes
        option :no

        next_node do |response|
          if response == "yes"
            :which_country?
          elsif response == "no"
            :tax_credits_unlikely_outcome
          end
        end
      end

      # Q20 already_abroad
      multiple_choice :tax_credits_currently_claiming? do
        option :yes
        option :no

        next_node do |response|
          if response == "yes"
            :tax_credits_eea_entitled_outcome
          elsif response == "no"
            :tax_credits_unlikely_outcome
          end
        end
      end

      # Q23 going_abroad and Q22 already_abroad
      multiple_choice :tax_credits_why_going_abroad? do
        option :tax_credits_holiday
        option :tax_credits_medical_treatment
        option :tax_credits_death

        next_node do |response|
          if response == "tax_credits_holiday"
            :tax_credits_holiday_outcome
          elsif response == "tax_credits_medical_treatment"
            :tax_credits_medical_death_outcome
          elsif response == "tax_credits_death"
            :tax_credits_medical_death_outcome
          end
        end
      end

      # Q26 going_abroad and Q25 already_abroad
      multiple_choice :iidb_already_claiming? do
        option :yes
        option :no

        next_node do |response|
          if response == "yes"
            :which_country?
          elsif response == "no"
            :iidb_maybe_outcome
          end
        end
      end

      # Q30 going_abroad and Q29 already_abroad
      multiple_choice :db_claiming_benefits? do
        option :yes
        option :no

        next_node do |response|
          if ['going_abroad'].include?(going_or_already_abroad)
            if response == "yes"
              :db_going_abroad_eea_outcome
            else
              :db_going_abroad_other_outcome
            end
          elsif ['already_abroad'].include?(going_or_already_abroad)
            if response == "yes"
              :db_already_abroad_eea_outcome
            else
              :db_already_abroad_other_outcome
            end
          end
        end
      end

      # Q33 going_abroad
      multiple_choice :is_claiming_benefits? do
        option :yes
        option :no

        next_node do |response|
          if response == "yes"
            :is_claiming_benefits_outcome
          elsif response == "no"
            :is_either_of_the_following?
          end
        end
      end

      # Q34 going_abroad
      multiple_choice :is_either_of_the_following? do
        option :yes
        option :no

        next_node do |response|
          if response == "yes"
            :is_abroad_for_treatment?
          elsif response == "no"
            :is_any_of_the_following_apply?
          end
        end
      end

      # Q35 going_abroad
      multiple_choice :is_abroad_for_treatment? do
        option :yes
        option :no

        next_node do |response|
          if response == "yes"
            :is_abroad_for_treatment_outcome
          elsif response == "no"
            :is_work_or_sick_pay?
          end
        end
      end

      # Q36 going_abroad
      multiple_choice :is_work_or_sick_pay? do
        option :yes
        option :no

        next_node do |response|
          if response == "yes"
            :is_abroad_for_treatment_outcome
          elsif response == "no"
            :is_not_eligible_outcome
          end
        end
      end

      # Q37 going_abroad
      multiple_choice :is_any_of_the_following_apply? do
        option :yes
        option :no

        next_node do |response|
          if response == "yes"
            :is_not_eligible_outcome
          elsif response == "no"
            :is_abroad_for_treatment_outcome
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
          if response == "less_than_a_year_medical"
            :jsa_less_than_a_year_medical_outcome
          elsif response == "less_than_a_year_other"
            :jsa_less_than_a_year_other_outcome
          elsif response == "more_than_a_year"
            :which_country?
          end
        end
      end
      # Going abroad Q18 (tax credits) and Q17 already_abroad
      multiple_choice :tax_credits_how_long_abroad? do
        option :tax_credits_up_to_a_year
        option :tax_credits_more_than_a_year

        next_node do |response|
          if response == "tax_credits_up_to_a_year"
            :tax_credits_why_going_abroad?
          elsif response == "tax_credits_more_than_a_year"
            :tax_credits_children?
          end
        end
      end

      # Going abroad Q24 going_abroad (ESA) and Q23 already_abroad
      multiple_choice :esa_how_long_abroad? do
        option :esa_under_a_year_medical
        option :esa_under_a_year_other
        option :esa_more_than_a_year

        next_node do |response|
          if ['going_abroad'].include?(going_or_already_abroad)
            if response == "esa_under_a_year_medical"
              :esa_going_abroad_under_a_year_medical_outcome
            elsif response == "esa_under_a_year_other"
              :esa_going_abroad_under_a_year_other_outcome
            else
              :which_country?
            end
          elsif ['already_abroad'].include?(going_or_already_abroad)
            if response == "esa_under_a_year_medical"
              :esa_already_abroad_under_a_year_medical_outcome
            elsif response == "esa_under_a_year_other"
              :esa_already_abroad_under_a_year_other_outcome
            else
              :which_country?
            end
          end
        end
      end

      # Going abroad Q28 going_abroad (Disability Benefits) and Q27 already_abroad
      multiple_choice :db_how_long_abroad? do
        option :temporary
        option :permanent

        next_node do |response|
          if response == "permanent"
            :which_country?
          elsif ['going_abroad'].include?(going_or_already_abroad)
            :db_going_abroad_temporary_outcome
          else
            :db_already_abroad_temporary_outcome
          end
        end
      end

      # Going abroad Q32 going_abroad (Income Support)
      multiple_choice :is_how_long_abroad? do
        option :is_under_a_year_medical
        option :is_under_a_year_other
        option :is_more_than_a_year

        next_node do |response|
          if response == "is_under_a_year_medical"
            :is_under_a_year_medical_outcome
          elsif response == "is_under_a_year_other"
            :is_claiming_benefits?
          elsif response == "is_more_than_a_year"
            :is_more_than_a_year_outcome
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
      outcome :tax_credits_crown_servant_outcome do # A19 already_abroad
        precalculate :tax_credits_crown_servant do
          PhraseList.new(:"tax_credits_#{going_or_already_abroad}_helpline")
        end
      end
      outcome :tax_credits_cross_border_worker_outcome do # A20 already_abroad and A22 going_abroad
        precalculate :tax_credits_cross_border_worker do
          PhraseList.new(:"tax_credits_cross_border_#{going_or_already_abroad}", :tax_credits_cross_border, :"tax_credits_#{going_or_already_abroad}_helpline")
        end
      end
      outcome :tax_credits_unlikely_outcome #A21 already_abroad and A23 going_abroad
      outcome :tax_credits_eea_entitled_outcome # A22 already_abroad and A24 going_abroad
      outcome :tax_credits_holiday_outcome do # A23 already_abroad and A25 going_abroad and A26 going_abroad
        precalculate :tax_credits_holiday do
          PhraseList.new(:"tax_credits_holiday_#{going_or_already_abroad}", :tax_credits_holiday, :"tax_credits_#{going_or_already_abroad}_helpline")
        end
      end
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

      outcome :tax_credits_medical_death_outcome do # A24 already_abroad
        precalculate :tax_credits_medical_death do
          PhraseList.new(:"tax_credits_medical_death_#{going_or_already_abroad}", :tax_credits_medical_death, :"tax_credits_#{going_or_already_abroad}_helpline")
        end
      end
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
      outcome :bb_already_abroad_ss_outcome # A38 already_abroad
      outcome :bb_already_abroad_other_outcome # A39 already_abroad
      outcome :is_already_abroad_outcome # A40 already_abroad
    end
  end
end
