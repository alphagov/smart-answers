require_relative '../test_helper'
require_relative '../helpers/i18n_test_helper'
require_relative '../fixtures/smart_answer_flows/smart-answers-controller-sample-with-value-question'
require_relative 'smart_answers_controller_test_helper'
require 'gds_api/test_helpers/content_api'

class SmartAnswersControllerValueQuestionTest < ActionController::TestCase
  tests SmartAnswersController

  include I18nTestHelper
  include SmartAnswersControllerTestHelper
  include GdsApi::TestHelpers::ContentApi

  def setup
    stub_content_api_default_artefact

    @flow = SmartAnswer::SmartAnswersControllerSampleWithValueQuestionFlow.build
    load_path = fixture_file('smart_answer_flows')
    SmartAnswer::FlowRegistry.stubs(:instance).returns(stub("Flow registry", find: @flow, load_path: load_path))
    use_additional_translation_file(fixture_file('smart_answer_flows/locales/en/smart-answers-controller-sample-with-value-question.yml'))
  end

  def teardown
    reset_translation_files
  end

  context "GET /<slug>" do
    context "value question" do
      should "display question" do
        get :show, id: 'smart-answers-controller-sample-with-value-question', started: 'y'
        assert_select ".step.current h2", /How many green bottles\?/
        assert_select "input[type=text][name=response]"
      end

      should "accept question input and redirect to canonical url" do
        submit_response "10"
        assert_redirected_to '/smart-answers-controller-sample-with-value-question/y/10'
      end

      should "display collapsed question, and format number" do
        get :show, id: 'smart-answers-controller-sample-with-value-question', started: 'y', responses: "12345"
        assert_select ".done-questions", /How many green bottles\?\s+12,345/
      end

      context "label in translation file" do
        setup do
          get :show, id: 'smart-answers-controller-sample-with-value-question', started: 'y', responses: "12345"
        end
        should "show the label text before the question input" do
          assert_match /value-question-label.*?input.*?name="response".*?/, response.body
          assert_select "label > input[type=text][name=response]"
        end
      end

      context "suffix_label in translation file" do
        setup do
          get :show, id: 'smart-answers-controller-sample-with-value-question', started: 'y', responses: "123/456"
        end

        should "show the label text after the question input" do
          assert_match /input.*?name="response".*?value-question-suffix-label/, response.body
          assert_select "label > input[type=text][name=response]"
        end
      end
    end
  end

  def submit_response(response = nil, other_params = {})
    super(response, other_params.merge(id: 'smart-answers-controller-sample-with-value-question'))
  end

  def submit_json_response(response = nil, other_params = {})
    super(response, other_params.merge(id: 'smart-answers-controller-sample-with-value-question'))
  end
end
