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

    def divorced?
      marital_status == 'divorced'
    end

    def married?
      marital_status == 'married'
    end

    def widowed?
      marital_status == 'widowed'
    end

  private

    def rates
      @rates ||= RatesQuery.from_file('state_pension').rates
    end
  end
end
