require_relative "../../test_helper"

module SmartAnswer::Calculators
  class RegisterADeathRatesQueryTest < ActiveSupport::TestCase
    setup do
      @rates_query = RatesQuery.from_file('register_a_death')
    end

    context 'for 2015/16' do
      setup do
        @rates = @rates_query.rates(Date.parse('2015-04-06'))
      end

      should 'be £105 for registering a death' do
        assert_equal 105, @rates.register_a_death
      end

      should 'be £65 for a copy of the death registration certificate' do
        assert_equal 65, @rates.copy_of_death_registration_certificate
      end
    end

    context 'for 2016/17' do
      setup do
        @rates = @rates_query.rates(Date.parse('2016-04-06'))
      end

      should 'be £150 for registering a death' do
        assert_equal 150, @rates.register_a_death
      end

      should 'be £50 for a copy of the death registration certificate' do
        assert_equal 50, @rates.copy_of_death_registration_certificate
      end
    end
  end
end
