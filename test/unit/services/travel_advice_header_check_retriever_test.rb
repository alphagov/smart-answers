require "test_helper"
require "support/foreign_travel_advice_helper"

class TravelAdviceHeaderCheckRetrieverTest < ActiveSupport::TestCase
  include ForeignTravelAdviceHelper

  setup do
    Rails.cache.clear
  end

  context ".fetch" do
    should "return true if the country has all the headers" do
      stub_foreign_travel_advice
      status = TravelAdviceHeaderCheckRetriever.fetch("spain")

      assert_equal true, status
    end

    should "return false if the country does not have all the headers" do
      stub_incomplete_foreign_travel_advice
      status = TravelAdviceHeaderCheckRetriever.fetch("spain")

      assert_equal false, status
    end
  end
end
