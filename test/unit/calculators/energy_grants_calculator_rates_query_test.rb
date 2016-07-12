require_relative "../../test_helper"

module SmartAnswer::Calculators
  class EnergyGrantsCalculatorRatesQueryTest < ActiveSupport::TestCase
    setup do
      @rates = RatesQuery.from_file('energy_grants_calculator')
    end

    context 'for 2016/17' do
      should 'be 5th May 1953 for winter fuel payments threshold' do
        energy_grants_rates = @rates.rates(Date.parse('2016-09-30'))
        expected_date = Date.parse('1953-05-05')
        assert_equal expected_date, energy_grants_rates.winter_fuel_payment_threshold
      end
    end
  end
end
