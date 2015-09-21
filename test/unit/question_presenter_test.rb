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

    test '#error returns nil if there is no error set on the state' do
      flow = nil
      question = Question::Date.new(flow, :example_question?)
      state = State.new(question.name)
      state.error = nil
      presenter = QuestionPresenter.new('flow.test', question, state)

      assert_nil presenter.error
    end

    test '#error uses the error key to lookup a custom error message for the question in the YAML file' do
      flow = nil
      question = Question::Date.new(flow, :question_with_custom_error_message)
      state = State.new(question.name)
      state.error = :custom_error_message
      presenter = QuestionPresenter.new('flow.test', question, state)

      assert_equal 'custom error message', presenter.error
    end

    test '#error falls back to the default error message for the question in the YAML file' do
      flow = nil
      question = Question::Date.new(flow, :question_with_default_error_message)
      state = State.new(question.name)
      state.error = :non_existent_custom_error_message
      presenter = QuestionPresenter.new('flow.test', question, state)

      assert_equal 'default error message', presenter.error
    end

    test '#error falls back to the default error message for the flow' do
      flow = nil
      question_name = :question_with_no_custom_or_default_error_message
      question = Question::Date.new(flow, question_name)
      state = State.new(question.name)
      state.error = "SmartAnswer::InvalidResponse"
      presenter = QuestionPresenter.new('flow.test', question, state)

      assert_equal 'Please answer this question', presenter.error
    end
  end
end
