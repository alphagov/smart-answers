module SmartAnswer::Calculators
  class UkBenefitsAbroadCalculator
    include ActiveModel::Model

    attr_accessor :country, :benefits, :dispute_criteria, :partner_premiums
    attr_accessor :possible_impairments, :impairment_periods, :tax_credits

    COUNTRIES_OF_FORMER_YUGOSLAVIA = %w(bosnia-and-herzegovina kosovo macedonia montenegro serbia).freeze
    STATE_BENEFITS = {
      bereavement_benefits: "Bereavement benefits",
      severe_disablement_allowance: "Severe Disablement Allowance",
      employment_and_support_allowance: "Employment and Support Allowance",
      incapacity_benefit: "Incapacity Benefit",
      industrial_injuries_disablement_benefit: "Industrial Injuries Disablement Benefit",
      state_pension: "State Pension"
    }.freeze
    DISPUTE_CRITERIA = {
      trades_dispute: "I'm affected by a trades dispute (eg on strike)",
      full_time_secondary_education: "I'm age 16 to 19 and in full-time secondary education",
      appealing_against_decision: "I'm appealing against a decision about your ability to work"
    }.freeze
    PREMIUMS = {
      pension_premium: "Pensioner premium",
      higher_pensioner: "Higher Pensioner premium",
      disability_premium: "Disability premium",
      severe_disability_premium: "Severe Disability premium"
    }.freeze
    private_constant :STATE_BENEFITS, :DISPUTE_CRITERIA, :PREMIUMS

    def eea_country?
      %w(austria belgium bulgaria croatia cyprus czech-republic denmark estonia
         finland france germany gibraltar greece hungary iceland ireland italy
         latvia liechtenstein lithuania luxembourg malta netherlands norway
         poland portugal romania slovakia slovenia spain sweden switzerland).include?(country)
    end

    def former_yugoslavia?
      COUNTRIES_OF_FORMER_YUGOSLAVIA.include?(country)
    end

    def social_security_countries_jsa?
      (COUNTRIES_OF_FORMER_YUGOSLAVIA + %w(guernsey jersey new-zealand)).include?(country)
    end

    def social_security_countries_iidb?
      (COUNTRIES_OF_FORMER_YUGOSLAVIA +
      %w(barbados bermuda guernsey jersey israel jamaica mauritius philippines turkey)).include?(country)
    end

    def social_security_countries_bereavement_benefits?
      (COUNTRIES_OF_FORMER_YUGOSLAVIA +
      %w(barbados bermuda canada guernsey jersey israel jamaica mauritius new-zealand philippines turkey usa)).include?(country)
    end

    def state_benefits
      STATE_BENEFITS
    end

    def all_dispute_criteria
      DISPUTE_CRITERIA
    end

    def premiums
      PREMIUMS
    end

    def benefits?
      benefits.present? && benefits.is_a?(Array) && valid_benefits?
    end

    def dispute_criteria?
      dispute_criteria.present? &&
        dispute_criteria.is_a?(Array) &&
        valid_dispute_criteria?
    end

    def partner_premiums?
      partner_premiums.present? &&
        partner_premiums.is_a?(Array) &&
        valid_partner_premiums?
    end

    def getting_income_support?
      possible_impairments.present? &&
        possible_impairments.is_a?(Array) &&
        possible_impairments?
    end

    def not_getting_sick_pay?
      impairment_periods.present? &&
        impairment_periods.is_a?(Array) &&
        valid_impairment_periods?
    end

    def tax_credits?
      tax_credits.present? &&
        tax_credits.is_a?(Array) &&
        valid_tax_credits_benefits?
    end

  private

    def valid_benefits?
      benefits.map(&:to_sym).all? { |benefit| state_benefits.keys.include?(benefit) }
    end

    def valid_dispute_criteria?
      dispute_criteria.map(&:to_sym).all? do |criterion|
        all_dispute_criteria.keys.include?(criterion)
      end
    end

    def valid_partner_premiums?
      partner_premiums.map(&:to_sym).all? do |premium|
        premiums.keys.include?(premium)
      end
    end

    def possible_impairments?
      possible_impairments.all? do |impairment|
        %w(
          too_ill_to_work
          temporarily_incapable_of_work
        ).include?(impairment)
      end
    end

    def valid_impairment_periods?
      impairment_periods.all? do |period|
        %w(
          364_days
          196_days
        ).include?(period)
      end
    end

    def valid_tax_credits_benefits?
      tax_credits.all? do |tax_credit|
        %w(
          state_pension
          widows_benefit
          incapacity_benefit
          bereavement_benefit
          severe_disablement_allowance
          industrial_injuries_disablement_benefit
          contribution_based_employment_support_allowance
        ).include?(tax_credit)
      end
    end
  end
end
