module SmartAnswer::Calculators
  class CheckBenefitsSupportCalculator
    attr_accessor :where_do_you_live,
                  :over_state_pension_age,
                  :are_you_working,
                  :disability_or_health_condition,
                  :disability_affecting_work,
                  :carer_disability_or_health_condition,
                  :unpaid_care_hours,
                  :children_living_with_you,
                  :age_of_children,
                  :children_with_disability,
                  :assets_and_savings

    def benefit_data
      YAML.load_file(Rails.root.join("config/smart_answers/check_benefits_support_data.yml")).freeze
    end

    def benefits_for_outcome
      benefit_data["benefits"].select { |benefit| benefit }.compact
    end

    def eligible_for_employment_and_support_allowance?
      @over_state_pension_age == "no" &&
        @disability_or_health_condition == "yes" &&
        disability_affecting_work != "no"
    end

    def eligible_for_jobseekers_allowance?
      @where_do_you_live != "northern-ireland" &&
        @over_state_pension_age == "no" &&
        @are_you_working != "yes_over_16_hours_per_week" &&
        @disability_affecting_work != "yes_unable_to_work"
    end

    def eligible_for_pension_credit?
      @over_state_pension_age == "no"
    end

    def eligible_for_access_to_work?
      @where_do_you_live != "northern-ireland" &&
        @disability_or_health_condition == "yes" &&
        @disability_affecting_work != "yes_unable_to_work"
    end

    def eligible_for_universal_credit?
      @over_state_pension_age == "no" && @assets_and_savings == "under_16000"
    end

    def eligible_for_housing_benefit?
      @over_state_pension_age == "yes"
    end

    def eligible_for_tax_free_childcare?
      eligible_child_ages = %w[1_or_under 2 3_to_4 5_to_11]
      @are_you_working == "yes" &&
        @children_living_with_you == "yes" &&
        @age_of_children.split(",").any? { |age| eligible_child_ages.include?(age) }
    end

    def eligible_for_free_childcare_2yr_olds?
      @where_do_you_live == "england" &&
        @children_living_with_you == "yes" &&
        @age_of_children.split(",").any?("2")
    end

    def eligible_for_childcare_3_4yr_olds_wales?
      @where_do_you_live == "wales" &&
        @are_you_working == "yes_under_16_hours_per_week" &&
        @children_living_with_you == "yes" &&
        @age_of_children.split(",").any?("3_to_4")
    end

    def eligible_for_15hrs_free_childcare_3_4yr_olds?
      @where_do_you_live == "england" &&
        @children_living_with_you == "yes" &&
        @age_of_children.split(",").any?("3_to_4")
    end

    def eligible_for_30hrs_free_childcare_3_4yrs?
      @are_you_working == "yes_over_16_hours_per_week" &&
        @children_living_with_you == "yes" &&
        @age_of_children.split(",").any?("3_to_4")
    end

    def eligible_for_30hrs_free_childcare_3_4yrs_scotland?
      @where_do_you_live == "scotland" &&
        @children_living_with_you == "yes" &&
        @age_of_children.split(",").any?("3_to_4")
    end

    def eligible_for_2yr_old_childcare_scotland?
      @where_do_you_live == "scotland" &&
        @children_living_with_you == "yes" &&
        @age_of_children.split(",").any?("2")
    end

    def eligible_for_child_benefit?
      @children_living_with_you == "yes"
    end

    def eligible_for_disability_living_allowance_for_children?
      eligible_child_ages = %w[1_or_under 2 3_to_4 5_to_11 12_to_15]

      %w[england wales].include?(@where_do_you_live) &&
        @carer_disability_or_health_condition == "yes" &&
        @children_living_with_you == "yes" &&
        @age_of_children.split(",").any? { |age| eligible_child_ages.include?(age) } &&
        @children_with_disability == "yes"
    end
  end
end
