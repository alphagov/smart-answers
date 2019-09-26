require_relative "../../test_helper"
require "gds_api/test_helpers/imminence"

module SmartAnswer::Calculators
  class LandlordImmigrationCheckCalculatorTest < ActiveSupport::TestCase
    include GdsApi::TestHelpers::Imminence

    setup do
      @calculator = LandlordImmigrationCheckCalculator.new
    end

    context "when postcode is in England" do
      setup do
        imminence_has_areas_for_postcode("RH6 0NP", [{ type: "EUR", name: "South East", country_name: "England" }])
        @calculator.postcode = "RH6 0NP"
      end

      should "determine that the rules do not apply" do
        assert @calculator.rules_apply?
      end
    end

    context "when postcode is outside England" do
      setup do
        imminence_has_areas_for_postcode("PA3 2SW", [{ type: "EUR", name: "Scotland", country_name: "Scotland" }])
        @calculator.postcode = "PA3 2SW"
      end

      should "determine that the rules do not apply" do
        refute @calculator.rules_apply?
      end
    end

    context "when postcode has multiple areas all in England" do
      setup do
        imminence_has_areas_for_postcode("RH6 0NP", [
          { type: "EUR", name: "South East", country_name: "England" },
          { type: "DIS", name: "Crawley Borough Council", country_name: "England" },
        ])
        @calculator.postcode = "RH6 0NP"
      end

      should "return single country for postcode" do
        assert_equal %w[England], @calculator.countries_for_postcode
      end

      should "determine that the rules do apply" do
        assert @calculator.rules_apply?
      end
    end

    context "when postcode has multiple areas some in England and some not" do
      setup do
        imminence_has_areas_for_postcode("XY1 0AB", [
          { type: "CTY", name: "Cumbria County Council", country_name: "England" },
          { type: "SPC", name: "Dumfriesshire", country_name: "Scotland" },
        ])
        @calculator.postcode = "XY1 0AB"
      end

      should "return all countries for postcode" do
        assert_equal %w(England Scotland), @calculator.countries_for_postcode
      end

      should "determine that the rules do apply" do
        assert @calculator.rules_apply?
      end
    end

    context "when postcode is unknown" do
      setup do
        @calculator.postcode = "E15"

        stub_request(
          :get,
          %r{\A#{GdsApi::TestHelpers::Imminence::IMMINENCE_API_ENDPOINT}/areas/#{@calculator.postcode}\.json},
        ).to_return(
          body: {
            "_response_info" => { "status" => 404, "links" => [] },
            "results" => [],
          }.to_json,
        )
      end

      should "raise an exception" do
        assert_raises SmartAnswer::BaseStateTransitionError do
          @calculator.areas_for_postcode
        end
      end
    end

    should "return true when nationality is from somewhere else" do
      @calculator.nationality = "somewhere-else"

      assert @calculator.from_somewhere_else?
    end

    should "return false when nationality is from somewhere else" do
      @calculator.nationality = "non-eea"

      refute @calculator.from_somewhere_else?
    end

    context "when Imminence responds with an error" do
      setup do
        @calculator.postcode = "RH6 0NP"
        stub_request(
          :get, "#{Plek.new.find('imminence')}/areas/#{@calculator.postcode}.json"
        ).to_return(status: 500)
      end

      should "raise an error" do
        assert_raises GdsApi::HTTPServerError do
          @calculator.rules_apply?
        end
      end
    end

    context 'when Imminence responds with a not "ok" status' do
      setup do
        @calculator.postcode = "RH6 0NP"
        stub_request(
          :get, "#{Plek.new.find('imminence')}/areas/#{@calculator.postcode}.json"
        ).to_return(
          status: 200,
          body: {
            _response_info: {
              status: 400,
              links: [],
            },
            total: 0,
            start_index: 1,
            page_size: 0,
            current_page: 1,
            pages: 1,
            results: [],
          }.to_json,
        )
      end

      should "raise an error" do
        assert_raises SmartAnswer::LoggedError do
          @calculator.rules_apply?
        end
      end
    end
  end
end
