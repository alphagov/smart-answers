require_relative "../test_helper"

module SmartAnswer
  class CountrySelectQuestionTest < ActiveSupport::TestCase
    def setup
      @question = Question::CountrySelect.new(:example)
    end

    test "Can list options" do
      assert @question.options.include?({slug: "azerbaijan", name: "Azerbaijan"})
      assert @question.options.include?({slug: "greece", name: "Greece"})
    end

    test "Can validate a provided option" do
      assert @question.valid_option?("azerbaijan")
      assert @question.valid_option?("greece")
    end

    test "Can convert key to pretty name" do
      assert_equal(@question.to_response(7), {slug: "antigua-and-barbuda", name: "Antigua and Barbuda"})
      assert_equal(@question.to_response(20), {slug: "belgium", name: "Belgium"})
    end
  end
end