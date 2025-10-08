require_relative "../test_helper"

module SmartAnswer
  class PensionTest < ActiveSupport::TestCase
    setup do
      stub_request(:get, "https://publishing-api.test.gov.uk/v2/content?document_type=content_block_pension&per_page=500")
        .to_return(status: 200, body: {
          "results" => [
            {
              "details" => {
                "rates" => {
                  "full-basic-state-pension-amount" => {
                    "title" => "Full basic state pension amount",
                    "amount" => "£121.34",
                  },
                  "lower-basic-state-pension-amount" => {
                    "title" => "Lower basic state pension amount",
                    "amount" => "£105.22",
                  },
                },
              },
              "content_id_aliases" => [
                {
                  "name" => "basic-state-pension",
                },
              ],
            },
            {
              "details" => {},
              "content_id_aliases" => [
                {
                  "name" => "pension-without-rates",
                },
              ],
            },
          ],
        }.to_json)
    end

    test ".all returns all pensions" do
      result = Pension.all

      assert_equal 2, result.size

      assert_equal "basic-state-pension", result[0].slug

      assert_equal 2, result[0].rates.size

      assert_equal "full-basic-state-pension-amount", result[0].rates[0].slug
      assert_equal "Full basic state pension amount", result[0].rates[0].title
      assert_equal "£121.34", result[0].rates[0].amount

      assert_equal "lower-basic-state-pension-amount", result[0].rates[1].slug
      assert_equal "Lower basic state pension amount", result[0].rates[1].title
      assert_equal "£105.22", result[0].rates[1].amount

      assert_equal "pension-without-rates", result[1].slug

      assert_equal 0, result[1].rates.size
    end

    test ".find returns a pension" do
      result = Pension.find("basic-state-pension")

      assert_equal "basic-state-pension", result.slug

      assert_equal 2, result.rates.size

      assert_equal "full-basic-state-pension-amount", result.rates[0].slug
      assert_equal "Full basic state pension amount", result.rates[0].title
      assert_equal "£121.34", result.rates[0].amount

      assert_equal "lower-basic-state-pension-amount", result.rates[1].slug
      assert_equal "Lower basic state pension amount", result.rates[1].title
      assert_equal "£105.22", result.rates[1].amount
    end
  end
end
