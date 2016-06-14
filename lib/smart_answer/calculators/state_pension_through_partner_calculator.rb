module SmartAnswer::Calculators
  class StatePensionThroughPartnerCalculator
    include ActiveModel::Model

    attr_accessor :marital_status

    def lower_basic_state_pension_rate
      rates.lower_weekly_rate
    end

    def higher_basic_state_pension_rate
      rates.weekly_rate
    end

  private

    def rates
      @rates ||= RatesQuery.from_file('state_pension').rates
    end
  end
end
