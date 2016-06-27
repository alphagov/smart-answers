module SmartAnswer::Calculators
  class StatePensionThroughPartnerCalculator
    include ActiveModel::Model

    attr_accessor :marital_status
    attr_accessor :when_will_you_reach_pension_age
    attr_accessor :when_will_your_partner_reach_pension_age
    attr_accessor :gender

    def lower_basic_state_pension_rate
      rates.lower_weekly_rate
    end

    def higher_basic_state_pension_rate
      rates.weekly_rate
    end

    def divorced?
      marital_status == 'divorced'
    end

    def married?
      marital_status == 'married'
    end

    def widowed?
      marital_status == 'widowed'
    end

    def reached_pension_age_before_specific_date?
      when_will_you_reach_pension_age == 'your_pension_age_before_specific_date'
    end

    def reached_pension_age_after_specific_date?
      when_will_you_reach_pension_age == 'your_pension_age_after_specific_date'
    end

    def partner_reached_pension_age_before_specific_date?
      when_will_your_partner_reach_pension_age == 'partner_pension_age_before_specific_date'
    end

    def partner_reached_pension_age_after_specific_date?
      when_will_your_partner_reach_pension_age == 'partner_pension_age_after_specific_date'
    end

    def male?
      gender == 'male_gender'
    end

    def female?
      gender == 'female_gender'
    end

    def answers_part_1
      answers = []
      if married?
        answers << :old1
      elsif widowed?
        answers << :widow
      end
      answers
    end

    def answers_part_2
      answers = answers_part_1
      if reached_pension_age_before_specific_date?
        answers << :old2
      elsif reached_pension_age_after_specific_date?
        answers << :new2
      end
      answers << :old3 if widowed?
      answers
    end

    def answers_part_3
      answers = answers_part_2
      if partner_reached_pension_age_before_specific_date?
        answers << :old3
      elsif partner_reached_pension_age_after_specific_date?
        answers << :new3
      end
      answers
    end

    def widow_and_new_pension?
      (!married? && widowed?) && reached_pension_age_after_specific_date?
    end

    def widow_and_old_pension?
      (!married? && widowed?) && reached_pension_age_before_specific_date?
    end

    def current_rules_no_additional_pension?
      answers_part_3 == [:old1, :old2, :old3] || answers_part_3 == [:new1, :old2, :old3]
    end

    def current_rules_national_insurance_no_state_pension?
      answers_part_3 == [:old1, :old2, :new3] || answers_part_3 == [:new1, :old2, :new3]
    end

  private

    def rates
      @rates ||= RatesQuery.from_file('state_pension').rates
    end
  end
end
