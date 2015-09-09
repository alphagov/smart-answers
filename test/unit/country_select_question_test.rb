require_relative "../test_helper"

module SmartAnswer
  class CountrySelectQuestionTest < ActiveSupport::TestCase
    context "using the worldwide API data" do
      setup do
        location1 = stub(slug: 'afghanistan', name: 'Afghanistan')
 location2 = stub(slug: 'denmark', name: 'Denmark')
 location3 = stub(slug: 'united-kingdom', name: 'United Kingdom')
 location4 = stub(slug: 'vietnam', name: 'Vietnam')
 location5 = stub(slug: 'holy-see', name: 'Holy See')
 location6 = stub(slug: 'british-antarctic-territory', name: 'British Antartic Territory')
 location7 = stub(slug: 'greenland', name: 'Greenland')
        WorldLocation.stubs(:all).returns([location1, location2, location3, location4, location5, location6])
        UkbaCountry.stubs(:all).returns([location7])
      end

      should "be able to list options" do
        @question = Question::CountrySelect.new(nil, :example)
        assert_equal %w(afghanistan denmark vietnam holy-see british-antarctic-territory), @question.options.map(&:slug)
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
        assert_equal %w(afghanistan denmark united-kingdom vietnam holy-see british-antarctic-territory), @question.options.map(&:slug)
        assert @question.valid_option?('united-kingdom')
      end

      should "exclude Holy See and British Antartic Territory when requested" do
        @question = Question::CountrySelect.new(nil, :example, exclude_countries: %w(holy-see british-antarctic-territory))
        assert_equal %w(afghanistan denmark vietnam), @question.options.map(&:slug)
        assert ! @question.valid_option?('holy-see')
        assert ! @question.valid_option?('british-antarctic-territory')
      end

      should "include additional countries" do
        @question = Question::CountrySelect.new(nil, :example, exclude_countries: %w(afghanistan british-antarctic-territory denmark holy-see vietnam), additional_countries: UkbaCountry.all)
        assert_equal %w(greenland), @question.options.map(&:slug)
        assert ! @question.valid_option?("fooey")
        assert ! @question.valid_option?("united-kingdom")
      end
    end

    context "using the legacy data" do
      setup do
        @question = Question::CountrySelect.new(nil, :example, use_legacy_data: true)
      end

      should "be able to list options" do
        assert @question.options.include?(LegacyCountry.new(slug: "azerbaijan", name: "Azerbaijan"))
        assert @question.options.include?(LegacyCountry.new(slug: "greece", name: "Greece"))
      end

      should "validate a provided option" do
        assert @question.valid_option?("azerbaijan")
        assert @question.valid_option?("greece")
        assert ! @question.valid_option?("fooey")
      end
    end
  end
end
