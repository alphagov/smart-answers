module SmartAnswer::Calculators
  class BusinessCoronavirusSupportFinderCalculator
    attr_accessor :business_based,
                  :business_size,
                  :paye_scheme,
                  :self_employed,
                  :non_domestic_property,
                  :sectors,
                  :closed_by_restrictions

    def initialize
      @closed_by_restrictions = []
      @sectors = []
    end

    RULES = {
      statutory_sick_rebate: lambda { |calculator|
        calculator.business_size == "0_to_249" &&
          calculator.paye_scheme == "yes"
      },
      self_employed_income_scheme: lambda { |calculator|
        calculator.self_employed == "yes"
      },
      retail_hospitality_leisure_business_rates: lambda { |calculator|
        calculator.business_based == "england" &&
          calculator.non_domestic_property != "no" &&
          calculator.sectors.include?("retail_hospitality_or_leisure")
      },
      omicron_hospitality_and_leisure_grant: lambda { |calculator|
        calculator.business_based == "england" &&
          calculator.sectors.include?("retail_hospitality_or_leisure")
      },
      nursery_support: lambda { |calculator|
        calculator.business_based == "england" &&
          calculator.non_domestic_property != "no" &&
          calculator.sectors.include?("nurseries")
      },
      kickstart_scheme: lambda { |calculator|
        calculator.business_based != "northern_ireland"
      },
      vat_reduction: lambda { |calculator|
        calculator.sectors.include?("retail_hospitality_or_leisure")
      },
      traineeships: lambda { |calculator|
        calculator.business_based == "england"
      },
      apprenticeships: lambda { |calculator|
        calculator.business_based == "england"
      },
      tlevels: lambda { |calculator|
        calculator.business_based == "england"
      },
      additional_restrictions_grant: lambda { |calculator|
        calculator.business_based == "england"
      },
      council_grants: lambda { |calculator|
        council_grant_questions = %i[additional_restrictions_grant
                                     retail_hospitality_leisure_business_rates
                                     nursery_support]

        council_grant_questions.any? { |q| calculator.show?(q) }
      },
    }.freeze

    def show?(result_id)
      RULES[result_id].call(self)
    end
  end
end
