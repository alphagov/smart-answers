class UkBenefitsAbroadFlow < SmartAnswer::Flow
  def define
    content_id "e1eaf183-1211-4fd7-b439-5c94498814ef"
    name "uk-benefits-abroad"
    status :published

    exclude_countries = %w[british-antarctic-territory french-guiana guadeloupe holy-see martinique mayotte reunion st-maarten]
    additional_countries = [
      OpenStruct.new(slug: "jersey", name: "Jersey"),
      OpenStruct.new(slug: "guernsey", name: "Guernsey"),
    ]

    # Q1
    radio :going_or_already_abroad? do
      option :going_abroad
      option :already_abroad

      on_response do |response|
        self.calculator = SmartAnswer::Calculators::UkBenefitsAbroadCalculator.new
        calculator.going_abroad = (response == "going_abroad")
      end

      next_node do
        question :which_benefit?
      end
    end

    # Q2 going_abroad and Q3 already_abroad
    radio :which_benefit? do
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

      on_response do |response|
        calculator.benefit = response
      end

      next_node do |response|
        if %w[maternity_benefits child_benefit ssp bereavement_benefits jsa].include?(response)
          question :which_country?
        elsif response == "winter_fuel_payment"
          outcome :wfp_not_eligible_outcome
        elsif response == "iidb"
          question :iidb_already_claiming?
        elsif response == "esa"
          question :esa_how_long_abroad?
        elsif response == "disability_benefits"
          question :db_how_long_abroad?
        elsif response == "tax_credits"
          question :eligible_for_tax_credits?
        elsif calculator.going_abroad
          case response
          when "pension"
            outcome :pension_going_abroad_outcome # A2 going_abroad
          when "income_support"
            question :is_how_long_abroad? # Q32 going_abroad
          end
        elsif calculator.already_abroad
          case response
          when "pension"
            outcome :pension_already_abroad_outcome # A2 already_abroad
          when "income_support"
            outcome :is_already_abroad_outcome # A40 already_abroad
          end
        end
      end
    end

    ## Country Question - Shared
    country_select(:which_country?, additional_countries:, exclude_countries:) do
      on_response do |response|
        calculator.country = response
        calculator.country_name = (WorldLocation.all + additional_countries).find { |c| c.slug == calculator.country }.name
      end

      next_node do |response|
        case calculator.benefit
        when "jsa"
          if calculator.already_abroad && calculator.eea_country?
            outcome :jsa_eea_already_abroad_outcome # A3 already_abroad
          elsif calculator.already_abroad && calculator.social_security_countries_jsa?
            outcome :jsa_social_security_already_abroad_outcome
          elsif calculator.going_abroad && calculator.country == "ireland"
            question :is_british_or_irish?
          elsif calculator.going_abroad && calculator.country == "gibraltar"
            outcome :jsa_eea_going_abroad_maybe_outcome
          elsif calculator.going_abroad && calculator.eea_country?
            question :worked_in_eea_or_switzerland? # A5 going_abroad
          elsif calculator.going_abroad && calculator.social_security_countries_jsa?
            outcome :jsa_social_security_going_abroad_outcome
          else
            outcome :jsa_not_entitled_outcome # A7 calculator.going_abroad and A5 already_abroad
          end
        when "maternity_benefits"
          if calculator.eea_country?
            question :working_for_a_uk_employer? # Q8 going_abroad and Q7 already_abroad
          else
            question :employer_paying_ni? # Q10, Q11, Q16 going_abroad and Q9, Q10, Q15 already_abroad
          end

        when "child_benefit"
          if calculator.eea_country?
            question :do_either_of_the_following_apply? # Q13 going_abroad and Q12 already_abroad
          elsif calculator.former_yugoslavia?
            if calculator.going_abroad
              outcome :child_benefit_fy_going_abroad_outcome # A14 going_abroad
            else
              outcome :child_benefit_fy_already_abroad_outcome # A12 already_abroad
            end
          elsif %w[barbados canada guernsey israel jersey mauritius new-zealand].include?(response)
            outcome :child_benefit_ss_outcome # A15 going_abroad and A13 already_abroad
          elsif %w[jamaica turkey usa].include?(response)
            outcome :child_benefit_jtu_outcome # A14 already_abroad
          else
            outcome :child_benefit_not_entitled_outcome # A18 going_abroad and A16 already_abroad
          end
        when "iidb"
          if calculator.going_abroad
            if calculator.eea_country? || !calculator.social_security_countries_iidb?
              outcome :iidb_going_abroad_eea_outcome # A32 going_abroad
            else
              outcome :iidb_going_abroad_ss_outcome # A34 going_abroad
            end
          elsif calculator.already_abroad
            if calculator.eea_country? || !calculator.social_security_countries_iidb?
              outcome :iidb_already_abroad_eea_outcome # A31 already_abroad
            else
              outcome :iidb_already_abroad_ss_outcome # A33 already_abroad
            end
          end
        when "disability_benefits"
          if calculator.eea_country?
            question :worked_in_eea_or_switzerland?
          elsif calculator.going_abroad
            outcome :db_going_abroad_other_outcome # A36 going_abroad
          else
            outcome :db_already_abroad_other_outcome # A35 already_abroad
          end
        when "ssp"
          if calculator.eea_country?
            question :working_for_uk_employer_ssp? # Q15 going_abroad and Q14 already_abroad
          else
            question :employer_paying_ni? # Q10, Q11, Q16 going_abroad and Q9, Q10, Q15 already_abroad
          end
        when "tax_credits"
          if calculator.eea_country?
            question :tax_credits_currently_claiming? # Q20 already_abroad
          else
            outcome :tax_credits_unlikely_outcome # A21 already_abroad and A23 going_abroad
          end
        when "esa"
          if calculator.going_abroad
            if calculator.country == "ireland"
              question :is_british_or_irish?
            elsif calculator.former_yugoslavia?
              outcome :esa_going_abroad_eea_outcome
            elsif %w[barbados guernsey gibraltar israel jersey jamaica turkey usa].include?(response)
              outcome :esa_going_abroad_eea_outcome
            elsif calculator.eea_country?
              question :worked_in_eea_or_switzerland?
            else
              outcome :esa_going_abroad_other_outcome # A30 going_abroad
            end
          elsif calculator.already_abroad
            if calculator.country == "ireland"
              question :is_british_or_irish?
            elsif calculator.country == "gibraltar"
              outcome :esa_already_abroad_eea_outcome
            elsif calculator.eea_country?
              question :worked_in_eea_or_switzerland?
            elsif calculator.former_yugoslavia?
              outcome :esa_already_abroad_ss_outcome # A28 already_abroad
            elsif %w[barbados jersey guernsey jamaica turkey usa].include?(response)
              outcome :esa_already_abroad_ss_outcome
            else
              outcome :esa_already_abroad_other_outcome # A29 already_abroad
            end
          end
        when "bereavement_benefits"
          if calculator.going_abroad
            if calculator.eea_country?
              outcome :bb_going_abroad_eea_outcome # A39 going_abroad
            elsif calculator.social_security_countries_bereavement_benefits?
              outcome :bb_going_abroad_ss_outcome # A40 going_abroad
            else
              outcome :bb_going_abroad_other_outcome # A38 going_abroad
            end
          elsif calculator.already_abroad
            if calculator.eea_country?
              outcome :bb_already_abroad_eea_outcome # A37 already_abroad
            elsif calculator.social_security_countries_bereavement_benefits?
              outcome :bb_already_abroad_ss_outcome # A38 already_abroad
            else
              outcome :bb_already_abroad_other_outcome # A39 already_abroad
            end
          end
        end
      end
    end

    # Q8 going_abroad and Q7 already_abroad
    radio :working_for_a_uk_employer? do
      option :yes
      option :no

      next_node do |response|
        case response
        when "yes"
          question :eligible_for_smp? # Q9 going_abroad and Q8 already_abroad
        when "no"
          outcome :maternity_benefits_maternity_allowance_outcome # A10 going_abroad and A8 already_abroad
        end
      end
    end

    # Q9 going_abroad and Q8 already_abroad
    radio :eligible_for_smp? do
      option :yes
      option :no

      next_node do |response|
        case response
        when "yes"
          outcome :maternity_benefits_eea_entitled_outcome # A11 going_abroad and A9 already_abroad
        when "no"
          outcome :maternity_benefits_maternity_allowance_outcome # A10 going_abroad and A8 already_abroad
        end
      end
    end

    # Q10, Q11, Q16 going_abroad and Q9, Q10, Q15 already_abroad
    radio :employer_paying_ni? do
      option :yes
      option :no

      next_node do |response|
        # SSP benefits
        if calculator.benefit == "ssp"
          if calculator.going_abroad
            if response == "yes"
              outcome :ssp_going_abroad_entitled_outcome # A19 going_abroad
            else
              outcome :ssp_going_abroad_not_entitled_outcome # A20 going_abroad
            end
          elsif calculator.already_abroad
            if response == "yes"
              outcome :ssp_already_abroad_entitled_outcome # A17 already_abroad
            else
              outcome :ssp_already_abroad_not_entitled_outcome # A18 already_abroad
            end
          end
        # not SSP benefits
        elsif response == "yes"
          question :eligible_for_smp? # Q9 going_abroad and Q8 already_abroad
        elsif calculator.employer_paying_ni_not_ssp_country_entitled?
          if calculator.already_abroad
            outcome :maternity_benefits_social_security_already_abroad_outcome # A10 already_abroad
          else
            outcome :maternity_benefits_social_security_going_abroad_outcome # A12 going_abroad
          end
        else
          outcome :maternity_benefits_not_entitled_outcome # A13 going_abroad and A11 already_abroad
        end
      end
    end

    # Q13 going_abroad and Q12 already_abroad
    checkbox_question :do_either_of_the_following_apply? do
      SmartAnswer::Calculators::UkBenefitsAbroadCalculator::STATE_BENEFITS.each_key do |benefit|
        option benefit
      end

      on_response do |response|
        calculator.benefits = response.split(",")
      end

      next_node do |_response|
        if calculator.benefits?
          outcome :child_benefit_entitled_outcome # A17 going_abroad and A15 already_abroad
        else
          outcome :child_benefit_not_entitled_outcome # A18 going_abroad and A16 already_abroad
        end
      end
    end

    # Q15 going_abroad and Q14 already_abroad
    radio :working_for_uk_employer_ssp? do
      option :yes
      option :no

      next_node do |response|
        if calculator.going_abroad
          if response == "yes"
            outcome :ssp_going_abroad_entitled_outcome # A19 going_abroad
          else
            outcome :ssp_going_abroad_not_entitled_outcome # A20 going_abroad
          end
        elsif calculator.already_abroad
          if response == "yes"
            outcome :ssp_already_abroad_entitled_outcome # A17 already_abroad
          else
            outcome :ssp_already_abroad_not_entitled_outcome # A18 already_abroad
          end
        end
      end
    end

    # Q17 going_abroad and Q16 already_abroad
    radio :eligible_for_tax_credits? do
      option :crown_servant
      option :cross_border_worker
      option :none_of_the_above

      next_node do |response|
        case response
        when "crown_servant"
          outcome :tax_credits_crown_servant_outcome # A19 already_abroad
        when "cross_border_worker"
          outcome :tax_credits_cross_border_worker_outcome # A20 already_abroad
        when "none_of_the_above"
          question :tax_credits_how_long_abroad? # Q18 going_abroad and Q17 already_abroad
        end
      end
    end

    # Q19 going_abroad and Q18 already_abroad
    radio :tax_credits_children? do
      option :yes
      option :no

      next_node do |response|
        case response
        when "yes"
          question :which_country? # Q17
        when "no"
          outcome :tax_credits_unlikely_outcome # A21 already_abroad and A23 going_abroad
        end
      end
    end

    # Q20 already_abroad
    checkbox_question :tax_credits_currently_claiming? do
      SmartAnswer::Calculators::UkBenefitsAbroadCalculator::TAX_CREDITS_BENEFITS.each_key do |credit|
        option credit
      end

      on_response do |response|
        calculator.tax_credits = response.split(",")
      end

      next_node do |_response|
        if calculator.tax_credits?
          outcome :tax_credits_eea_entitled_outcome # A22 already_abroad and A24 going_abroad
        else
          outcome :tax_credits_unlikely_outcome # A21 already_abroad and A23 going_abroad
        end
      end
    end

    # Q23 going_abroad and Q22 already_abroad
    radio :tax_credits_why_going_abroad? do
      option :tax_credits_holiday
      option :tax_credits_medical_treatment
      option :tax_credits_death

      next_node do |response|
        case response
        when "tax_credits_holiday"
          outcome :tax_credits_holiday_outcome # A23 already_abroad and A25 going_abroad and A26 going_abroad
        when "tax_credits_medical_treatment", "tax_credits_death"
          outcome :tax_credits_medical_death_outcome # A24 already_abroad
        end
      end
    end

    # Q26 going_abroad and Q25 already_abroad
    radio :iidb_already_claiming? do
      option :yes
      option :no

      next_node do |response|
        case response
        when "yes"
          question :which_country? # Shared question
        when "no"
          outcome :iidb_maybe_outcome # A30 already_abroad and A31 going_abroad
        end
      end
    end

    # Q33 going_abroad
    checkbox_question :is_claiming_benefits? do
      SmartAnswer::Calculators::UkBenefitsAbroadCalculator::PREMIUMS.each_key do |premium|
        option premium
      end

      on_response do |response|
        calculator.partner_premiums = response.split(",")
      end

      next_node do |_response|
        if calculator.partner_premiums?
          outcome :is_claiming_benefits_outcome # A43 going_abroad
        else
          question :is_either_of_the_following? # Q34 going_abroad
        end
      end
    end

    # Q34 going_abroad
    checkbox_question :is_either_of_the_following? do
      SmartAnswer::Calculators::UkBenefitsAbroadCalculator::IMPAIRMENTS.each_key do |impairment|
        option impairment
      end

      on_response do |response|
        calculator.possible_impairments = response.split(",")
      end

      next_node do |_response|
        if calculator.getting_income_support?
          question :is_abroad_for_treatment? # Q35 going_abroad
        else
          question :is_any_of_the_following_apply? # Q37 going_abroad
        end
      end
    end

    # Q35 going_abroad
    radio :is_abroad_for_treatment? do
      option :yes
      option :no

      next_node do |response|
        case response
        when "yes"
          outcome :is_abroad_for_treatment_outcome # A44 going_abroad
        when "no"
          question :is_work_or_sick_pay? # Q36 going_abroad
        end
      end
    end

    # Q36 going_abroad
    checkbox_question :is_work_or_sick_pay? do
      SmartAnswer::Calculators::UkBenefitsAbroadCalculator::PERIODS_OF_IMPAIRMENT.each_key do |period|
        option period
      end

      on_response do |response|
        calculator.impairment_periods = response.split(",")
      end

      next_node do |_response|
        if calculator.not_getting_sick_pay?
          outcome :is_abroad_for_treatment_outcome # A44 going_abroad
        else
          outcome :is_not_eligible_outcome # A45 going_abroad
        end
      end
    end

    # Q37 going_abroad
    checkbox_question :is_any_of_the_following_apply? do
      SmartAnswer::Calculators::UkBenefitsAbroadCalculator::DISPUTE_CRITERIA.each_key do |criterion|
        option criterion
      end

      on_response do |response|
        calculator.dispute_criteria = response.split(",")
      end

      next_node do |_response|
        if calculator.dispute_criteria?
          outcome :is_not_eligible_outcome # A45 going_abroad
        else
          outcome :is_abroad_for_treatment_outcome # A44 going_abroad
        end
      end
    end

    # Going abroad questions
    # Going abroad Q18 (tax credits) and Q17 already_abroad
    radio :tax_credits_how_long_abroad? do
      option :tax_credits_up_to_a_year
      option :tax_credits_more_than_a_year

      next_node do |response|
        case response
        when "tax_credits_up_to_a_year"
          question :tax_credits_why_going_abroad? # Q23 going_abroad and Q22 already_abroad
        when "tax_credits_more_than_a_year"
          question :tax_credits_children? # Q19 going_abroad and Q18 already_abroad
        end
      end
    end

    # Going abroad Q24 going_abroad (ESA) and Q23 already_abroad
    radio :esa_how_long_abroad? do
      option :esa_under_a_year_medical
      option :esa_under_a_year_other
      option :esa_more_than_a_year

      next_node do |response|
        if calculator.going_abroad && response == "esa_under_a_year_medical"
          outcome :esa_going_abroad_under_a_year_medical_outcome # A27 going_abroad
        elsif calculator.going_abroad && response == "esa_under_a_year_other"
          outcome :esa_going_abroad_under_a_year_other_outcome # A28 going_abroad
        elsif calculator.already_abroad && response == "esa_under_a_year_medical"
          outcome :esa_already_abroad_under_a_year_medical_outcome # A25 already_abroad
        elsif calculator.already_abroad && response == "esa_under_a_year_other"
          outcome :esa_already_abroad_under_a_year_other_outcome # A26 already_abroad
        else
          question :which_country?
        end
      end
    end

    # Going abroad Q28 going_abroad (Disability Benefits) and Q27 already_abroad
    radio :db_how_long_abroad? do
      option :temporary
      option :permanent

      next_node do |response|
        if response == "permanent"
          question :which_country? # Q25
        elsif calculator.going_abroad
          outcome :db_going_abroad_temporary_outcome # A35 going_abroad
        else
          outcome :db_already_abroad_temporary_outcome # A34 already_abroad
        end
      end
    end

    # Going abroad Q32 going_abroad (Income Support)
    radio :is_how_long_abroad? do
      option :is_under_a_year_medical
      option :is_under_a_year_other
      option :is_more_than_a_year

      next_node do |response|
        case response
        when "is_under_a_year_medical"
          outcome :is_under_a_year_medical_outcome # A42 going_abroad
        when "is_under_a_year_other"
          question :is_claiming_benefits? # Q33 going_abroad
        when "is_more_than_a_year"
          outcome :is_more_than_a_year_outcome # A41 going_abroad
        end
      end
    end

    # Going abroad
    radio :worked_in_eea_or_switzerland? do
      option :before_jan_2021
      option :after_jan_2021
      option :no

      next_node do |response|
        case response
        when "before_jan_2021"
          case calculator.benefit
          when "jsa"
            outcome :jsa_eea_going_abroad_maybe_outcome
          when "esa"
            outcome(calculator.going_abroad ? :esa_going_abroad_eea_outcome : :esa_already_abroad_eea_outcome)
          when "disability_benefits"
            outcome(calculator.going_abroad ? :db_going_abroad_eea_outcome : :db_already_abroad_eea_outcome)
          end
        when "after_jan_2021", "no"
          question :parents_lived_in_eea_or_switzerland?
        end
      end
    end

    radio :parents_lived_in_eea_or_switzerland? do
      option :before_jan_2021
      option :after_jan_2021
      option :no

      next_node do |response|
        case response
        when "before_jan_2021"
          case calculator.benefit
          when "jsa"
            outcome :jsa_eea_going_abroad_maybe_outcome
          when "esa"
            outcome(calculator.going_abroad ? :esa_going_abroad_eea_outcome : :esa_already_abroad_eea_outcome)
          when "disability_benefits"
            outcome(calculator.going_abroad ? :db_going_abroad_eea_outcome : :db_already_abroad_eea_outcome)
          end
        when "after_jan_2021", "no"
          case calculator.benefit
          when "jsa"
            outcome :jsa_not_entitled_outcome
          when "esa"
            outcome(calculator.going_abroad ? :esa_going_abroad_other_outcome : :esa_already_abroad_other_outcome)
          when "disability_benefits"
            outcome(calculator.going_abroad ? :db_going_abroad_other_outcome : :db_already_abroad_other_outcome)
          end
        end
      end
    end

    radio :born_before_23_September_1958? do
      option :yes
      option :no

      next_node do |response|
        case response
        when "yes"
          question :you_or_partner_get_a_benefit_in_the_country?
        when "no"
          outcome :wfp_not_eligible_outcome
        end
      end
    end

    radio :you_or_partner_get_a_benefit_in_the_country? do
      option :yes
      option :no

      next_node do |response|
        case response
        when "yes"
          outcome :wfp_not_eligible_outcome
        when "no"
          question :you_or_partner_get_a_means_tested_benefit_in_the_country?
        end
      end
    end

    radio :you_or_partner_get_a_means_tested_benefit_in_the_country? do
      option :yes
      option :no

      next_node do |response|
        case response
        when "yes"
          outcome :wfp_maybe_outcome
        when "no"
          outcome :wfp_not_eligible_outcome
        end
      end
    end

    radio :is_british_or_irish? do
      option :yes
      option :no

      next_node do |response|
        case response
        when "yes"
          case calculator.benefit
          when "jsa"
            outcome :jsa_ireland_outcome
          when "esa"
            outcome(calculator.going_abroad ? :esa_going_abroad_eea_outcome : :esa_already_abroad_eea_outcome)
          when "disability_benefits"
            outcome :db_going_abroad_ireland_outcome
          end
        when "no"
          question :worked_in_eea_or_switzerland?
        end
      end
    end

    outcome :pension_going_abroad_outcome # A2 going_abroad
    outcome :jsa_social_security_going_abroad_outcome # A6 going_abroad
    outcome :jsa_not_entitled_outcome # A7 going_abroad and A5 already_abroad
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
    outcome :maternity_benefits_eea_entitled_outcome # A11 going_abroad and A9 already_abroad
    outcome :maternity_benefits_social_security_already_abroad_outcome # A10 already_abroad
    outcome :child_benefit_fy_already_abroad_outcome # A12 already_abroad
    outcome :child_benefit_jtu_outcome # A14 already_abroad
    outcome :ssp_already_abroad_entitled_outcome # A17 already_abroad
    outcome :ssp_already_abroad_not_entitled_outcome # A18 already_abroad
    outcome :tax_credits_crown_servant_outcome # A19 already_abroad
    outcome :tax_credits_cross_border_worker_outcome # A20 already_abroad and A22 going_abroad
    outcome :tax_credits_unlikely_outcome # A21 already_abroad and A23 going_abroad
    outcome :tax_credits_eea_entitled_outcome # A22 already_abroad and A24 going_abroad
    outcome :tax_credits_holiday_outcome # A23 already_abroad and A25 going_abroad and A26 going_abroad
    outcome :esa_going_abroad_under_a_year_medical_outcome # A27 going_abroad
    outcome :esa_going_abroad_under_a_year_other_outcome # A28 going_abroad
    outcome :esa_going_abroad_eea_outcome # A29 going_abroad
    outcome :esa_going_abroad_other_outcome # A30 going_abroad
    outcome :iidb_going_abroad_eea_outcome # A32 going_abroad
    outcome :iidb_going_abroad_ss_outcome # A33 going_abroad
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

    outcome :jsa_eea_going_abroad_maybe_outcome
    outcome :jsa_ireland_outcome

    outcome :wfp_ireland_outcome
    outcome :wfp_maybe_outcome
    outcome :wfp_not_eligible_outcome

    outcome :db_going_abroad_ireland_outcome
  end
end
