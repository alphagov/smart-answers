require_relative "../test_helper"

module SmartAnswer
  class QuestionWithOptionsPresenterTest < ActiveSupport::TestCase
    setup do
      @renderer = stub("renderer")
    end

    test "#options returns options with labels and values" do
      question = Question::MultipleChoice.new(nil, :question_name?)
      question.option(:option_one)
      question.option(:option_two)

      @renderer.stubs(:option_text).with(:option_one).returns("option-one-text")
      @renderer.stubs(:option_text).with(:option_two).returns("option-two-text")
      presenter = QuestionWithOptionsPresenter.new(question, nil, renderer: @renderer)

      assert_equal %w(option_one option_two), presenter.options.map(&:value)
      assert_equal %w(option-one-text option-two-text), presenter.options.map(&:label)
    end
  end
end
