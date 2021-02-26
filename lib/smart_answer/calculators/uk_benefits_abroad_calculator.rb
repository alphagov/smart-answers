module SmartAnswer::Calculators
  class UkBenefitsAbroadCalculator
    include ActiveModel::Model

    attr_accessor :country,
                  :country_name,
                  :benefits,
                  :dispute_criteria,
                  :partner_premiums,
                  :possible_impairments,
                  :impairment_periods,
                  :tax_credits,
                  :going_abroad,
                  :benefit

    COUNTRIES_OF_FORMER_YUGOSLAVIA = %w[bosnia-and-herzegovina kosovo montenegro north-macedonia serbia].freeze
    STATE_BENEFITS = {
      bereavement_benefits: "Bereavement benefits",
      severe_disablement_allowance: "Severe Disablement Allowance",
      employment_and_support_allowance: "Employment and Support Allowance",
      incapacity_benefit: "Incapacity Benefit",
      industrial_injuries_disablement_benefit: "Industrial Injuries Disablement Benefit",
      state_pension: "State Pension",
    }.freeze
    DISPUTE_CRITERIA = {
      trades_dispute: "I'm affected by a trades dispute (eg on strike)",
      full_time_secondary_education: "I'm age 16 to 19 and in full-time secondary education",
      appealing_against_decision: "I'm appealing against a decision about my ability to work",
    }.freeze
    PREMIUMS = {
      pension_premium: "Pensioner premium",
      higher_pensioner: "Higher Pensioner premium",
      disability_premium: "Disability premium",
      severe_disability_premium: "Severe Disability premium",
    }.freeze
    IMPAIRMENTS = {
      too_ill_to_work: "I’m getting Statutory Sick Pay",
      temporarily_incapable_of_work: "I’m incapable of work, but being treated as capable of work because I’m temporarily disqualified from receiving Income Support",
    }.freeze
    PERIODS_OF_IMPAIRMENT = {
      "364_days": "364 days",
      "196_days": "196 days if you're terminally ill, or getting the highest rate of Disability Living Allowance (care component) or the enhanced rate of Personal Independence Payment (daily living component)",
    }.freeze
    TAX_CREDITS_BENEFITS = {
      state_pension: "State Pension",
      widows_benefit: "Widow’s Benefit",
      incapacity_benefit: "Incapacity Benefit",
      bereavement_benefit: "Bereavement Benefit",
      severe_disablement_allowance: "Severe Disablement Allowance",
      industrial_injuries_disablement_benefit: "Industrial Injuries Disablement Benefit",
      contribution_based_employment_support_allowance: "contribution-based Employment and Support Allowance",
    }.freeze
    EEA_COUNTRIES = %w[austria
                       belgium
                       bulgaria
                       croatia
                       cyprus
                       czech-republic
                       denmark
                       estonia
                       finland
                       france
                       germany
                       gibraltar
                       greece
                       hungary
                       iceland
                       ireland
                       italy
                       latvia
                       liechtenstein
                       lithuania
                       luxembourg
                       malta
                       netherlands
                       norway
                       poland
                       portugal
                       romania
                       slovakia
                       slovenia
                       spain
                       sweden
                       switzerland].freeze

    def eea_country?
      EEA_COUNTRIES.include?(country)
    end

    def country_eligible_for_winter_fuel_payment?
      (EEA_COUNTRIES - %w[cyprus france gibraltar greece malta portugal spain]).include?(country)
    end

    def former_yugoslavia?
      COUNTRIES_OF_FORMER_YUGOSLAVIA.include?(country)
    end

    def social_security_countries_jsa?
      if going_abroad
        (COUNTRIES_OF_FORMER_YUGOSLAVIA + %w[guernsey new-zealand]).include?(country)
      else
        (COUNTRIES_OF_FORMER_YUGOSLAVIA +
        %w[barbados bermuda canada guernsey jersey israel jamaica mauritius new-zealand philippines turkey usa]).include?(country)
      end
    end

    def social_security_countries_iidb?
      (COUNTRIES_OF_FORMER_YUGOSLAVIA +
      %w[barbados bermuda guernsey jersey israel jamaica mauritius philippines turkey]).include?(country)
    end

    def social_security_countries_bereavement_benefits?
      (COUNTRIES_OF_FORMER_YUGOSLAVIA +
      %w[barbados bermuda canada guernsey jersey israel jamaica mauritius new-zealand philippines turkey usa]).include?(country)
    end

    def employer_paying_ni_not_ssp_country_entitled?
      (COUNTRIES_OF_FORMER_YUGOSLAVIA + %w[barbados guernsey jersey israel turkey]).include?(country)
    end

    def channel_islands?
      %w[jersey guernsey].include?(country)
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

    def impairments
      IMPAIRMENTS
    end

    def periods_of_impairment
      PERIODS_OF_IMPAIRMENT
    end

    def tax_credits_benefits
      TAX_CREDITS_BENEFITS
    end

    def benefits?
      ListValidator.call(
        constraint: STATE_BENEFITS,
        test: benefits,
      )
    end

    def dispute_criteria?
      ListValidator.call(
        constraint: DISPUTE_CRITERIA,
        test: dispute_criteria,
      )
    end

    def partner_premiums?
      ListValidator.call(
        constraint: PREMIUMS,
        test: partner_premiums,
      )
    end

    def getting_income_support?
      ListValidator.call(
        constraint: IMPAIRMENTS,
        test: possible_impairments,
      )
    end

    def not_getting_sick_pay?
      ListValidator.call(
        constraint: PERIODS_OF_IMPAIRMENT,
        test: impairment_periods,
      )
    end

    def tax_credits?
      ListValidator.call(
        constraint: TAX_CREDITS_BENEFITS,
        test: tax_credits,
      )
    end

    def already_abroad
      !going_abroad
    end

    def country_question_title
      if going_abroad
        "Which country are you moving to?"
      else
        "Which country are you living in?"
      end
    end

    def why_abroad_question_title
      if going_abroad
        "Why are you going abroad?"
      else
        "Why have you gone abroad?"
      end
    end

    def already_abroad_text_two
      " or permanently" if already_abroad
    end

    def how_long_question_titles
      if benefit == "disability_benefits"
        "How long will you be abroad for?"
      elsif going_abroad
        "How long are you going abroad for?"
      else
        "How long will you be living abroad for?"
      end
    end
  end
end
