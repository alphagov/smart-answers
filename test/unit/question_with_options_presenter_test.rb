require_relative "../test_helper"

module SmartAnswer
  class QuestionWithOptionsPresenterTest < ActiveSupport::TestCase
    setup do
      @renderer = stub("renderer")

      @renderer.stubs(:option).with(:option_one).returns("option-one-text")
      @renderer.stubs(:option).with(:option_two).returns({ label: "option-two-text", hint_text: "option-two-hint" })
      @renderer.stubs(:option).with(:option_three).returns("option-three-text")
    end

    context "question defined with option keys" do
      setup do
        question = Question::Radio.new(nil, :question_name?) do
          option(:option_one)
          option(:option_two)
        end

        @presenter = QuestionWithOptionsPresenter.new(question, nil, nil, renderer: @renderer)
      end

      should "options returns options with labels and values" do
        assert_equal(%w[option_one option_two], @presenter.options.map { |o| o[:value] })
        assert_equal(%w[option-one-text option-two-text], @presenter.options.map { |o| o[:label] })
      end

      should "option_attributes returns a hash when option attribute is a string from the renderer" do
        assert_equal({ label: "option-one-text", value: "option_one" }, @presenter.option_attributes("option_one"))
      end

      should "option_attributes returns a hash when option attribute is a hash from the renderer" do
        assert_equal({ label: "option-two-text", value: "option_two", hint_text: "option-two-hint" }, @presenter.option_attributes("option_two"))
      end
    end

    context "question defined with an option block" do
      setup do
        question = Question::Radio.new(nil, :question_name?) do
          options { %w[option_two option_three] }
        end

        @presenter = QuestionWithOptionsPresenter.new(question, nil, nil, renderer: @renderer)
      end

      should "options returns options with labels and values" do
        assert_equal(%w[option_two option_three], @presenter.options.map { |o| o[:value] })
        assert_equal(%w[option-two-text option-three-text], @presenter.options.map { |o| o[:label] })
      end
    end
  end
end
