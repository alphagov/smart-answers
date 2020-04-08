module SmartAnswer::Calculators
  class CoronavirusBusinessSupportCalculator
    include ActiveModel::Model

    attr_accessor :business_based
    attr_accessor :business_size
    attr_accessor :self_employed
    attr_accessor :annual_turnover
    attr_accessor :business_rates
    attr_accessor :non_domestic_property
    attr_accessor :self_assessment_july_2020
    attr_accessor :sectors

    def initialize(attributes = {})
      super
    end
  end
end
