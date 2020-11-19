module SmartAnswer::Calculators
  class BusinessCoronavirusSupportFinderCalculator
    attr_accessor :business_based,
                  :business_size,
                  :annual_turnover,
                  :paye_scheme,
                  :self_employed,
                  :non_domestic_property,
                  :sectors,
                  :rate_relief_march_2020

    RULES = {
      job_retention_scheme: lambda { |calculator|
        calculator.paye_scheme == "yes"
      },
      statutory_sick_rebate: lambda { |calculator|
        calculator.business_size == "0_to_249" &&
          calculator.paye_scheme == "yes"
      },
      self_employed_income_scheme: lambda { |calculator|
        calculator.business_size == "0_to_249" &&
          calculator.self_employed == "yes"
      },
      retail_hospitality_leisure_business_rates: lambda { |calculator|
        calculator.business_based == "england" &&
          calculator.non_domestic_property != "none" &&
          calculator.sectors.include?("retail_hospitality_or_leisure")
      },
      nursery_support: lambda { |calculator|
        calculator.business_based == "england" &&
          calculator.non_domestic_property != "none" &&
          calculator.sectors.include?("nurseries")
      },
      discretionary_grant: lambda { |calculator|
        calculator.business_based == "england" &&
          calculator.business_size == "0_to_249" &&
          %w[under_85k 85k_to_45m].include?(calculator.annual_turnover)
      },
      business_loan_scheme: lambda { |calculator|
        %w[under_85k 85k_to_45m].include?(calculator.annual_turnover)
      },
      large_business_loan_scheme: lambda { |calculator|
        %w[45m_to_500m 500m_and_over].include?(calculator.annual_turnover)
      },
      bounce_back_loan: lambda { |calculator|
        %w[under_85k 85k_to_45m].include?(calculator.annual_turnover)
      },
      future_fund: lambda { |calculator|
        calculator.annual_turnover == "pre_revenue"
      },
      kickstart_scheme: lambda { |calculator|
        calculator.business_based != "northern_ireland"
      },
    }.freeze

    def show?(result_id)
      RULES[result_id].call(self)
    end
  end
end
