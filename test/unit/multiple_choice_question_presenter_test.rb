require_relative "../test_helper"

module SmartAnswer
  class MultipleChoiceQuestionPresenterTest < ActiveSupport::TestCase
    setup do
      @question = Question::Radio.new(nil, :question_name?)
      @question.option(:option1)
      @question.option(:option2)
      @question.option(:option3)

      @renderer = stub("renderer")

      @renderer.stubs(:option).with(:option1).returns("Option 1")
      @renderer.stubs(:option).with(:option2).returns("Option 2")
      @renderer.stubs(:option).with(:option3).returns("Option 3")

      @presenter = MultipleChoiceQuestionPresenter.new(@question, nil, nil, renderer: @renderer)
      @presenter.stubs(:response_for_current_question).returns(nil)
    end

    test "#response_label returns option label" do
      assert_equal "Option 1", @presenter.response_label("option1")
    end

    test "#radio_buttons return hashes of radio attributes" do
      assert_equal(%w[option1 option2 option3], @presenter.radio_buttons.map { |c| c[:value] })
      assert_equal(["Option 1", "Option 2", "Option 3"], @presenter.radio_buttons.map { |c| c[:text] })
      assert_equal([false, false, false], @presenter.radio_buttons.map { |c| c[:checked] })
    end

    test "#radio_buttons sets an existing selection to true" do
      @presenter.stubs(:response_for_current_question).returns("option2")

      assert_equal([false, true, false], @presenter.radio_buttons.map { |c| c[:checked] })
    end

    test "#caption returns the given caption when a caption is given" do
      @renderer.stubs(:hide_caption).returns(false)
      @renderer.stubs(:content_for).with(:caption).returns("caption-text")

      assert_equal "caption-text", @presenter.caption
    end
  end
end
