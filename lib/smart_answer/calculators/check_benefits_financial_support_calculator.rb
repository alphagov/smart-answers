module SmartAnswer::Calculators
  class CheckBenefitsFinancialSupportCalculator
    attr_accessor :where_do_you_live,
                  :over_state_pension_age,
                  :are_you_working,
                  :how_many_paid_hours_work,
                  :disability_or_health_condition,
                  :disability_affecting_daily_tasks,
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
      return false unless @children_living_with_you == "yes"

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

    def eligible_for_healthy_start?
      skip_benefit_list = %w[housing_benefit]
      age_groups = %w[pregnant 1_or_under 2 3_to_4]

      general_child_benefit_eligibility?(skip_benefit_list, age_groups)
    end

    def best_start_foods_scotland?
      skip_benefit_list = %w[pension_credit housing_benefit]
      age_groups = %w[pregnant 1_or_under 2]

      general_child_benefit_eligibility?(skip_benefit_list, age_groups)
    end

    def eligible_for_free_school_meals?
      skip_benefit_list = %w[housing_benefit]
      age_groups = %w[3_to_4 5_to_7 8_to_11 12_to_15 16_to_17]

      general_child_benefit_eligibility?(skip_benefit_list, age_groups)
    end

    def eligible_for_free_school_meals_scotland?
      skip_benefit_list = []
      age_groups = %w[3_to_4 5_to_7 8_to_11 12_to_15 16_to_17]

      general_child_benefit_eligibility?(skip_benefit_list, age_groups)
    end

    def eligible_for_school_clothing_grant_scotland?
      skip_benefit_list = []
      age_groups = %w[3_to_4 5_to_7 8_to_11 12_to_15 16_to_17 18_to_19]

      general_child_benefit_eligibility?(skip_benefit_list, age_groups)
    end

    def eligible_for_uniform_grant_northern_ireland?
      skip_benefit_list = %w[housing_benefit]
      age_groups = %w[3_to_4 5_to_7 8_to_11 12_to_15 16_to_17]

      general_child_benefit_eligibility?(skip_benefit_list, age_groups)
    end

    def eligible_for_pupil_development_grant_wales?
      skip_benefit_list = %w[housing_benefit]
      age_groups = %w[3_to_4 5_to_7 8_to_11 12_to_15 16_to_17]

      general_child_benefit_eligibility?(skip_benefit_list, age_groups)
    end

    def eligible_for_school_transport?
      age_groups = %w[3_to_4 5_to_7 8_to_11 12_to_15 16_to_17 18_to_19]

      @children_living_with_you == "yes" && eligible_child_ages?(age_groups)
    end

    def eligible_for_an_older_persons_bus_pass?
      @over_state_pension_age == "yes"
    end

    def eligible_for_free_tv_license?
      return true if @disability_or_health_condition == "yes"
      return false if @over_state_pension_age == "no"
      return false if @on_benefits == "no"

      @on_benefits == "dont_know" || !permitted_benefits?(%w[pension_credit])
    end

    def eligible_for_a_disabled_persons_bus_pass?
      @disability_or_health_condition == "yes"
    end

    def eligible_for_employment_and_support_allowance?
      @over_state_pension_age == "no" &&
        @are_you_working != "no_retired" &&
        @disability_or_health_condition == "yes" &&
        @disability_affecting_work != "no"
    end

    def eligible_for_jobseekers_allowance?
      eligible_for_jobseekers_in_paid_work? || eligible_for_jobseekers_not_in_paid_work?
    end

    def eligible_for_pension_credit?
      return false if @over_state_pension_age == "no"

      @on_benefits == "no" || permitted_benefits?(%w[pension_credit])
    end

    def eligible_for_access_to_work?
      @disability_or_health_condition == "yes" &&
        @disability_affecting_work != "yes_unable_to_work"
    end

    def eligible_for_universal_credit?
      return false if @over_state_pension_age == "yes"
      return false if @assets_and_savings == "over_16000"

      @on_benefits == "no" || permitted_benefits?(%w[universal_credit])
    end

    def eligible_for_housing_benefit?
      return false if @over_state_pension_age == "no"

      @on_benefits == "no" || permitted_benefits?(%w[housing_benefit])
    end

    def eligible_for_scottish_child_payment?
      age_groups = %w[1_or_under 2 3_to_4 5_to_7 8_to_11 12_to_15]
      return false unless @children_living_with_you == "yes" && eligible_child_ages?(age_groups)
      return false if @on_benefits == "no"

      permitted_benefits?(%w[housing_benefit])
    end

    def eligible_for_tax_free_childcare?
      return false if @are_you_working != "yes"
      return false if @children_living_with_you == "no"
      return false if @children_with_disability == "yes"

      age_groups = %w[1_or_under 2 3_to_4 5_to_7 8_to_11]
      eligible_child_ages?(age_groups)
    end

    def eligible_for_tax_free_childcare_with_disability?
      return false if @are_you_working != "yes"
      return false if @children_living_with_you == "no"
      return false if @children_with_disability == "no"

      age_groups = %w[1_or_under 2 3_to_4 5_to_7 8_to_11 12_to_15 16_to_17]
      eligible_child_ages?(age_groups)
    end

    def eligible_for_free_childcare_2yr_olds?
      return false unless @children_living_with_you == "yes" && eligible_child_ages?(%w[2])
      return false if @on_benefits == "no"

      permitted_benefits?(%w[housing_benefit])
    end

    def eligible_for_childcare_3_4yr_olds?
      @children_living_with_you == "yes" &&
        eligible_child_ages?(%w[3_to_4])
    end

    def eligible_for_15hrs_free_childcare_3_4yr_olds?
      @children_living_with_you == "yes" && eligible_child_ages?(%w[3_to_4])
    end

    def eligible_for_free_childcare_when_working_1_under_2_3_4yrs?
      age_groups = %w[1_or_under 2 3_to_4]

      @are_you_working == "yes" &&
        @children_living_with_you == "yes" &&
        eligible_child_ages?(age_groups)
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

    def eligible_for_winter_fuel_payment?
      return false if
        @where_do_you_live == "scotland" || @where_do_you_live == "northern-ireland"

      true if @over_state_pension_age == "yes"
    end

    def eligible_for_winter_fuel_payment_ni?
      @where_do_you_live == "northern-ireland" && @over_state_pension_age == "yes"
    end

    def eligible_for_carers_allowance?
      @carer_disability_or_health_condition == "yes"
    end

    def eligible_for_personal_independence_payment?
      return true if @over_state_pension_age == "no" && @disability_or_health_condition == "yes"

      age_groups = %w[16_to_17 18_to_19]

      @children_living_with_you == "yes" &&
        eligible_child_ages?(age_groups) &&
        @children_with_disability == "yes"
    end

    def eligible_for_adult_disability_payment_scotland?
      @over_state_pension_age == "no" &&
        @disability_or_health_condition == "yes" &&
        @disability_affecting_daily_tasks == "yes"
    end

    def eligible_for_attendance_allowance?
      @over_state_pension_age == "yes" &&
        @disability_or_health_condition == "yes" &&
        @disability_affecting_daily_tasks == "yes"
    end

    def eligible_for_budgeting_loan?
      return false if @on_benefits == "no"

      skip_benefit_list = %w[universal_credit housing_benefit]

      permitted_benefits?(skip_benefit_list)
    end

    def eligible_for_support_for_mortgage_interest?
      return false if @on_benefits == "no"

      skip_benefit_list = %w[housing_benefit]

      permitted_benefits?(skip_benefit_list)
    end

    def eligible_for_education_maintenance_allowance_ni?
      @children_living_with_you == "yes" && eligible_child_ages?(%w[16_to_17 18_to_19])
    end

    def eligible_for_warm_home_discount_scheme?
      @on_benefits != "no"
    end

    def eligible_for_help_to_save?
      if @current_benefits.nil?
        eligible_for_help_to_save_dont_know_if_on_benefits?
      else
        eligible_for_help_to_save_on_benefits?
      end
    end

    def eligible_disabled_facilities_grant?
      disabled_adult_less_than_16000_savings? || living_with_disabled_child_less_than_16000_savings?
    end

    def eligible_for_help_with_house_adaptations_if_you_are_disabled?
      @disability_or_health_condition == "yes" || living_with_disabled_child?
    end

  private

    def eligible_for_help_to_save_dont_know_if_on_benefits?
      @over_state_pension_age == "no" &&
        @on_benefits == "dont_know"
    end

    def eligible_for_help_to_save_on_benefits?
      @over_state_pension_age == "no" &&
        @on_benefits == "yes" &&
        @current_benefits.include?("universal_credit")
    end

    def eligible_for_jobseekers_in_paid_work?
      @over_state_pension_age == "no" &&
        @are_you_working == "yes" &&
        @how_many_paid_hours_work == "sixteen_or_less_per_week" &&
        @disability_affecting_work != "yes_unable_to_work"
    end

    def eligible_for_jobseekers_not_in_paid_work?
      @over_state_pension_age == "no" &&
        @are_you_working == "no" &&
        @disability_affecting_work != "yes_unable_to_work"
    end

    def eligible_child_ages?(age_groups)
      @age_of_children.split(",").any? { |age| age_groups.include?(age) }
    end

    def general_child_benefit_eligibility?(skip_benefit_list, age_groups)
      return false if @children_living_with_you == "no"
      return false unless eligible_child_ages?(age_groups)
      return false if @on_benefits == "no"

      permitted_benefits?(skip_benefit_list)
    end

    def permitted_benefits?(skip_benefit_list)
      return true if @on_benefits == "dont_know"

      @current_benefits.split(",").none? do |benefit|
        skip_benefit_list.include?(benefit)
      end
    end

    def living_with_disabled_child?
      @children_living_with_you == "yes" && @children_with_disability == "yes"
    end

    def disabled_adult_less_than_16000_savings?
      @disability_or_health_condition == "yes" && @assets_and_savings != "over_16000"
    end

    def living_with_disabled_child_less_than_16000_savings?
      living_with_disabled_child? && @assets_and_savings != "over_16000"
    end
  end
end
