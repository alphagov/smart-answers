require_relative '../../test_helper'
require 'gds_api/test_helpers/imminence'

module SmartAnswer::Calculators
  class LandlordImmigrationCheckCalculatorTest < ActiveSupport::TestCase
    include GdsApi::TestHelpers::Imminence

    setup do
      @calculator = LandlordImmigrationCheckCalculator.new
    end

    context 'when postcode is in England' do
      setup do
        imminence_has_areas_for_postcode("RH6 0NP", [{ slug: 'crawley-borough-council', country_name: 'England' }])
        @calculator.postcode = "RH6 0NP"
      end

      should 'determine that the rules do not apply' do
        assert @calculator.rules_apply?
      end
    end

    context 'when postcode is outside England' do
      setup do
        imminence_has_areas_for_postcode("PA3 2SW", [{ slug: 'renfrewshire-council', country_name: 'Scotland' }])
        @calculator.postcode = "PA3 2SW"
      end

      should 'determine that the rules do not apply' do
        refute @calculator.rules_apply?
      end
    end

    context 'when postcode has multiple areas all in England' do
      setup do
        imminence_has_areas_for_postcode("RH6 0NP", [
          { slug: 'crawley-borough-council', country_name: 'England' },
          { slug: 'west-sussex-county-council', country_name: 'England' },
        ])
        @calculator.postcode = "RH6 0NP"
      end

      should 'return single country for postcode' do
        assert_equal ['England'], @calculator.countries_for_postcode
      end

      should 'determine that the rules do apply' do
        assert @calculator.rules_apply?
      end
    end

    context 'when postcode has multiple areas some in England and some not' do
      setup do
        imminence_has_areas_for_postcode("XY1 0AB", [
          { slug: 'xy-borough-council', country_name: 'England' },
          { slug: 'xy-county-council', country_name: 'Scotland' },
        ])
        @calculator.postcode = "XY1 0AB"
      end

      should 'return all countries for postcode' do
        assert_equal %w(England Scotland), @calculator.countries_for_postcode
      end

      should 'determine that the rules do apply' do
        assert @calculator.rules_apply?
      end
    end

    context 'when postcode is unknown' do
      setup do
        imminence_has_areas_for_postcode("E15", [])
        @calculator.postcode = "E15"
      end

      should 'return no areas for postcode' do
        assert_equal [], @calculator.areas_for_postcode
      end

      should 'determine that the rules do not apply' do
        refute @calculator.rules_apply?
      end
    end
  end
end
