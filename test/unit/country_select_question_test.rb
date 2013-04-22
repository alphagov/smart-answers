require_relative "../test_helper"

module SmartAnswer
  class CountrySelectQuestionTest < ActiveSupport::TestCase
    context "using the worldwide API data" do
      setup do
        location1 = stub(:slug => 'afghanistan', :name => 'Afghanistan')
        location2 = stub(:slug => 'denmark', :name => 'Denmark')
        location3 = stub(:slug => 'united-kingdom', :name => 'United Kingdom')
        location4 = stub(:slug => 'vietnam', :name => 'Vietnam')
        WorldLocation.stubs(:all).returns([location1, location2, location3, location4])
      end

      should "be able to list options" do
        @question = Question::CountrySelect.new(:example)
        assert_equal %w(afghanistan denmark vietnam), @question.options.map(&:slug)
      end

      should "validate a provided option" do
        @question = Question::CountrySelect.new(:example)
        assert @question.valid_option?("afghanistan")
        assert @question.valid_option?("vietnam")
        assert ! @question.valid_option?("fooey")
        assert ! @question.valid_option?("united-kingdom")
      end

      should "include UK when requested" do
        @question = Question::CountrySelect.new(:example, :include_uk => true)
        assert_equal %w(afghanistan denmark united-kingdom vietnam), @question.options.map(&:slug)
        assert @question.valid_option?('united-kingdom')
      end
    end

    context "using the legacy data" do
      setup do
        @question = Question::CountrySelect.new(:example, :use_legacy_data => true)
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
