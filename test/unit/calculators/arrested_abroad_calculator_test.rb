require_relative "../../test_helper"

module SmartAnswer::Calculators
  class ArrestedAbroadCalculatorTest < ActiveSupport::TestCase
    context ArrestedAbroad do
      setup do
        @calc = ArrestedAbroad.new
      end

      context "generating a URL" do
        should "not error if the country doesn't exist" do
          assert_nothing_raised do
            @calc.generate_url_for_download("doesntexist", "pdf", "hello world")
          end
        end

        should "generate link if country exists" do
          link = @calc.generate_url_for_download("argentina", "pdf", "Prisoner pack")
          assert_equal "- [Prisoner pack](/government/publications/argentina-prisoner-pack)", link
        end

        should "add external tag if URL contains http" do
          link = @calc.generate_url_for_download("kuwait", "doc", "Foo")
          assert link.include?("{:rel=\"external\"}")
        end

        should "not include external tag if URL is internal" do
          link = @calc.generate_url_for_download("israel", "pdf", "Foo")
          assert !link.include?("{:rel=\"external\"}")
        end
      end



      context "countries with regions" do
        should "pull the regions out of the YML for Australia" do
          resp = @calc.get_country_regions("australia")["new_south_wales"]
          expected = {
            "link" => "/government/publications/australia-prisoner-pack",
            "url_text" => "Prisoner pack for New South Wales"
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
