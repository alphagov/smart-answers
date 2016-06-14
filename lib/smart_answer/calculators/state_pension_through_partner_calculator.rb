module SmartAnswer::Calculators
  class StatePensionThroughPartnerCalculator
    include ActiveModel::Model

    attr_accessor :marital_status

    def lower_basic_state_pension_rate
      RatesQuery.from_file('state_pension').rates.lower_weekly_rate
    end
  end
end
