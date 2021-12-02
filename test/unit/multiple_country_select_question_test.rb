require_relative "../test_helper"

module SmartAnswer
  class MultipleCountrySelectQuestionTest < ActiveSupport::TestCase
    setup do
      @question = Question::MultipleCountrySelect.new(nil, :example)
    end

    context "select_count" do
      should "initialize select_count to 1" do
        assert_equal 1, @question.select_count
      end
    end

    context "options" do
      setup do
        stub_worldwide_api_has_locations(%w[afghanistan british-antarctic-territory denmark the-gambia holy-see united-kingdom vietnam])
      end

      should "be able to list options" do
        assert_equal %w[afghanistan british-antarctic-territory denmark the-gambia holy-see united-kingdom vietnam], @question.options.map(&:slug)
      end
    end

    context "parse_input" do
      should "return blank when the raw input is nil" do
        assert_equal(nil, @question.parse_input(nil))
      end

      should "return blank when the raw input is an empty string" do
        assert_equal("", @question.parse_input(""))
      end

      # TODO: when the serializing approach has settled down - write more useful tests!
    end
  end
end
