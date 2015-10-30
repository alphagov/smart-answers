require_relative '../../test_helper'
require 'gds_api/test_helpers/imminence'

module SmartAnswer::Calculators
  class LandlordImmigrationCheckCalculatorTest < ActiveSupport::TestCase
    include GdsApi::TestHelpers::Imminence

    setup do
      imminence_has_areas_for_postcode("WC2B%206SE", [])
      imminence_has_areas_for_postcode("B1%201EQ", [{ slug: "birmingham-city-council" }])
      imminence_has_areas_for_postcode("B62%200BG", [{ slug: "dudley-city-council" }])
      imminence_has_areas_for_postcode("B43%205AB", [{ slug: "sandwell-city-council" }])
      imminence_has_areas_for_postcode("WV1%201ES", [{ slug: "wolverhampton-city-council" }])
      imminence_has_areas_for_postcode("B43%207DG", [{ slug: "walsall-city-council" }, { slug: "london" }])
    end

    test "with an invalid postcode" do
      stub_request(:get, %r{\A#{Plek.new.find('imminence')}/areas/E15\.json}).
        to_return(body: { _response_info: { status: 404 }, total: 0, results: [] }.to_json)

      response = Services.imminence_api.areas_for_postcode("E15")

      assert_equal 404, response["_response_info"]["status"]
      assert_equal 0, response["total"]
      assert_empty response["results"]
    end

    test "with a valid postcode outside valid areas" do
      refute LandlordImmigrationCheckCalculator.valid_postcode("WC2B 6SE")
    end

    test "with a valid postcode within the valid areas" do
      assert LandlordImmigrationCheckCalculator.valid_postcode("B1 1EQ")
      assert LandlordImmigrationCheckCalculator.valid_postcode("B62 0BG")
      assert LandlordImmigrationCheckCalculator.valid_postcode("B43 5AB")
      assert LandlordImmigrationCheckCalculator.valid_postcode("WV1 1ES")
      assert LandlordImmigrationCheckCalculator.valid_postcode("B43 7DG")
    end
  end
end
