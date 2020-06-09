require_relative "../test_helper"

module SmartAnswer
  class QuestionWithOptionsPresenterTest < ActiveSupport::TestCase
    setup do
      @renderer = stub("renderer")
    end

    test "#all_options returns options with labels and values" do
      question = Question::MultipleChoice.new(nil, :question_name?)
      question.option(:option_one)
      question.option(:option_two)

      @renderer.stubs(:option_text).with(:option_one).returns("option-one-text")
      @renderer.stubs(:option_text).with(:option_two).returns("option-two-text")
      presenter = QuestionWithOptionsPresenter.new(question, nil, renderer: @renderer)

      assert_equal(%w[option_one option_two], presenter.options.map { |o| o[:value] })
      assert_equal(%w[option-one-text option-two-text], presenter.options.map { |o| o[:label] })
    end

    test "#option_attributes returns a hash of labels and values" do
      question = Question::MultipleChoice.new(nil, :question_name?)
      question.option(:option_one)

      @renderer.stubs(:option_text).with(:option_one).returns("option-one-text")
      presenter = QuestionWithOptionsPresenter.new(question, nil, renderer: @renderer)

      assert_equal({ label: "option-one-text", value: "option_one" }, presenter.option_attributes("option_one"))
    end
  end
end
