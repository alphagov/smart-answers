require_relative "../test_helper"

module SmartAnswer
  class CheckboxQuestionPresenterTest < ActiveSupport::TestCase
    setup do
      @question = Question::Checkbox.new(nil, :question_name?)
      @question.option(:option1)
      @question.option(:option2)
      @question.option(:option3)

      @renderer = stub("renderer")

      @renderer.stubs(:option_text).with(:option1).returns("Option 1")
      @renderer.stubs(:option_text).with(:option2).returns("Option 2")
      @renderer.stubs(:option_text).with(:option3).returns("Option 3")

      @presenter = CheckboxQuestionPresenter.new(@question, nil, renderer: @renderer)
    end

    test "#response_labels returns option labels for responses" do
      assert_equal ["Option 1", "Option 2"], @presenter.response_labels("option1,option2")
    end

    test "#response_labels returns default none label" do
      assert_equal %w[None], @presenter.response_labels("none")
    end

    test "#checkboxes return hashes of checkbox attributes" do
      assert_equal(%w[option1 option2 option3], @presenter.checkboxes.map { |c| c[:value] })
      assert_equal(["Option 1", "Option 2", "Option 3"], @presenter.checkboxes.map { |c| c[:label] })
      assert_equal([nil, nil, nil], @presenter.checkboxes.map { |c| c[:checked] })
    end
  end
end
