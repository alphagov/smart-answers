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

        calculate :is_already_abroad do |response|
          response == 'already_abroad'
        end

        calculate :already_abroad_text_two do |response|
          if is_already_abroad
            PhraseList.new(:already_abroad_text_two)
          end
        end

        next_node :which_benefit?
      end

      # Q2 going_abroad and Q3 already_abroad
      multiple_choice :which_benefit? do
        option :jsa
        option :pension
        option winter_fuel_payment: :which_country? # Country Question - Shared
        option maternity_benefits: :which_country? # Country Question - Shared
        option child_benefit: :which_country? # Country Question - Shared
        option iidb: :iidb_already_claiming? # Q26 going_abroad and Q25 already_abroad
        option ssp: :which_country? # Country Question - Shared
        option esa: :esa_how_long_abroad? # Q24 going_abroad and Q23 already_abroad
        option disability_benefits: :db_how_long_abroad? # Q28 going_abroad and Q27 already_abroad
        option bereavement_benefits: :which_country? # Country Question - Shared
        option tax_credits: :eligible_for_tax_credits? # Q17 going_abroad and Q16 already_abroad
        option :income_support

        save_input_as :benefit

        calculate :how_long_question_titles do
          if benefit == "disability_benefits"
            PhraseList.new(:"#{benefit}_how_long_question_title")
          else
            PhraseList.new(:"#{going_or_already_abroad}_how_long_question_title")
          end
        end

        on_condition(going_abroad) do
          next_node_if(:jsa_how_long_abroad?, responded_with('jsa')) # Q3 going_abroad
          next_node_if(:pension_going_abroad_outcome, responded_with('pension')) # A2 going_abroad
          next_node_if(:is_how_long_abroad?, responded_with('income_support')) # Q32 going_abroad
        end
        on_condition(already_abroad) do
          next_node_if(:which_country?, responded_with('jsa'))
          next_node_if(:pension_already_abroad_outcome, responded_with('pension')) # A2 already_abroad
          next_node_if(:is_already_abroad_outcome, responded_with('income_support')) #A40 already_abroad
        end
      end

      ## Country Question - Shared
      country_select :which_country?,additional_countries: additional_countries, exclude_countries: exclude_countries do

        save_input_as :country

        calculate :country_name do
          (WorldLocation.all + additional_countries).find { |c| c.slug == country }.name
        end

      #jsa
        on_condition(variable_matches(:benefit, 'jsa')) do
          on_condition(already_abroad) do
            next_node_if(:jsa_eea_already_abroad_outcome, responded_with_eea_country) # A3 already_abroad
            next_node_if(:jsa_social_security_already_abroad_outcome, social_security_countries_jsa) # A4 already_abroad
          end

          on_condition(going_abroad) do
            next_node_if(:jsa_eea_going_abroad_outcome, responded_with_eea_country) # A5 going_abroad
            next_node_if(:jsa_social_security_going_abroad_outcome, social_security_countries_jsa) # A6 going_abroad
          end
          next_node(:jsa_not_entitled_outcome) # A7 going_abroad and A5 already_abroad
        end
      #maternity
        on_condition(variable_matches(:benefit, 'maternity_benefits')) do
          next_node_if(:working_for_a_uk_employer?, responded_with_eea_country) # Q8 going_abroad and Q7 already_abroad
          next_node(:employer_paying_ni?) # Q10, Q11, Q16 going_abroad and Q9, Q10, Q15 already_abroad
        end
      #wfp
        on_condition(variable_matches(:benefit, 'winter_fuel_payment')) do
          on_condition(responded_with_eea_country) do
            next_node_if(:wfp_going_abroad_outcome, going_abroad) # A9 going_abroad
            next_node(:wfp_eea_eligible_outcome) # A7 already_abroad
          end
          next_node(:wfp_not_eligible_outcome) # A8 going_abroad and A6 already_abroad
        end
      #child benefit
        on_condition(variable_matches(:benefit, 'child_benefit')) do
          next_node_if(:do_either_of_the_following_apply?, responded_with_eea_country) # Q13 going_abroad and Q12 already_abroad
          on_condition(responded_with_former_yugoslavia) do
            next_node_if(:child_benefit_fy_going_abroad_outcome, going_abroad) # A14 going_abroad
            next_node(:child_benefit_fy_already_abroad_outcome) # A12 already_abroad
          end
          next_node_if(:child_benefit_ss_outcome, responded_with(%w(barbados canada guernsey israel jersey mauritius new-zealand))) # A15 going_abroad and A13 already_abroad
          next_node_if(:child_benefit_jtu_outcome, responded_with(%w(jamaica turkey usa))) # A14 already_abroad
          next_node(:child_benefit_not_entitled_outcome) # A18 going_abroad and A16 already_abroad
        end
      #iidb
        on_condition(variable_matches(:benefit, 'iidb')) do
          on_condition(going_abroad) do
            next_node_if(:iidb_going_abroad_eea_outcome, responded_with_eea_country) # A32 going_abroad
            next_node_if(:iidb_going_abroad_ss_outcome, social_security_countries_iidb) # A33 going_abroad
            next_node(:iidb_going_abroad_other_outcome) # A34 going_abroad
          end
          on_condition(already_abroad) do
            next_node_if(:iidb_already_abroad_eea_outcome, responded_with_eea_country) # A31 already_abroad
            next_node_if(:iidb_already_abroad_ss_outcome, social_security_countries_iidb) # A32 already_abroad
            next_node(:iidb_already_abroad_other_outcome) # A33 already_abroad
          end
        end
      #disability benefits
        on_condition(variable_matches(:benefit, 'disability_benefits')) do
          next_node_if(:db_claiming_benefits?, responded_with_eea_country) # Q30 going_abroad and Q29 already_abroad
          next_node_if(:db_going_abroad_other_outcome, going_abroad) # A36 going_abroad
          next_node(:db_already_abroad_other_outcome) # A35 already_abroad
        end
      #ssp
        on_condition(variable_matches(:benefit, 'ssp')) do
          next_node_if(:working_for_uk_employer_ssp?, responded_with_eea_country) # Q15 going_abroad and Q14 already_abroad
          next_node(:employer_paying_ni?) # Q10, Q11, Q16 going_abroad and Q9, Q10, Q15 already_abroad
        end
      #tax credits
        on_condition(variable_matches(:benefit, 'tax_credits')) do
          next_node_if(:tax_credits_currently_claiming?, responded_with_eea_country) # Q20 already_abroad
          next_node(:tax_credits_unlikely_outcome) # A21 already_abroad and A23 going_abroad
        end
      #esa
        on_condition(variable_matches(:benefit, 'esa')) do
          on_condition(going_abroad) do
            next_node_if(:esa_going_abroad_eea_outcome, responded_with_eea_country) # A29 going_abroad
            next_node_if(:esa_going_abroad_eea_outcome, responded_with_former_yugoslavia)
            next_node_if(:esa_going_abroad_eea_outcome, responded_with(%w(barbados guernsey israel jersey jamaica turkey usa)))
            next_node(:esa_going_abroad_other_outcome) # A30 going_abroad
          end
          on_condition(already_abroad) do
            next_node_if(:esa_already_abroad_eea_outcome, responded_with_eea_country) # A27 already_abroad
            next_node_if(:esa_already_abroad_ss_outcome, responded_with_former_yugoslavia) # A28 already_abroad
            next_node_if(:esa_already_abroad_ss_outcome, responded_with(%w(barbados jersey guernsey jamaica turkey usa)))
            next_node(:esa_already_abroad_other_outcome) # A29 already_abroad
          end
        end
      #bereavement_benefits
        on_condition(variable_matches(:benefit, 'bereavement_benefits')) do
          on_condition(going_abroad) do
            next_node_if(:bb_going_abroad_eea_outcome, responded_with_eea_country) # A39 going_abroad
            next_node_if(:bb_going_abroad_ss_outcome, social_security_countries_bereavement_benefits) # A40 going_abroad
            next_node(:bb_going_abroad_other_outcome) # A38 going_abroad
          end
          on_condition(already_abroad) do
            next_node_if(:bb_already_abroad_eea_outcome, responded_with_eea_country) # A37 already_abroad
            next_node_if(:bb_already_abroad_ss_outcome, social_security_countries_bereavement_benefits) # A38 already_abroad
            next_node(:bb_already_abroad_other_outcome) # A39 already_abroad
          end
        end
      end

      # Q8 going_abroad and Q7 already_abroad
      multiple_choice :working_for_a_uk_employer? do
        option yes: :eligible_for_smp? # Q9 going_abroad and Q8 already_abroad
        option no: :maternity_benefits_maternity_allowance_outcome # A10 going_abroad and A8 already_abroad
      end

      # Q9 going_abroad and Q8 already_abroad
      multiple_choice :eligible_for_smp? do
        option yes: :maternity_benefits_eea_entitled_outcome # A11 going_abroad and A9 already_abroad
        option no: :maternity_benefits_maternity_allowance_outcome # A10 going_abroad and A8 already_abroad
      end

      # Q10, Q11, Q16 going_abroad and Q9, Q10, Q15 already_abroad
      multiple_choice :employer_paying_ni? do
        option :yes
        option :no

        #SSP benefits
        on_condition(variable_matches(:benefit, 'ssp')) do
          on_condition(going_abroad) do
            next_node_if(:ssp_going_abroad_entitled_outcome, responded_with('yes')) # A19 going_abroad
            next_node(:ssp_going_abroad_not_entitled_outcome) # A20 going_abroad
          end
          on_condition(already_abroad) do
            next_node_if(:ssp_already_abroad_entitled_outcome, responded_with('yes')) # A17 already_abroad
            next_node(:ssp_already_abroad_not_entitled_outcome) # A18 already_abroad
          end
        end
        #not SSP benefits
        next_node_if(:eligible_for_smp?, responded_with('yes')) # Q9 going_abroad and Q8 already_abroad
        on_condition(variable_matches(:country, countries_of_former_yugoslavia + %w(barbados guernsey jersey israel turkey))) do
          on_condition(already_abroad) do
            next_node(:maternity_benefits_social_security_already_abroad_outcome) # A10 already_abroad
          end
          next_node_if(:maternity_benefits_social_security_going_abroad_outcome) # A12 going_abroad
        end
        next_node(:maternity_benefits_not_entitled_outcome) # A13 going_abroad and A11 already_abroad
      end

      # Q13 going_abroad and Q12 already_abroad
      multiple_choice :do_either_of_the_following_apply? do
        option yes: :child_benefit_entitled_outcome # A17 going_abroad and A15 already_abroad
        option no: :child_benefit_not_entitled_outcome # A18 going_abroad and A16 already_abroad
      end

      # Q15 going_abroad and Q14 already_abroad
      multiple_choice :working_for_uk_employer_ssp? do
        option :yes
        option :no

        on_condition(going_abroad) do
          next_node_if(:ssp_going_abroad_entitled_outcome, responded_with('yes')) # A19 going_abroad
          next_node(:ssp_going_abroad_not_entitled_outcome) # A20 going_abroad
        end
        on_condition(already_abroad) do
          next_node_if(:ssp_already_abroad_entitled_outcome, responded_with('yes')) # A17 already_abroad
          next_node(:ssp_already_abroad_not_entitled_outcome) # A18 already_abroad
        end
      end

      # Q17 going_abroad and Q16 already_abroad
      multiple_choice :eligible_for_tax_credits? do
        option crown_servant: :tax_credits_crown_servant_outcome # A19 already_abroad
        option cross_border_worker: :tax_credits_cross_border_worker_outcome # A20 already_abroad
        option none_of_the_above: :tax_credits_how_long_abroad? # Q18 going_abroad and Q17 already_abroad
      end

      # Q19 going_abroad and Q18 already_abroad
      multiple_choice :tax_credits_children? do
        option yes: :which_country? # Q17
        option no: :tax_credits_unlikely_outcome # A21 already_abroad and A23 going_abroad
      end

      # Q20 already_abroad
      multiple_choice :tax_credits_currently_claiming? do
        option yes: :tax_credits_eea_entitled_outcome # A22 already_abroad and A24 going_abroad
        option no: :tax_credits_unlikely_outcome # A21 already_abroad and A23 going_abroad
      end

      # Q23 going_abroad and Q22 already_abroad
      multiple_choice :tax_credits_why_going_abroad? do
        option tax_credits_holiday: :tax_credits_holiday_outcome # A23 already_abroad and A25 going_abroad and A26 going_abroad
        option tax_credits_medical_treatment: :tax_credits_medical_death_outcome #A24 already_abroad
        option tax_credits_death: :tax_credits_medical_death_outcome #A24 already_abroad
      end

      # Q26 going_abroad and Q25 already_abroad
      multiple_choice :iidb_already_claiming? do
        option yes: :which_country? # Shared question
        option no: :iidb_maybe_outcome # A30 already_abroad and A31 going_abroad
      end

      # Q30 going_abroad and Q29 already_abroad
      multiple_choice :db_claiming_benefits? do
        option :yes
        option :no

        on_condition(going_abroad) do
          next_node_if(:db_going_abroad_eea_outcome, responded_with('yes')) # A37 going_abroad
          next_node(:db_going_abroad_other_outcome) # A36 going_abroad
        end
        on_condition(already_abroad) do
          next_node_if(:db_already_abroad_eea_outcome, responded_with('yes')) # A36 already_abroad
          next_node(:db_already_abroad_other_outcome) # A35 already_abroad
        end
      end

      # Q33 going_abroad
      multiple_choice :is_claiming_benefits? do
        option yes: :is_claiming_benefits_outcome # A43 going_abroad
        option no: :is_either_of_the_following? # Q34 going_abroad
      end

      # Q34 going_abroad
      multiple_choice :is_either_of_the_following? do
        option yes: :is_abroad_for_treatment? # Q35 going_abroad
        option no: :is_any_of_the_following_apply? # Q37 going_abroad
      end

      # Q35 going_abroad
      multiple_choice :is_abroad_for_treatment? do
        option yes: :is_abroad_for_treatment_outcome # A44 going_abroad
        option no: :is_work_or_sick_pay? # Q36 going_abroad
      end

      # Q36 going_abroad
      multiple_choice :is_work_or_sick_pay? do
        option yes: :is_abroad_for_treatment_outcome # A44 going_abroad
        option no: :is_not_eligible_outcome # A45 going_abroad
      end

      # Q37 going_abroad
      multiple_choice :is_any_of_the_following_apply? do
        option yes: :is_not_eligible_outcome # A45 going_abroad
        option no: :is_abroad_for_treatment_outcome # A44 going_abroad
      end

      # Going abroad questions
      # Going abroad Q3 going_abroad
      multiple_choice :jsa_how_long_abroad? do
        option :less_than_a_year_medical
        option :less_than_a_year_other
        option :more_than_a_year

        save_input_as :how_long_abroad_jsa

        next_node_if(:jsa_less_than_a_year_medical_outcome, responded_with("less_than_a_year_medical")) # A3 going_abroad
        next_node_if(:jsa_less_than_a_year_other_outcome, responded_with("less_than_a_year_other")) # A4 going_abroad
        next_node_if(:which_country?, responded_with("more_than_a_year"))
      end
      # Going abroad Q18 (tax credits) and Q17 already_abroad
      multiple_choice :tax_credits_how_long_abroad? do
        option tax_credits_up_to_a_year: :tax_credits_why_going_abroad? #Q23 going_abroad and Q22 already_abroad
        option tax_credits_more_than_a_year: :tax_credits_children? # Q19 going_abroad and Q18 already_abroad
      end

      # Going abroad Q24 going_abroad (ESA) and Q23 already_abroad
      multiple_choice :esa_how_long_abroad? do
        option :esa_under_a_year_medical
        option :esa_under_a_year_other
        option :esa_more_than_a_year

        on_condition(going_abroad) do
          next_node_if(:esa_going_abroad_under_a_year_medical_outcome, responded_with('esa_under_a_year_medical')) # A27 going_abroad
          next_node_if(:esa_going_abroad_under_a_year_other_outcome, responded_with('esa_under_a_year_other')) # A28 going_abroad
        end
        on_condition(already_abroad) do
          next_node_if(:esa_already_abroad_under_a_year_medical_outcome, responded_with('esa_under_a_year_medical')) # A25 already_abroad
          next_node_if(:esa_already_abroad_under_a_year_other_outcome, responded_with('esa_under_a_year_other')) # A26 already_abroad
        end
        next_node(:which_country?)
      end

      # Going abroad Q28 going_abroad (Disability Benefits) and Q27 already_abroad
      multiple_choice :db_how_long_abroad? do
        option :temporary
        option permanent: :which_country? # Q25

        next_node_if(:db_going_abroad_temporary_outcome, going_abroad) # A35 going_abroad
        next_node(:db_already_abroad_temporary_outcome) # A34 already_abroad
      end

      # Going abroad Q32 going_abroad (Income Support)
      multiple_choice :is_how_long_abroad? do
        option is_under_a_year_medical: :is_under_a_year_medical_outcome # A42 going_abroad
        option is_under_a_year_other: :is_claiming_benefits? # Q33 going_abroad
        option is_more_than_a_year: :is_more_than_a_year_outcome # A41 going_abroad
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
