require_relative "../test_helper"
require "support/foreign_travel_advice_helper"

class TravelAdviceHeaderCheckerTest < ActiveSupport::TestCase
  include ForeignTravelAdviceHelper

  context "#has_all_content_headers?" do
    setup do
      @header_checker = TravelAdviceHeaderChecker.new("spain")
    end

    should "return true when country has all of the required headers" do
      stub_foreign_travel_advice

      assert_equal true, @header_checker.has_content_headers?
    end

    should "return false when country does not have all of the required headers" do
      stub_incomplete_foreign_travel_advice

      assert_equal false, @header_checker.has_content_headers?
    end

    should "handle JSON::ParserError errors" do
      stub_unparsable_json_foreign_travel_advice

      assert_equal false, @header_checker.has_content_headers?
    end

    should "handle connection timeouts" do
      stub_server_timeout_foreign_travel_advice

      assert_equal false, @header_checker.has_content_headers?
    end
  end
end
