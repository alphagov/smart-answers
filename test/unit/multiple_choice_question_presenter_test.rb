require_relative "../test_helper"

module SmartAnswer
  class MultipleChoiceQuestionPresenterTest < ActiveSupport::TestCase
    setup do
      @question = Question::MultipleChoice.new(nil, :question_name?)
      @question.option(:option1)
      @question.option(:option2)
      @question.option(:option3)

      @renderer = stub("renderer")

      @renderer.stubs(:option_text).with(:option1).returns("Option 1")
      @renderer.stubs(:option_text).with(:option2).returns("Option 2")
      @renderer.stubs(:option_text).with(:option3).returns("Option 3")

      @presenter = MultipleChoiceQuestionPresenter.new(@question, nil, renderer: @renderer)
    end

    test "#response_label returns option label" do
      assert_equal "Option 1", @presenter.response_label("option1")
    end

    test "#radio_buttons return hashes of radio attributes" do
      assert_equal(%w[option1 option2 option3], @presenter.radio_buttons.map { |c| c[:value] })
      assert_equal(["Option 1", "Option 2", "Option 3"], @presenter.radio_buttons.map { |c| c[:text] })
      assert_equal([nil, nil, nil], @presenter.radio_buttons.map { |c| c[:checked] })
    end
  end
end
