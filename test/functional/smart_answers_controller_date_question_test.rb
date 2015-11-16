require_relative '../test_helper'
require_relative '../helpers/i18n_test_helper'
require_relative '../helpers/fixture_flows_helper'
require_relative '../fixtures/smart_answer_flows/smart-answers-controller-sample-with-date-question'
require_relative 'smart_answers_controller_test_helper'
require 'gds_api/test_helpers/content_api'

class SmartAnswersControllerDateQuestionTest < ActionController::TestCase
  tests SmartAnswersController

  include I18nTestHelper
  include FixtureFlowsHelper
  include SmartAnswersControllerTestHelper
  include GdsApi::TestHelpers::ContentApi

  def setup
    stub_content_api_default_artefact

    setup_fixture_flows
    use_additional_translation_file(fixture_file('smart_answer_flows/locales/en/smart-answers-controller-sample-with-date-question.yml'))
  end

  def teardown
    teardown_fixture_flows
    reset_translation_files
  end

  context "GET /<slug>" do
    context "date question" do
      should "display question" do
        get :show, id: 'smart-answers-controller-sample-with-date-question', started: 'y'
        assert_select ".step.current h2", /When\?/
        assert_select "select[name='response[day]']"
        assert_select "select[name='response[month]']"
        assert_select "select[name='response[year]']"
      end

      should "accept question input and redirect to canonical url" do
        submit_response day: "1", month: "1", year: "2011"
        assert_redirected_to '/smart-answers-controller-sample-with-date-question/y/2011-01-01'
      end

      should "not error if passed blank response" do
        submit_response ''
        assert_response :success
      end

      should "not error if passed string response" do
        submit_response 'bob'
        assert_response :success
      end

      context "valid response given" do
        context "format=json" do
          should "give correct canonical url" do
            submit_json_response(day: "01", month: "01", year: "2013")
            assert_redirected_to '/smart-answers-controller-sample-with-date-question/y/2013-01-01.json'
          end

          should "set correct cache control headers" do
            with_cache_control_expiry do
              submit_json_response(day: "01", month: "01", year: "2013")
              assert_equal "max-age=1800, public", @response.header["Cache-Control"]
            end
          end
        end
      end

      context "no response given" do
        should "redisplay question" do
          submit_response(day: "", month: "", year: "")
          assert_select ".step.current h2", /When\?/
        end

        should "show an error message" do
          submit_response(day: "", month: "", year: "")
          assert_select ".step.current .error"
        end

        context "format=json" do
          should "give correct canonical url" do
            submit_json_response(day: "", month: "", year: "")
            data = JSON.parse(response.body)
            assert_equal '/smart-answers-controller-sample-with-date-question/y', data['url']
          end

          should "show an error message" do
            submit_json_response(day: "", month: "", year: "")
            data = JSON.parse(response.body)
            doc = Nokogiri::HTML(data['html_fragment'])
            current_step = doc.css('.step.current')
            assert current_step.css('.error').size > 0, "#{current_step.to_s} should contain .error"
          end
        end
      end

      should "display collapsed question, and format number" do
        get :show, id: 'smart-answers-controller-sample-with-date-question', started: 'y', responses: "2011-01-01"
        assert_select ".done-questions", /When\?\s+1 January 2011/
      end
    end
  end

  def submit_response(response = nil, other_params = {})
    super(response, other_params.merge(id: 'smart-answers-controller-sample-with-date-question'))
  end

  def submit_json_response(response = nil, other_params = {})
    super(response, other_params.merge(id: 'smart-answers-controller-sample-with-date-question'))
  end
end
