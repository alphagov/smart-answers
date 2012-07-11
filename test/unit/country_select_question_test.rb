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
      assert_equal({slug: "antigua-and-barbuda", name: "Antigua and Barbuda"}, @question.to_response("antigua-and-barbuda"))
      assert_equal({slug: "belgium", name: "Belgium"}, @question.to_response("belgium"))
    end
  end
end
