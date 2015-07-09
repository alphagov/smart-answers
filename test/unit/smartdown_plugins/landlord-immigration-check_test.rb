require 'test_helper'
require 'smartdown_plugins/landlord-immigration-check/render_time'
require 'gds_api/test_helpers/imminence'

module SmartdownPlugins
  class LandlordImmigrationCheckTest < ActiveSupport::TestCase
    include GdsApi::TestHelpers::Imminence

    def stub_answer(value)
      OpenStruct.new(value: value)
    end

    setup do
      imminence_has_areas_for_postcode("WC2B%206SE", [])
      imminence_has_areas_for_postcode("B1%201EQ", [{ slug: "birmingham-city-council" }])
      imminence_has_areas_for_postcode("B62%200BG", [{ slug: "dudley-city-council" }])
      imminence_has_areas_for_postcode("B43%205AB", [{ slug: "sandwell-city-council" }])
      imminence_has_areas_for_postcode("WV1%201ES", [{ slug: "wolverhampton-city-council" }])
      imminence_has_areas_for_postcode("B43%207DG", [{ slug: "walsall-city-council" }, { slug: "london" }])
    end

    test "with an invalid postcode" do
      stub_request(:get, %r{\A#{Plek.current.find('imminence')}/areas/E15\.json}).
        to_return(body: { _response_info: { status: 404 }, total: 0, results: [] }.to_json)

      response = $imminence.areas_for_postcode("E15")

      assert_equal 404, response["_response_info"]["status"]
      assert_equal 0, response["total"]
      assert_empty response["results"]
    end

    test "with a valid postcode outside valid areas" do
      refute SmartdownPlugins::LandlordImmigrationCheck.valid_postcode(stub_answer("WC2B 6SE"))
    end

    test "with a valid postcode within the valid areas" do
      assert SmartdownPlugins::LandlordImmigrationCheck.valid_postcode(stub_answer("B1 1EQ"))
      assert SmartdownPlugins::LandlordImmigrationCheck.valid_postcode(stub_answer("B62 0BG"))
      assert SmartdownPlugins::LandlordImmigrationCheck.valid_postcode(stub_answer("B43 5AB"))
      assert SmartdownPlugins::LandlordImmigrationCheck.valid_postcode(stub_answer("WV1 1ES"))
      assert SmartdownPlugins::LandlordImmigrationCheck.valid_postcode(stub_answer("B43 7DG"))
    end
  end
end
