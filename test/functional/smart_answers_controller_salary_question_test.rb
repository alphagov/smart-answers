require_relative '../test_helper'
require_relative '../helpers/i18n_test_helper'
require_relative '../fixtures/smart_answer_flows/smart-answers-controller-sample-with-salary-question'
require_relative 'smart_answers_controller_test_helper'
require 'gds_api/test_helpers/content_api'

class SmartAnswersControllerSalaryQuestionTest < ActionController::TestCase
  tests SmartAnswersController

  include I18nTestHelper
  include SmartAnswersControllerTestHelper
  include GdsApi::TestHelpers::ContentApi

  def setup
    stub_content_api_default_artefact

    @flow = SmartAnswer::SmartAnswersControllerSampleWithSalaryQuestionFlow.build
    load_path = fixture_file('smart_answer_flows')
    SmartAnswer::FlowRegistry.stubs(:instance).returns(stub("Flow registry", find: @flow, load_path: load_path))
    use_additional_translation_file(fixture_file('smart_answer_flows/locales/en/smart-answers-controller-sample-with-salary-question.yml'))
  end

  def teardown
    reset_translation_files
  end

  context "GET /<slug>" do
    context "salary question" do
      should "display question" do
        get :show, id: 'smart-answers-controller-sample-with-salary-question', started: 'y'
        assert_select ".step.current h2", /How much\?/
        assert_select "input[type=text][name='response[amount]']"
        assert_select "select[name='response[period]']"
      end

      context "error message overridden in translation file" do
        setup do
          submit_response({ amount: "bad_number" }, { responses: '1.23' })
        end

        should "show a validation error if invalid amount" do
          assert_select ".step.current h2", /Salary question with error message/
          assert_select ".error", /salary-question-error-message/
        end
      end

      context "error message not overridden in translation file" do
        should "show a generic message" do
          submit_response amount: "bad_number"
          assert_select ".step.current h2", /How much\?/
          assert_select ".error", /Please answer this question/
        end
      end

      should "show a validation error if invalid period" do
        submit_response amount: "1", period: "bad_period"
        assert_select ".step.current h2", /How much\?/
        assert_select ".error", /Please answer this question/
      end

      should "accept responses as GET params and redirect to canonical url" do
        submit_response amount: "1", period: "month"
        assert_redirected_to '/smart-answers-controller-sample-with-salary-question/y/1.0-month'
      end

      context "a response has been accepted" do
        setup do
          with_cache_control_expiry do
            get :show, id: 'smart-answers-controller-sample-with-salary-question', started: 'y', responses: "1.0-month"
          end
        end

        should "show response summary" do
          assert_select ".done-questions", /How much\?\s+£1 per month/
        end

        should "have cache headers set to 30 mins for inner pages" do
          assert_equal "max-age=1800, public", @response.header["Cache-Control"]
        end
      end
    end
  end

  def submit_response(response = nil, other_params = {})
    super(response, other_params.merge(id: 'smart-answers-controller-sample-with-salary-question'))
  end

  def submit_json_response(response = nil, other_params = {})
    super(response, other_params.merge(id: 'smart-answers-controller-sample-with-salary-question'))
  end
end
