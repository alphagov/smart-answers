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

    test "Node hint looked up from translation file" do
      question = Question::Date.new(nil, :example_question?)
      presenter = QuestionPresenter.new("flow.test", question)

      assert_equal 'Hint for foo', presenter.hint
    end

    test "Can check if node has hint" do
      assert QuestionPresenter.new("flow.test", Question::Date.new(nil, :example_question?)).has_hint?
      assert !QuestionPresenter.new("flow.test", Question::Date.new(nil, :missing)).has_hint?
    end

    test "Interpolated dates are localized" do
      question = Question::Date.new(nil, :interpolated_question)
      state = State.new(question.name)
      state.day = Date.parse('2011-04-05')
      presenter = QuestionPresenter.new("flow.test", question, state)

      assert_match /Today is  5 April 2011/, presenter.body
    end

    test "Interpolated phrase lists are localized and interpreted as govspeak" do
      outcome = Outcome.new(nil, :outcome_with_interpolated_phrase_list)
      state = State.new(outcome.name)
      state.phrases = PhraseList.new(:one, :two, :three)
      presenter = QuestionPresenter.new("flow.test", outcome, state)

      assert_match Regexp.new("<p>Here are the phrases:</p>

      <p>This is the first one</p>

      <p>This is <strong>the</strong> second</p>

      <p>The last!</p>
      ".gsub /^      /, ''), presenter.body
    end

    test "Phrase lists notify developers and fallback gracefully when no translation can be found" do
      outcome = Outcome.new(nil, :outcome_with_interpolated_phrase_list)
      state = State.new(outcome.name)
      state.phrases = PhraseList.new(:four, :one, :two, :three)
      presenter = QuestionPresenter.new("flow.test", outcome, state)

      Rails.logger.expects(:warn).with("[Missing phrase] The phrase being rendered is not present: flow.test.phrases.four\tResponses: ").once

      assert_match Regexp.new("<p>Here are the phrases:</p>

      <p>four</p>

      <p>This is the first one</p>

      <p>This is <strong>the</strong> second</p>

      <p>The last!</p>
      ".gsub /^      /, ''), presenter.body
    end

    test "Node body looked up from translation file, rendered as HTML using govspeak by default" do
      question = Question::Date.new(nil, :example_question?)
      presenter = QuestionPresenter.new("flow.test", question)

      assert_equal "<p>The body copy</p>\n", presenter.body
    end

    test "Node body looked up from translation file, rendered as raw text when HTML disabled" do
      question = Question::Date.new(nil, :example_question?)
      presenter = QuestionPresenter.new("flow.test", question)

      assert_equal "The body copy", presenter.body(html: false)
    end

    test 'delegates #to_response to node' do
      question = stub('question')
      question.stubs(:to_response).returns('response')
      presenter = QuestionPresenter.new("flow.test", question)

      assert_equal 'response' , presenter.to_response('answer-text')
    end
  end
end
