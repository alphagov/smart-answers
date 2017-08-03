module SmartAnswer::Calculators
  class UkBenefitsAbroadCalculator
    include ActiveModel::Model

    COUNTRIES_OF_FORMER_YUGOSLAVIA = %w(bosnia-and-herzegovina kosovo macedonia montenegro serbia).freeze

    attr_accessor :country, :benefits, :dispute_criteria

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

    def benefits?
      benefits.present? && benefits.is_a?(Array) && valid_benefits?
    end

    def dispute_criteria?
      dispute_criteria.present? &&
        dispute_criteria.is_a?(Array) &&
        valid_dispute_criteria?
    end

  private

    def valid_benefits?
      benefits.all? do |benefit|
        %w(
          bereavement_benefits
          severe_disablement_allowance
          employment_and_support_allowance
          incapacity_benefit
          industrial_injuries_disablement_benefit
          state_pension
        ).include?(benefit)
      end
    end

    def valid_dispute_criteria?
      dispute_criteria.all? do |criterion|
        %w(
          trades_dispute
          full_time_secondary_education
          appealing_against_decision
        ).include?(criterion)
      end
    end
  end
end
