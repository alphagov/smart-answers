# encoding: UTF-8
require_relative '../test_helper'
require_relative '../helpers/smartdown_helper'
require 'gds_api/test_helpers/content_api'

class ValidationTest < ActionController::TestCase
  include GdsApi::TestHelpers::ContentApi
  include SmartdownHelper

  setup do
    stub_content_api_default_artefact
    @controller = SmartAnswersController.new
    @question_name = "student-finance-forms"
    @scenario_sequences = scenario_sequences("student-finance-forms")
  end

  should "have identical coversheets" do
    smartanswer_content = get_smartanswer_content(@question_name)
    smartdown_content = get_smartdown_content(@question_name)
    error_message_diff = Diffy::Diff.new(smartanswer_content, smartdown_content)
    assert_equal smartanswer_content, smartdown_content, message = error_message_diff
  end

  should "have identical first question page" do
    smartanswer_content = get_smartanswer_content(@question_name, true)
    smartdown_content = get_smartdown_content(@question_name, true)
    error_message_diff = Diffy::Diff.new(smartanswer_content, smartdown_content)
    assert_equal smartanswer_content, smartdown_content, message = error_message_diff
  end

  should "have identical pages given all possible answer scenarios" do
    errors = 0
    @scenario_sequences.each do |responses|
      smartanswer_content = get_smartanswer_content(@question_name, true, responses)
      begin
        smartdown_content = get_smartdown_content(@question_name, true, responses)
      rescue Smartdown::Engine::UndefinedValue
        p "UNDEFINED SMARTDOWN VALUE FOR #{responses.join(", ")}"
        p "================================"
        errors+=1
      rescue Smartdown::Engine::IndeterminateNextNode
        p "UNDEFINED SMARTDOWN NEXT NODE FOR #{responses.join(", ")}"
        p "================================"
        errors+=1
      end
      error_message_diff = Diffy::Diff.new(smartanswer_content, smartdown_content, :context => 1)
      if smartanswer_content != smartdown_content
        p "ERROR FOR #{responses.join(", ")}"
        p error_message_diff
        p "================================"
        errors+=1
      end
    end
    assert_equal 0, errors
  end
end
