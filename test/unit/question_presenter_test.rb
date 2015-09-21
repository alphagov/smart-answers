require_relative '../test_helper'

module SmartAnswer
  class QuestionPresenterTest < ActiveSupport::TestCase
    def setup
      @old_load_path = I18n.config.load_path.dup
      @example_translation_file =
        File.expand_path('../../fixtures/node_presenter_test/example.yml', __FILE__)
      I18n.config.load_path.unshift(@example_translation_file)
      I18n.reload!
    end

    def teardown
      I18n.config.load_path = @old_load_path
      I18n.reload!
    end

    test "Node title looked up from translation file" do
      question = Question::Date.new(nil, :example_question?)
      presenter = QuestionPresenter.new("flow.test", question)

      assert_equal 'Foo', presenter.title
    end

    test "Node title existence check" do
      question = Question::Date.new(nil, :example_question?)
      presenter = QuestionPresenter.new("flow.test", question)

      assert presenter.has_title?
    end

    test "Node title can be interpolated with state" do
      question = Question::Date.new(nil, :interpolated_question)
      state = State.new(question.name)
      state.day = 'Monday'
      presenter = QuestionPresenter.new("flow.test", question, state)

      assert_equal 'Is today a Monday?', presenter.title
    end
  end
end
