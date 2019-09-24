require_relative "../test_helper"

module SmartAnswer
  class CountrySelectQuestionTest < ActiveSupport::TestCase
    context "using the worldwide API data" do
      setup do
        location1 = stub(slug: "afghanistan", name: "Afghanistan")
        location2 = stub(slug: "british-antarctic-territory", name: "British Antartic Territory")
        location3 = stub(slug: "denmark", name: "Denmark")
        location4 = stub(slug: "the-gambia", name: "The Gambia")
        location5 = stub(slug: "holy-see", name: "Holy See")
        location6 = stub(slug: "united-kingdom", name: "United Kingdom")
        location7 = stub(slug: "vietnam", name: "Vietnam")
        location8 = stub(slug: "greenland", name: "Greenland")
        WorldLocation.stubs(:all).returns([location1, location2, location3, location4, location5, location6, location7])
        UkbaCountry.stubs(:all).returns([location8])
      end

      should "be able to list options" do
        @question = Question::CountrySelect.new(nil, :example)
        assert_equal %w(afghanistan british-antarctic-territory denmark the-gambia holy-see vietnam), @question.options.map(&:slug)
      end

      should "validate a provided option" do
        @question = Question::CountrySelect.new(nil, :example)
        assert @question.valid_option?("afghanistan")
        assert @question.valid_option?("vietnam")
        assert ! @question.valid_option?("fooey")
        assert ! @question.valid_option?("united-kingdom")
      end

      should "include UK when requested" do
        @question = Question::CountrySelect.new(nil, :example, include_uk: true)
        assert_equal %w(afghanistan british-antarctic-territory denmark the-gambia holy-see united-kingdom vietnam), @question.options.map(&:slug)
        assert @question.valid_option?("united-kingdom")
      end

      should "exclude Holy See and British Antartic Territory when requested" do
        @question = Question::CountrySelect.new(nil, :example, exclude_countries: %w(holy-see british-antarctic-territory))
        assert_equal %w(afghanistan denmark the-gambia vietnam), @question.options.map(&:slug)
        assert ! @question.valid_option?("holy-see")
        assert ! @question.valid_option?("british-antarctic-territory")
      end

      context "when including additional countries" do
        should "include additional countries" do
          @question = Question::CountrySelect.new(nil, :example, exclude_countries: %w(afghanistan british-antarctic-territory the-gambia denmark holy-see vietnam), additional_countries: UkbaCountry.all)
          assert_equal %w(greenland), @question.options.map(&:slug)
          assert ! @question.valid_option?("fooey")
          assert ! @question.valid_option?("united-kingdom")
        end

        should "ignore the definite article when alphabetising country names" do
          @question = Question::CountrySelect.new(nil, :example, additional_countries: UkbaCountry.all)
          assert_equal %w(afghanistan british-antarctic-territory denmark the-gambia greenland holy-see vietnam), @question.options.map(&:slug)
        end
      end
    end
  end
end
