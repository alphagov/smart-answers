
require_relative '../test_helper'

require 'ostruct'

module SmartAnswer
  class NodePresenterTest < ActiveSupport::TestCase
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

    test "Interpolated dates are localized" do
      question = Question::Date.new(nil, :interpolated_question)
      state = State.new(question.name)
      state.day = Date.parse('2011-04-05')
      presenter = NodePresenter.new("flow.test", question, state)

      assert_match /Today is  5 April 2011/, presenter.body
    end

    test "Interpolated phrase lists are localized and interpreted as govspeak" do
      outcome = Outcome.new(nil, :outcome_with_interpolated_phrase_list)
      state = State.new(outcome.name)
      state.phrases = PhraseList.new(:one, :two, :three)
      presenter = NodePresenter.new("flow.test", outcome, state)

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
      presenter = NodePresenter.new("flow.test", outcome, state)

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
      presenter = NodePresenter.new("flow.test", question)

      assert_equal "<p>The body copy</p>\n", presenter.body
    end

    test "Node body looked up from translation file, rendered as raw text when HTML disabled" do
      question = Question::Date.new(nil, :example_question?)
      presenter = NodePresenter.new("flow.test", question)

      assert_equal "The body copy", presenter.body(html: false)
    end

    test "Can check if a node has body" do
      assert NodePresenter.new("flow.test", Question::Date.new(nil, :example_question?)).has_body?, "example_question? has body"
      assert !NodePresenter.new("flow.test", Question::Date.new(nil, :missing)).has_body?, "missing has no body"
    end

    test "Node hint looked up from translation file" do
      question = Question::Date.new(nil, :example_question?)
      presenter = NodePresenter.new("flow.test", question)

      assert_equal 'Hint for foo', presenter.hint
    end

    test "Can check if node has hint" do
      assert NodePresenter.new("flow.test", Question::Date.new(nil, :example_question?)).has_hint?
      assert !NodePresenter.new("flow.test", Question::Date.new(nil, :missing)).has_hint?
    end

    test "Options can be looked up from translation file" do
      question = Question::MultipleChoice.new(nil, :example_question?)
      question.option yes: :yay
      question.option no: :nay
      presenter = NodePresenter.new("flow.test", question)

      assert_equal "Oui", presenter.options[0].label
      assert_equal "Non", presenter.options[1].label
      assert_equal "yes", presenter.options[0].value
      assert_equal "no", presenter.options[1].value
    end

    test "Options can be looked up from default values in translation file" do
      question = Question::MultipleChoice.new(nil, :example_question?)
      question.option maybe: :mumble
      presenter = NodePresenter.new("flow.test", question)

      assert_equal "Mebbe", presenter.options[0].label
    end

    test "Options label falls back to option value" do
      question = Question::MultipleChoice.new(nil, :example_question?)
      question.option something: :mumble
      presenter = NodePresenter.new("flow.test", question)

      assert_equal "something", presenter.options[0].label
    end

    test "Can lookup a response label for a multiple choice question" do
      question = Question::MultipleChoice.new(nil, :example_question?)
      question.option yes: :yay
      question.option no: :nay
      presenter = MultipleChoiceQuestionPresenter.new("flow.test", question)

      assert_equal "Oui", presenter.response_label("yes")
    end

    test "Can lookup a response label for a date question" do
      question = Question::Date.new(nil, :example_question?)
      presenter = DateQuestionPresenter.new("flow.test", question)

      assert_equal " 1 March 2011", presenter.response_label(Date.parse("2011-03-01"))
    end

    test "Identifies the relevant partial template for the class of the node" do
      presenter = QuestionPresenter.new(nil, Question::Date.new(nil, nil))
      assert_equal "date_question", presenter.partial_template_name

      presenter = QuestionPresenter.new(nil, Question::CountrySelect.new(nil, nil))
      assert_equal "country_select_question", presenter.partial_template_name

      presenter = QuestionPresenter.new(nil, Question::MultipleChoice.new(nil, nil))
      assert_equal "multiple_choice_question", presenter.partial_template_name
    end
  end
end
