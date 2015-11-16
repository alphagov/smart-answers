require_relative '../test_helper'
require_relative '../helpers/i18n_test_helper'
require_relative '../fixtures/smart_answer_flows/smart-answers-controller-sample-with-multiple-choice-question'
require_relative 'smart_answers_controller_test_helper'
require 'gds_api/test_helpers/content_api'

class SmartAnswersControllerMultipleChoiceQuestionTest < ActionController::TestCase
  tests SmartAnswersController

  include I18nTestHelper
  include SmartAnswersControllerTestHelper
  include GdsApi::TestHelpers::ContentApi

  def setup
    stub_content_api_default_artefact

    @flow = SmartAnswer::SmartAnswersControllerSampleWithMultipleChoiceQuestionFlow.build
    load_path = fixture_file('smart_answer_flows')
    SmartAnswer::FlowRegistry.stubs(:instance).returns(stub("Flow registry", find: @flow, load_path: load_path))
    use_additional_translation_file(fixture_file('smart_answer_flows/locales/en/smart-answers-controller-sample-with-multiple-choice-question.yml'))
  end

  def teardown
    reset_translation_files
  end

  context "multiple choice question" do
    context "format=json" do
      context "no response given" do
        should "show an error message" do
          submit_json_response(nil)
          data = JSON.parse(response.body)
          doc = Nokogiri::HTML(data['html_fragment'])
          assert doc.css('.error').size > 0, "#{data['html_fragment']} should contain .error"
        end
      end
    end
  end

  def submit_response(response = nil, other_params = {})
    super(response, other_params.merge(id: 'smart-answers-controller-sample-with-multiple-choice-question'))
  end

  def submit_json_response(response = nil, other_params = {})
    super(response, other_params.merge(id: 'smart-answers-controller-sample-with-multiple-choice-question'))
  end
end
