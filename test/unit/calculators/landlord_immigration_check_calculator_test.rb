require_relative '../../test_helper'
require 'gds_api/test_helpers/imminence'

module SmartAnswer::Calculators
  class LandlordImmigrationCheckCalculatorTest < ActiveSupport::TestCase
    include GdsApi::TestHelpers::Imminence

    setup do
      @calculator = LandlordImmigrationCheckCalculator.new
    end

    context 'when postcode is unknown' do
      setup do
        stub_request(:get, %r{\A#{Plek.new.find('imminence')}/areas/E15\.json}).
          to_return(body: { _response_info: { status: 404 }, total: 0, results: [] }.to_json)
        @calculator.postcode = "E15"
      end

      should 'return no areas for postcode' do
        assert_equal [], @calculator.areas_for_postcode
      end

      should 'determine that the rules do not apply' do
        refute @calculator.rules_apply?
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

    context 'when postcode is in England' do
      setup do
        imminence_has_areas_for_postcode("RH6 0NP", [{ slug: 'crawley-borough-council', country_name: 'England' }])
        @calculator.postcode = "RH6 0NP"
      end

      should 'determine that the rules do not apply' do
        assert @calculator.rules_apply?
      end
    end
  end
end
