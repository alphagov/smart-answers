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
                  :on_benefits,
                  :current_benefits,
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

    def benefits_selected?
      @current_benefits != "none"
    end

    def eligible_for_maternity_allowance?
      return unless @children_living_with_you == "yes"

      age_groups = %w[pregnant 1_or_under]

      @over_state_pension_age == "no" && eligible_child_ages?(age_groups)
    end

    def eligible_for_sure_start_maternity_grant?
      skip_benefit_list = %w[housing_benefit]
      age_groups = %w[pregnant 1_or_under]

      general_child_benefit_eligibility?(skip_benefit_list, age_groups)
    end

    def eligible_for_pregnancy_and_baby_payment_scotland?
      skip_benefit_list = []
      age_groups = %w[pregnant 1_or_under]

      general_child_benefit_eligibility?(skip_benefit_list, age_groups)
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
        %w[under_16000 none_16000].include?(@assets_and_savings)
    end

    def eligible_for_housing_benefit?
      @over_state_pension_age == "yes"
    end

    def eligible_for_tax_free_childcare?
      return unless @are_you_working != "no" && @children_living_with_you == "yes"

      age_groups = if @children_with_disability == "yes"
                     %w[1_or_under 2 3_to_4 5_to_7 8_to_11 12_to_15 16_to_17]
                   else
                     %w[1_or_under 2 3_to_4 5_to_7 8_to_11]
                   end

      eligible_child_ages?(age_groups)
    end

    def eligible_for_free_childcare_2yr_olds?
      @children_living_with_you == "yes" && eligible_child_ages?(%w[2])
    end

    def eligible_for_childcare_3_4yr_olds?
      @are_you_working == "yes_over_16_hours_per_week" &&
        @children_living_with_you == "yes" &&
        eligible_child_ages?(%w[3_to_4])
    end

    def eligible_for_15hrs_free_childcare_3_4yr_olds?
      @children_living_with_you == "yes" && eligible_child_ages?(%w[3_to_4])
    end

    def eligible_for_30hrs_free_childcare_3_4yrs?
      @are_you_working != "no" &&
        @children_living_with_you == "yes" &&
        eligible_child_ages?(%w[3_to_4])
    end

    def eligible_for_funded_early_learning_and_childcare?
      @children_living_with_you == "yes" && eligible_child_ages?(%w[2 3_to_4])
    end

    def eligible_for_child_benefit?
      @children_living_with_you == "yes"
    end

    def eligible_for_child_disability_support?
      age_groups = %w[1_or_under 2 3_to_4 5_to_7 8_to_11 12_to_15]

      @children_living_with_you == "yes" &&
        eligible_child_ages?(age_groups) &&
        @children_with_disability == "yes"
    end

    def eligible_for_carers_allowance?
      @carer_disability_or_health_condition == "yes"
    end

    def eligible_for_personal_independence_payment?
      return unless @over_state_pension_age == "no"

      return true if @disability_or_health_condition == "yes"

      age_groups = %w[16_to_17 18_to_19]

      @children_living_with_you == "yes" &&
        eligible_child_ages?(age_groups) &&
        @children_with_disability == "yes"
    end

    def eligible_for_attendance_allowance?
      @over_state_pension_age == "yes" && @disability_or_health_condition == "yes"
    end

    def eligible_for_free_tv_licence?
      @over_state_pension_age == "yes"
    end

    def eligible_for_nhs_low_income_scheme?
      %w[under_16000 none_16000].include?(@assets_and_savings)
    end

  private

    def eligible_child_ages?(age_groups)
      @age_of_children.split(",").any? { |age| age_groups.include?(age) }
    end

    def general_child_benefit_eligibility?(skip_benefit_list, age_groups)
      return if @children_living_with_you == "no"
      return unless eligible_child_ages?(age_groups)
      return if @on_benefits == "no"

      permitted_benefits?(skip_benefit_list)
    end

    def permitted_benefits?(skip_benefit_list)
      return true if @on_benefits == "dont_know"

      @current_benefits.split(",").none? do |benefit|
        skip_benefit_list.include?(benefit)
      end
    end
  end
end
