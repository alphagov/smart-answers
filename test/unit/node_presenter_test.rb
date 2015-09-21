
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
