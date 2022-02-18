require "test_helper"

class TravelAdviceHeaderCheckRetrieverTest < ActiveSupport::TestCase
  setup do
    Rails.cache.clear
  end

  context ".fetch" do
    should "return true if the country has all the headers" do
      response = {
        details: {
          parts: [
            {
              body: "<h2 id=\"all-travellers\">Header</h2><p>Content</p>" \
                "<h2 id=\"if-youre-transiting-through-spain\">Header</h2><p>Content</p>" \
                "<h2 id=\"if-youre-not-fully-vaccinated\">Header</h2><p>Content</p>" \
                "<h2 id=\"if-youre-fully-vaccinated\">Header</h2><p>Content</p>" \
                "<h2 id=\"children-and-young-people\">Header</h2><p>Content</p>" \
                "<h2 id=\"exemptions\">Header</h2><p>Content</p>",
              slug: "entry-requirements",
            },
          ],
        },
      }.to_json

      travel_advice_header_check_request = stub_request(:get, "https://www.gov.uk/api/content/foreign-travel-advice/spain").with(
        headers: { "Content-Type" => "application/json" },
      ).to_return(status: 200, body: response)

      status = TravelAdviceHeaderCheckRetriever.fetch("spain")

      assert_requested travel_advice_header_check_request
      assert_equal true, status
    end

    should "return false if the country does not have all the headers" do
      response = {
        details: {
          parts: [
            {
              body: "<h2 id=\"all-travellers\">Header</h2><p>Content</p>" \
                "<h2 id=\"if-youre-transiting-through-spain\">Header</h2><p>Content</p>" \
                "<h2 id=\"children-and-young-people\">Header</h2><p>Content</p>" \
                "<h2 id=\"exemptions\">Header</h2><p>Content</p>",
              slug: "entry-requirements",
            },
          ],
        },
      }.to_json

      travel_advice_header_check_request = stub_request(:get, "https://www.gov.uk/api/content/foreign-travel-advice/spain").with(
        headers: { "Content-Type" => "application/json" },
      ).to_return(status: 200, body: response)

      status = TravelAdviceHeaderCheckRetriever.fetch("spain")

      assert_requested travel_advice_header_check_request
      assert_equal false, status
    end
  end
end
