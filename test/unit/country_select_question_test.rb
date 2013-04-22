require_relative "../test_helper"

module SmartAnswer
  class CountrySelectQuestionTest < ActiveSupport::TestCase
    def setup
      @question = Question::CountrySelect.new(:example, :use_legacy_data => true)
    end

    test "Can list options" do
      assert @question.options.include?(LegacyCountry.new(slug: "azerbaijan", name: "Azerbaijan"))
      assert @question.options.include?(LegacyCountry.new(slug: "greece", name: "Greece"))
    end

    test "Can validate a provided option" do
      assert @question.valid_option?("azerbaijan")
      assert @question.valid_option?("greece")
    end
  end
end
