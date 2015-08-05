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

        should "not include external tag if URL is internal" do
          link = @calc.generate_url_for_download("israel", "pdf", "Foo")
          assert !link.include?("{:rel=\"external\"}")
        end
      end

      context "countries with regions" do
        should "pull out regions of the YML for Cyprus" do
          resp = @calc.get_country_regions("cyprus")
          assert resp["north"]
          assert resp["north_lawyer"]
          assert resp["republic"]
          assert resp["republic_lawyers"]
        end

        should "pull the regions out of the YML for Cyprus" do
          resp = @calc.get_country_regions("cyprus")["north"]
          expected = {
            "link" => "/government/publications/cyprus-north-prisoner-pack",
            "url_text" => "Prisoner pack for the north of Cyprus"
          }
          assert_equal expected, resp
        end
      end
    end
  end
end
