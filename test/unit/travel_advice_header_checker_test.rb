require_relative "../test_helper"

class TravelAdviceHeaderCheckerTest < ActiveSupport::TestCase
  context "#has_all_content_headers?" do
    setup do
      @header_checker = TravelAdviceHeaderChecker.new("spain")
    end

    should "return true when country has all of the required headers" do
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

      stub_request(:get, "https://www.gov.uk/api/content/foreign-travel-advice/spain").with(
        headers: { "Content-Type" => "application/json" },
      ).to_return(status: 200, body: response)

      assert_equal true, @header_checker.has_content_headers?
    end

    should "return false when country does not have all of the required headers" do
      response = {
        details: {
          parts: [
            {
              body: "<h2 id=\"all-travellers\">Header</h2><p>Content</p>" \
                "<h2 id=\"if-youre-transiting-through-spain\">Header</h2><p>Content</p>" \
                "<h2 id=\"children-and-young-people\">Header</h2><p>Content</p>",
              slug: "entry-requirements",
            },
          ],
        },
      }.to_json

      stub_request(:get, "https://www.gov.uk/api/content/foreign-travel-advice/spain").with(
        headers: { "Content-Type" => "application/json" },
      ).to_return(status: 200, body: response)

      assert_equal false, @header_checker.has_content_headers?
    end

    should "handle JSON::ParserError errors" do
      stub_request(:get, "https://www.gov.uk/api/content/foreign-travel-advice/spain").with(
        headers: { "Content-Type" => "application/json" },
      ).to_return(status: 200, body: "")

      assert_equal false, @header_checker.has_content_headers?
    end

    should "handle connection timeouts" do
      stub_request(:get, "https://www.gov.uk/api/content/foreign-travel-advice/spain").with(
        headers: { "Content-Type" => "application/json" },
      ).to_timeout

      assert_equal false, @header_checker.has_content_headers?
    end
  end
end
