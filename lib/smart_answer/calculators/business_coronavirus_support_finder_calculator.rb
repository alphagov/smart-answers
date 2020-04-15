module SmartAnswer::Calculators
  class BusinessCoronavirusSupportFinderCalculator
    attr_accessor :business_based,
                  :business_size,
                  :paye_scheme,
                  :annual_turnover,
                  :business_rates,
                  :non_domestic_property,
                  :self_assessment_july_2020,
                  :sectors

    RULES = {
      job_retention_scheme: ->(calculator) {
        calculator.paye_scheme == "yes"
      },
      vat_scheme: ->(calculator) {
        calculator.annual_turnover != "under_85k"
      },
      self_assessment_payments: ->(calculator) {
        calculator.self_assessment_july_2020 == "yes"
      },
      statutory_sick_rebate: ->(calculator) {
        calculator.business_size == "0_to_249" &&
          calculator.self_assessment_july_2020 == "yes"
      },
      self_employed_income_scheme: ->(calculator) {
        calculator.business_size == "0_to_249"
      },
      business_rates: ->(calculator) {
        calculator.business_based == "england" &&
          calculator.business_rates == "yes" &&
          calculator.non_domestic_property != "none" &&
          (%w[retail hospitality leisure] & calculator.sectors).any?
      },
      grant_funding: ->(calculator) {
        calculator.business_based == "england" &&
          calculator.business_rates == "yes" &&
          calculator.non_domestic_property == "over_15k" &&
          (%w[retail hospitality leisure] & calculator.sectors).any?
      },
      nursery_support: ->(calculator) {
        calculator.business_based == "england" &&
          calculator.business_rates == "yes" &&
          calculator.non_domestic_property != "none" &&
          calculator.sectors.include?("nurseries")
      },
      small_business_grant_funding: ->(calculator) {
        calculator.business_based == "england" &&
          calculator.business_size == "0_to_249" &&
          calculator.non_domestic_property == "up_to_15k"
      },
      business_loan_scheme: ->(calculator) {
        %w[under_85k 85k_to_45m].include?(calculator.annual_turnover)
      },
      large_business_loan_scheme: ->(calculator) {
        calculator.annual_turnover == "45m_to_500m"
      },
    }.freeze

    def show?(result_id)
      RULES[result_id].call(self)
    end
  end
end
