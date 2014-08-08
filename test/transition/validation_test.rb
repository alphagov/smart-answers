# encoding: UTF-8
require_relative '../test_helper'
require 'gds_api/test_helpers/content_api'

class ValidationTest < ActionController::TestCase
  include GdsApi::TestHelpers::ContentApi

  setup do
    stub_content_api_default_artefact
    @controller = SmartAnswersController.new
  end

  def get_smartanswer_content(question_name, started=false, responses=[])
    get_content(question_name, false, started, responses)
  end

  def get_smartdown_content(question_name, started=false, responses=[])
    get_content(question_name, true, started, responses)
  end

  def get_content(question_name, is_smartdown, started, responses)
    @controller.stubs(:smartdown_question).returns(is_smartdown)
    params = { id: question_name}
    if started
      params.merge!(started: "y")
    end
    unless responses.empty?
      params.merge!(responses: responses)
    end
    get :show, params
    response.body
  end

  should "compare coversheet content" do
    question_name = "student-finance-forms"
    smartanswer_content = get_smartanswer_content(question_name)
    smartdown_content = get_smartdown_content(question_name)
    error_message_diff = Diffy::Diff.new(smartanswer_content, smartdown_content)
    assert_equal smartanswer_content, smartdown_content, message = error_message_diff
  end

  should "the first question page" do
    question_name = "student-finance-forms"
    smartanswer_content = get_smartanswer_content(question_name, true)
    smartdown_content = get_smartdown_content(question_name, true)
    error_message_diff = Diffy::Diff.new(smartanswer_content, smartdown_content)
    assert_equal smartanswer_content, smartdown_content, message = error_message_diff
  end


  ["uk-full-time", "uk-part-time", "eu-full-time", "eu-part-time"].each do |answer|
    should "second question page after answer #{answer}" do
      question_name = "student-finance-forms"
      smartanswer_content = get_smartanswer_content(question_name, true, answer)
      smartdown_content = get_smartdown_content(question_name, true, answer)
      error_message_diff = Diffy::Diff.new(smartanswer_content, smartdown_content)
      assert_equal smartanswer_content, smartdown_content, message = error_message_diff
    end
  end
end
