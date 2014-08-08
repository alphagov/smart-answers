# encoding: UTF-8
require_relative '../test_helper'
require 'gds_api/test_helpers/content_api'

class ValidationTest < ActionController::TestCase
  include GdsApi::TestHelpers::ContentApi

  setup do
    stub_content_api_default_artefact
    @controller = SmartAnswersController.new
  end

  should "compare coversheet content" do
    smartdown_name = "student-finance-forms"
    smartanswer_name = "student-finance-forms"
    @controller.stubs(:smartdown_question).returns(false)
    get :show, { id: smartanswer_name }
    smartanswer_content = response.body
    @controller.stubs(:smartdown_question).returns(true)
    get :show, { id: smartdown_name }
    smartdown_content = response.body
    error_message_diff = Diffy::Diff.new(smartanswer_content, smartdown_content)
    assert_equal smartanswer_content, smartdown_content, message = error_message_diff
  end

  should "the first question page" do
    smartdown_name = "student-finance-forms"
    smartanswer_name = "student-finance-forms"
    @controller.stubs(:smartdown_question).returns(false)
    get :show, { id: smartanswer_name, started: "y" }
    smartanswer_content = response.body
    @controller.stubs(:smartdown_question).returns(true)
    get :show, { id: smartdown_name, started: "y" }
    smartdown_content = response.body
    error_message_diff = Diffy::Diff.new(smartanswer_content, smartdown_content)
    assert_equal smartanswer_content, smartdown_content, message = error_message_diff
  end


  ["uk-full-time", "uk-part-time", "eu-full-time", "eu-part-time"].each do |answer|
    should "second question page after answer #{answer}" do
      smartdown_name = "student-finance-forms"
      smartanswer_name = "student-finance-forms"
      @controller.stubs(:smartdown_question).returns(false)
      get :show, { id: smartanswer_name, started: "y", responses: answer }
      smartanswer_content = response.body
      @controller.stubs(:smartdown_question).returns(true)
      get :show, { id: smartdown_name, started: "y", responses: answer  }
      smartdown_content = response.body
      error_message_diff = Diffy::Diff.new(smartanswer_content, smartdown_content)
      assert_equal smartanswer_content, smartdown_content, message = error_message_diff
    end
  end
end
