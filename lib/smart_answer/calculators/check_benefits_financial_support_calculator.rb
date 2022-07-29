module SmartAnswer::Calculators
  class CheckBenefitsFinancialSupportCalculator
    attr_accessor :where_do_you_live,
                  :over_state_pension_age,
                  :are_you_working,
                  :disability_or_health_condition,
                  :disability_affecting_work,
                  :carer_disability_or_health_condition,
                  :children_living_with_you,
                  :age_of_children,
                  :children_with_disability,
                  :assets_and_savings

    def benefit_data
      @benefit_data ||= YAML.load_file(Rails.root.join("config/smart_answers/check_benefits_financial_support_data.yml")).freeze
    end

    def benefits_for_outcome
      @benefits_for_outcome ||= benefit_data["benefits"].select { |benefit|
        next unless benefit["countries"].include?(@where_do_you_live)

        benefit["condition"].nil? || send(benefit["condition"])
      }.compact
    end

    def number_of_benefits
      benefits_for_outcome.size
    end

    def eligible_for_employment_and_support_allowance?
      @over_state_pension_age == "no" &&
        @are_you_working != "yes_over_16_hours_per_week" &&
        @disability_or_health_condition == "yes" &&
        @disability_affecting_work != "no"
    end

    def eligible_for_jobseekers_allowance?
      @over_state_pension_age == "no" &&
        @are_you_working != "yes_over_16_hours_per_week" &&
        @disability_affecting_work != "yes_unable_to_work"
    end

    def eligible_for_pension_credit?
      @over_state_pension_age == "yes"
    end

    def eligible_for_access_to_work?
      @disability_or_health_condition == "yes" &&
        @disability_affecting_work != "yes_unable_to_work"
    end

    def eligible_for_universal_credit?
      @over_state_pension_age == "no" &&
        @assets_and_savings == "under_16000"
    end

    def eligible_for_housing_benefit?
      @over_state_pension_age == "yes"
    end

    def eligible_for_tax_free_childcare?
      return unless @are_you_working != "no" && @children_living_with_you == "yes"

      eligible_child_ages = if @children_with_disability == "yes"
                              %w[1_or_under 2 3_to_4 5_to_11 12_to_15 16_to_17]
                            else
                              %w[1_or_under 2 3_to_4 5_to_11]
                            end

      @age_of_children.split(",").any? { |age| eligible_child_ages.include?(age) }
    end

    def eligible_for_free_childcare_2yr_olds?
      @children_living_with_you == "yes" &&
        @age_of_children.split(",").any?("2")
    end

    def eligible_for_childcare_3_4yr_olds?
      @are_you_working == "yes_over_16_hours_per_week" &&
        @children_living_with_you == "yes" &&
        @age_of_children.split(",").any?("3_to_4")
    end

    def eligible_for_15hrs_free_childcare_3_4yr_olds?
      @children_living_with_you == "yes" &&
        @age_of_children.split(",").any?("3_to_4")
    end

    def eligible_for_30hrs_free_childcare_3_4yrs?
      @are_you_working != "no" &&
        @children_living_with_you == "yes" &&
        @age_of_children.split(",").any?("3_to_4")
    end

    def eligible_for_funded_early_learning_and_childcare?
      eligible_child_ages = %w[2 3_to_4]
      @children_living_with_you == "yes" &&
        @age_of_children.split(",").any? { |age| eligible_child_ages.include?(age) }
    end

    def eligible_for_child_benefit?
      @children_living_with_you == "yes"
    end

    def eligible_for_disability_living_allowance_for_children?
      eligible_child_ages = %w[1_or_under 2 3_to_4 5_to_11 12_to_15]

      @where_do_you_live != "scotland" &&
        @children_living_with_you == "yes" &&
        @age_of_children.split(",").any? { |age| eligible_child_ages.include?(age) } &&
        @children_with_disability == "yes"
    end

    def eligible_for_child_disability_payment_scotland?
      eligible_child_ages = %w[1_or_under 2 3_to_4 5_to_11 12_to_15]

      @where_do_you_live == "scotland" &&
        @children_living_with_you == "yes" &&
        @age_of_children.split(",").any? { |age| eligible_child_ages.include?(age) } &&
        @children_with_disability == "yes"
    end

    def eligible_for_carers_allowance?
      @carer_disability_or_health_condition == "yes"
    end

    def eligible_for_personal_independence_payment?
      return unless @over_state_pension_age == "no"

      return true if @disability_or_health_condition == "yes"

      eligible_child_ages = %w[16_to_17 18_to_19]
      @children_living_with_you == "yes" &&
        @age_of_children.split(",").any? { |age| eligible_child_ages.include?(age) } &&
        @children_with_disability == "yes"
    end

    def eligible_for_attendance_allowance?
      @over_state_pension_age == "yes" && @disability_or_health_condition == "yes"
    end

    def eligible_for_nhs_low_income_scheme?
      @assets_and_savings == "under_16000"
    end
  end
end
