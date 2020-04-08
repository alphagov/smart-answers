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

    def show_job_retention_scheme?
      self_employed == "no"
    end

    def show_vat_scheme?
      annual_turnover == "under_85k"
    end

    def show_self_assessment_payments?
      self_assessment_july_2020 == "yes"
    end

    def show_statutory_sick_rebate?
      business_size == "small_medium_enterprise" &&
        self_employed == "no" &&
        self_assessment_july_2020 == "yes"
    end

    def show_self_employed_income_scheme?
      business_size == "small_medium_enterprise" &&
        self_employed == "yes"
    end

    def show_business_rates?
      business_based == "england" &&
        business_rates == "yes" &&
        non_domestic_property != "none" &&
        (%w[retail hospitality leisure] & sectors).any?
    end

    def show_grant_funding?
      business_based == "england" &&
        business_rates == "yes" &&
        non_domestic_property == "over_15k" &&
        (%w[retail hospitality leisure] & sectors).any?
    end

    def show_nursery_support?
      business_based == "england" &&
        business_rates == "yes" &&
        non_domestic_property != "none" &&
        sectors.include?("nurseries")
    end

    def show_small_business_grant_funding?
      business_based == "england" &&
        business_size == "small_medium_enterprise" &&
        non_domestic_property == "under_15k"
    end

    def show_business_loan_scheme?
      self_employed == "no" &&
        annual_turnover != "over_45m"
    end

    def show_corporate_financing?
      self_employed == "no"
    end

    def show_business_tax_support?
      self_employed == "no" &&
        annual_turnover != "over_45m"
    end
  end
end
