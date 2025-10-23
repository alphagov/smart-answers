module SmartAnswer::Calculators
  class StatePensionThroughPartnerCalculator
    include ActiveModel::Model

    attr_accessor :marital_status,
                  :when_will_you_reach_pension_age,
                  :when_will_your_partner_reach_pension_age,
                  :gender

    LOWER_BASIC_STATE_PENSION_RATE_EMBED_CODE = "{{embed:content_block_pension:basic-state-pension/rates/lower-basic-state-pension-amount/amount}}".freeze
    HIGHER_BASIC_STATE_PENSION_RATE_EMBED_CODE = "{{embed:content_block_pension:basic-state-pension/rates/full-basic-state-pension-amount/amount}}".freeze

    def lower_basic_state_pension_rate
      @lower_basic_state_pension_rate ||= SmartAnswer::ContentBlock.new(LOWER_BASIC_STATE_PENSION_RATE_EMBED_CODE).render
    end

    def higher_basic_state_pension_rate
      @higher_basic_state_pension_rate ||= SmartAnswer::ContentBlock.new(HIGHER_BASIC_STATE_PENSION_RATE_EMBED_CODE).render
    end

    def divorced?
      marital_status == "divorced"
    end

    def married?
      marital_status == "married"
    end

    def widowed?
      marital_status == "widowed"
    end

    def reached_pension_age_before_specific_date?
      when_will_you_reach_pension_age == "your_pension_age_before_specific_date"
    end

    def reached_pension_age_after_specific_date?
      when_will_you_reach_pension_age == "your_pension_age_after_specific_date"
    end

    def partner_reached_pension_age_before_specific_date?
      when_will_your_partner_reach_pension_age == "partner_pension_age_before_specific_date"
    end

    def partner_reached_pension_age_after_specific_date?
      when_will_your_partner_reach_pension_age == "partner_pension_age_after_specific_date"
    end

    def male?
      gender == "male_gender"
    end

    def female?
      gender == "female_gender"
    end

    def widow_and_new_pension?
      widowed? && reached_pension_age_after_specific_date?
    end

    def widow_and_old_pension?
      widowed? && reached_pension_age_before_specific_date?
    end

    def current_rules_no_additional_pension?
      married? && reached_pension_age_before_specific_date? && partner_reached_pension_age_before_specific_date?
    end

    def current_rules_national_insurance_no_state_pension?
      married? && reached_pension_age_before_specific_date? && partner_reached_pension_age_after_specific_date?
    end
  end
end
