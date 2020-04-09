module SmartAnswer::Calculators
  class CoronavirusBusinessSupportCalculator
    attr_accessor :business_based,
                  :business_size,
                  :self_employed,
                  :annual_turnover,
                  :business_rates,
                  :non_domestic_property,
                  :self_assessment_july_2020,
                  :sectors

    RULES = {
      job_retention_scheme: ->(calculator) {
        calculator.self_employed == "no"
      },
      vat_scheme: ->(calculator) {
        calculator.annual_turnover != "under_85k"
      },
      self_assessment_payments: ->(calculator) {
        calculator.self_assessment_july_2020 == "yes"
      },
      statutory_sick_rebate: ->(calculator) {
        calculator.business_size == "small_medium_enterprise" &&
          calculator.self_employed == "no" &&
          calculator.self_assessment_july_2020 == "yes"
      },
      self_employed_income_scheme: ->(calculator) {
        calculator.business_size == "small_medium_enterprise" &&
          calculator.self_employed == "yes"
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
          calculator.business_size == "small_medium_enterprise" &&
          calculator.non_domestic_property == "under_15k"
      },
      business_loan_scheme: ->(calculator) {
        calculator.self_employed == "no" &&
          %w[under_85k over_85k].include?(calculator.annual_turnover)
      },
      corporate_financing: ->(calculator) {
        calculator.self_employed == "no"
      },
      business_tax_support: ->(calculator) {
        calculator.self_employed == "no"
      },
    }.freeze

    def show?(result_id)
      RULES[result_id].call(self)
    end

    def no_results?
      RULES.values.none? { |rule| rule.call(self) }
    end
  end
end
