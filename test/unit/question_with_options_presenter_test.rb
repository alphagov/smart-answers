require_relative "../test_helper"

module SmartAnswer
  class QuestionWithOptionsPresenterTest < ActiveSupport::TestCase
    setup do
      question = Question::MultipleChoice.new(nil, :question_name?)
      question.option(:option_one)
      question.option(:option_two)

      renderer = stub("renderer")

      renderer.stubs(:option).with(:option_one).returns("option-one-text")
      renderer.stubs(:option).with(:option_two).returns({ label: "option-two-text", hint_text: "option-two-hint" })
      @presenter = QuestionWithOptionsPresenter.new(question, nil, nil, renderer: renderer)
    end

    test "#all_options returns options with labels and values" do
      assert_equal(%w[option_one option_two], @presenter.options.map { |o| o[:value] })
      assert_equal(%w[option-one-text option-two-text], @presenter.options.map { |o| o[:label] })
    end

    test "#option_attributes returns a hash when option attribute is a string from the renderer" do
      assert_equal({ label: "option-one-text", value: "option_one" }, @presenter.option_attributes("option_one"))
    end

    test "#option_attributes returns a hash when option attribute is a hash from the renderer" do
      assert_equal({ label: "option-two-text", value: "option_two", hint_text: "option-two-hint" }, @presenter.option_attributes("option_two"))
    end
  end
end
