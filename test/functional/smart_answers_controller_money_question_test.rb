require_relative '../test_helper'
require_relative '../helpers/i18n_test_helper'
require_relative '../fixtures/smart_answer_flows/smart-answers-controller-sample-with-money-question'
require_relative 'smart_answers_controller_test_helper'
require 'gds_api/test_helpers/content_api'

class SmartAnswersControllerMoneyQuestionTest < ActionController::TestCase
  tests SmartAnswersController

  include I18nTestHelper
  include SmartAnswersControllerTestHelper
  include GdsApi::TestHelpers::ContentApi

  def setup
    stub_content_api_default_artefact

    @flow = SmartAnswer::SmartAnswersControllerSampleWithMoneyQuestionFlow.build
    load_path = fixture_file('smart_answer_flows')
    SmartAnswer::FlowRegistry.stubs(:instance).returns(stub("Flow registry", find: @flow, load_path: load_path))
    use_additional_translation_file(fixture_file('smart_answer_flows/locales/en/smart-answers-controller-sample-with-money-question.yml'))
  end

  def teardown
    reset_translation_files
  end

  context "GET /<slug>" do
    context "money question" do
      should "display question" do
        get :show, id: 'smart-answers-controller-sample-with-money-question', started: 'y'
        assert_select ".step.current h2", /How much\?/
        assert_select "input[type=text][name=response]"
      end

      should "show a validation error if invalid input" do
        submit_response "bad_number"
        assert_select ".step.current h2", /How much\?/
        assert_select "body", /Please answer this question/
      end

      context "suffix_label in translation file" do
        setup do
          get :show, id: 'smart-answers-controller-sample-with-money-question', started: 'y', responses: '1.23'
        end

        should "show the label after the question input" do
          assert_select "label > input[type=text][name=response]"
          assert_match /input.*?name="response".*?money-question-suffix-label/, response.body
        end
      end
    end
  end

  def submit_response(response = nil, other_params = {})
    super(response, other_params.merge(id: 'smart-answers-controller-sample-with-money-question'))
  end

  def submit_json_response(response = nil, other_params = {})
    super(response, other_params.merge(id: 'smart-answers-controller-sample-with-money-question'))
  end
end
