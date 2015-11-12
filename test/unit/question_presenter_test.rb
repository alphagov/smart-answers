require_relative '../test_helper'
require_relative "../helpers/i18n_test_helper"

module SmartAnswer
  class QuestionPresenterTest < ActiveSupport::TestCase
    include I18nTestHelper

    def setup
      @example_translation_file =
        File.expand_path('../../fixtures/smart_answer_flows/locales/en/question-presenter-sample.yml', __FILE__)
      use_additional_translation_file(@example_translation_file)
    end

    def teardown
      reset_translation_files
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

    context 'no error set on state' do
      setup do
        @question = Question::Date.new(nil, :example_question?)
        @state = State.new(@question.name)
        @state.error = nil
      end

      should 'return no error message' do
        presenter = QuestionPresenter.new('flow.test', @question, @state)
        assert_nil presenter.error
      end
    end

    context 'error message key exists for question' do
      setup do
        @question = Question::Date.new(nil, :question_with_custom_error_message)
        @state = State.new(@question.name)
        @state.error = 'custom_error_message_key'
      end

      should 'return error message for key' do
        presenter = QuestionPresenter.new('flow.test', @question, @state)
        assert_equal 'custom error message', presenter.error
      end
    end

    context 'error message key does not exist for question' do
      setup do
        @question = Question::Date.new(nil, :question_with_default_error_message)
        @state = State.new(@question.name)
        @state.error = 'non_existent_custom_error_message_key'
      end

      should 'return default error message for the question' do
        presenter = QuestionPresenter.new('flow.test', @question, @state)
        assert_equal 'default error message for the question', presenter.error
      end
    end

    context 'error is exception message and default error message interpolates it' do
      setup do
        @question = Question::Date.new(nil, :question_with_interpolated_default_error_message)
        @state = State.new(@question.name)
        @state.error = 'Raw message from InvalidResponse exception'
      end

      should 'return interpolated error message i.e. raw exception message' do
        presenter = QuestionPresenter.new('flow.test', @question, @state)
        assert_equal 'Raw message from InvalidResponse exception', presenter.error
      end
    end

    context 'neither error key nor default error key exist for question' do
      setup do
        @question = Question::Date.new(nil, :question_with_no_custom_or_default_error_message)
        @state = State.new(@question.name)
        @state.error = 'unknown_error_message_key'
      end

      should 'fallback to the system-wide default error message' do
        presenter = QuestionPresenter.new('flow.test', @question, @state)
        assert_equal I18n.translate('flow.defaults.error_message'), presenter.error
      end
    end

    test "Node hint looked up from translation file" do
      question = Question::Date.new(nil, :example_question?)
      presenter = QuestionPresenter.new("flow.test", question)

      assert_equal 'Hint for foo', presenter.hint
    end

    test "Interpolated dates are localized" do
      question = Question::Date.new(nil, :interpolated_question)
      state = State.new(question.name)
      state.day = Date.parse('2011-04-05')
      presenter = QuestionPresenter.new("flow.test", question, state)

      assert_match /Today is  5 April 2011/, presenter.body
    end

    test "Interpolated phrase lists are localized and interpreted as govspeak" do
      question = Question::Base.new(nil, :question_with_interpolated_phrase_list)
      state = State.new(question.name)
      state.phrases = PhraseList.new(:one, :two, :three)
      presenter = QuestionPresenter.new("flow.test", question, state)

      assert_match Regexp.new("<p>Here are the phrases:</p>

      <p>This is the first one</p>

      <p>This is <strong>the</strong> second</p>

      <p>The last!</p>
      ".gsub /^      /, ''), presenter.body
    end

    test "Phrase lists notify developers and fallback gracefully when no translation can be found" do
      question = Question::Base.new(nil, :question_with_interpolated_phrase_list)
      state = State.new(question.name)
      state.phrases = PhraseList.new(:four, :one, :two, :three)
      presenter = QuestionPresenter.new("flow.test", question, state)

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

    test "Node post_body looked up from translation file and parsed as govspeak" do
      question = Question::Date.new(nil, :question_with_post_body)
      presenter = QuestionPresenter.new("flow.test", question)

      assert_equal "<p>post body for question</p>\n", presenter.post_body
    end

    test "Node post_body returns nil when key doesn't exist in translation file" do
      question = Question::Date.new(nil, :question_with_no_post_body)
      presenter = QuestionPresenter.new("flow.test", question)

      assert_equal nil, presenter.post_body
    end

    test 'delegates #to_response to node' do
      question = Question::Base.new(nil, :question)
      question.stubs(:to_response).returns('response')
      presenter = QuestionPresenter.new("flow.test", question)

      assert_equal 'response', presenter.to_response('answer-text')
    end

    test "Options are looked up from translation file" do
      question = Question::MultipleChoice.new(nil, :example_question?)
      question.option :yes
      question.option :no
      presenter = QuestionPresenter.new("flow.test", question)

      assert_equal "Oui", presenter.options[0].label
      assert_equal "Non", presenter.options[1].label
      assert_equal "yes", presenter.options[0].value
      assert_equal "no", presenter.options[1].value
    end

    test "Exception is raised if option translation is missing" do
      question = Question::MultipleChoice.new(nil, :example_question?)
      question.option :missing
      presenter = QuestionPresenter.new("flow.test", question)

      e = assert_raises(I18n::MissingTranslationData) { presenter.options[0].label }
      assert_equal "translation missing: en-GB.flow.test.example_question?.options.missing", e.message
    end

    test "Avoids displaying the year for a date question when the year is 0" do
      question = Question::Date.new(nil, :example_question?)
      presenter = DateQuestionPresenter.new("flow.test", question)

      assert_equal " 5 April", presenter.response_label(Date.parse("0000-04-05"))
    end

    test "Identifies the relevant partial template for the class of the node" do
      presenter = QuestionPresenter.new(nil, Question::Date.new(nil, nil))
      assert_equal "date_question", presenter.partial_template_name

      presenter = QuestionPresenter.new(nil, Question::CountrySelect.new(nil, nil))
      assert_equal "country_select_question", presenter.partial_template_name

      presenter = QuestionPresenter.new(nil, Question::MultipleChoice.new(nil, nil))
      assert_equal "multiple_choice_question", presenter.partial_template_name
    end

    test "Can lookup a response label for a multiple choice question" do
      question = Question::MultipleChoice.new(nil, :example_question?)
      question.option :yes
      question.option :no
      presenter = MultipleChoiceQuestionPresenter.new("flow.test", question)

      assert_equal "Oui", presenter.response_label("yes")
    end

    test "Can lookup a response label for a date question" do
      question = Question::Date.new(nil, :example_question?)
      presenter = DateQuestionPresenter.new("flow.test", question)

      assert_equal " 1 March 2011", presenter.response_label(Date.parse("2011-03-01"))
    end
  end
end
