require_relative '../../test_helper'
require 'gds_api/test_helpers/imminence'

module SmartAnswer::Calculators
  class LandlordImmigrationCheckCalculatorTest < ActiveSupport::TestCase
    include GdsApi::TestHelpers::Imminence

    setup do
      # Excluded countries
      imminence_has_areas_for_postcode("PA3%202SW",   [{ slug: 'renfrewshire-council', country_name: 'Scotland' }])
      imminence_has_areas_for_postcode("SA2%207JU",   [{ slug: 'swansea-council', country_name: 'Wales' }])
      imminence_has_areas_for_postcode("BT29%204AB",  [{ slug: 'antrim-south-east', country_name: 'Northern Ireland' }])

      # Included country
      imminence_has_areas_for_postcode("RH6%200NP",   [{ slug: 'crawley-borough-council', country_name: 'England' }])
    end

    test "with an invalid postcode" do
      stub_request(:get, %r{\A#{Plek.new.find('imminence')}/areas/E15\.json}).
        to_return(body: { _response_info: { status: 404 }, total: 0, results: [] }.to_json)

      response = Services.imminence_api.areas_for_postcode("E15")

      assert_equal 404, response["_response_info"]["status"]
      assert_equal 0, response["total"]
      assert_empty response["results"]
    end

    test "with a valid postcode in Scotland" do
      calculator = LandlordImmigrationCheckCalculator.new("PA3 2SW")

      refute calculator.included_country?
    end

    test "with a valid postcode in Wales" do
      calculator = LandlordImmigrationCheckCalculator.new("SA2 7JU")

      refute calculator.included_country?
    end

    test "with a valid postcode in Northern Ireland" do
      calculator = LandlordImmigrationCheckCalculator.new("BT29 4AB")

      refute calculator.included_country?
    end

    test "with a valid postcode in England" do
      calculator = LandlordImmigrationCheckCalculator.new("RH6 0NP")

      assert calculator.included_country?
    end
  end
end
