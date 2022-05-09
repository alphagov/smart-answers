require_relative "../../test_helper"

module SmartAnswer::Calculators
  class ArrestedAbroadCalculatorTest < ActiveSupport::TestCase
    context ArrestedAbroad do
      context "generating a URL" do
        should "not error if the country doesn't exist" do
          assert_nothing_raised do
            calc = ArrestedAbroad.new("doesntexist")
            calc.generate_url_for_download("pdf", "hello world")
          end
        end

        should "generate link if country exists" do
          calc = ArrestedAbroad.new("argentina")
          link = calc.generate_url_for_download("pdf", "Prisoner pack")
          assert_equal "- [Prisoner pack](/government/publications/argentina-prisoner-pack)", link
        end

        should "not include external tag if URL is internal" do
          calc = ArrestedAbroad.new("israel")
          link = calc.generate_url_for_download("pdf", "Foo")
          assert_not link.include?("{:rel=\"external\"}")
        end
      end

      context "has extra downloads" do
        should "return true for countries with regions" do
          calc = ArrestedAbroad.new("cyprus")
          calc.stubs(:country_name).returns("Cyprus")
          assert calc.has_extra_downloads
        end

        should "return false if not a country with regions nor has extra download links" do
          calc = ArrestedAbroad.new("bermuda")
          calc.stubs(:country_name).returns("Bermuda")
          assert_not calc.has_extra_downloads
        end

        should "return true if country has extra download links" do
          calc = ArrestedAbroad.new("australia")
          calc.stubs(:country_name).returns("Australia")
          assert calc.has_extra_downloads
        end
      end
    end
  end
end
