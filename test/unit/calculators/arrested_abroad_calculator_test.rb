require_relative "../../test_helper"

module SmartAnswer::Calculators
  class ArrestedAbroadCalculatorTest < ActiveSupport::TestCase
    context ArrestedAbroad do
      setup do
        @calc = ArrestedAbroad.new
      end

      context "countries with regions" do
        should "pull the regions out of the YML for Australia" do
          resp = @calc.get_country_regions("australia")["new_south_wales"]
          expected = {
            "link" => "http://ukinaustralia.fco.gov.uk/resources/en/pdf/consular/nsw-prisoner-pack12",
            "url_text" => "Prisoner Pack for New South Wales"
          }
          assert_equal expected, resp
        end

        should "pull out regions of the YML for UAE" do
          resp = @calc.get_country_regions("united-arab-emirates")
          assert resp["abu_dhabi"]
          assert resp["dubai_north"]
          assert resp["police_info"]
          assert resp["addition"]
        end
      end
    end
  end
end
