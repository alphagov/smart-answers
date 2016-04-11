require_relative '../test_helper'
require_relative '../helpers/fixture_flows_helper'
require_relative '../fixtures/smart_answer_flows/smart-answers-controller-sample'
require_relative 'smart_answers_controller_test_helper'
require 'gds_api/test_helpers/content_api'

class SmartAnswersControllerTest < ActionController::TestCase
  include FixtureFlowsHelper
  include SmartAnswersControllerTestHelper
  include GdsApi::TestHelpers::ContentApi

  def setup
    stub_content_api_default_artefact
    setup_fixture_flows
  end

  def teardown
    teardown_fixture_flows
  end

  context "GET /<slug>" do
    should "respond with 404 if not found" do
      @registry = stub("Flow registry")
      @registry.stubs(:find).raises(SmartAnswer::FlowRegistry::NotFound)
      @controller.stubs(:flow_registry).returns(@registry)
      get :show, id: 'smart-answers-controller-sample'
      assert_response :missing
    end

    should "display landing page in html if no questions answered yet" do
      get :show, id: 'smart-answers-controller-sample'
      assert_select "h1", /Smart answers controller sample/
    end

    should "not have noindex tag on landing page" do
      get :show, id: 'smart-answers-controller-sample'
      assert_select "meta[name=robots][content=noindex]", count: 0
    end

    should "have cache headers set to 30 mins" do
      with_cache_control_expiry do
        get :show, id: "smart-answers-controller-sample"
        assert_equal "max-age=1800, public", @response.header["Cache-Control"]
      end
    end

    context "without a valid artefact" do
      setup do
        FlowPresenter.any_instance.stubs(:artefact).returns({})
      end

      should "still return a success response" do
        get :show, id: "smart-answers-controller-sample"
        assert response.ok?
      end

      should "have cache headers set to 5 seconds" do
        with_cache_control_expiry do
          get :show, id: "smart-answers-controller-sample"
          assert_equal "max-age=5, public", @response.header["Cache-Control"]
        end
      end
    end

    context "meta description in erb template" do
      should "be shown" do
        get :show, id: 'smart-answers-controller-sample'
        assert_select "head meta[name=description]" do |meta_tags|
          assert_equal 'This is a test description', meta_tags.first['content']
        end
      end
    end

    should "display first question after starting" do
      get :show, id: 'smart-answers-controller-sample', started: 'y'
      assert_select ".step.current h2", /Do you like chocolate\?/
      assert_select "input[name=response][value=yes]"
      assert_select "input[name=response][value=no]"
    end

    should "show outcome when smart answer is complete so that 'smartanswerOutcome' JS event is fired" do
      get :show, id: 'smart-answers-controller-sample', started: 'y', responses: 'yes'
      assert_select ".outcome"
    end

    should "have meta robots noindex on question pages" do
      get :show, id: 'smart-answers-controller-sample', started: 'y'
      assert_select "head meta[name=robots][content=noindex]"
    end

    should "send the artefact to slimmer" do
      artefact = artefact_for_slug('smart-answers-controller-sample')
      FlowPresenter.any_instance.stubs(:artefact).returns(artefact)
      @controller.expects(:set_slimmer_artefact).with(artefact)

      get :show, id: 'smart-answers-controller-sample'
    end

    should "503 if content_api times out" do
      FlowPresenter.any_instance.stubs(:artefact).raises(GdsApi::TimedOutException)

      get :show, id: 'smart-answers-controller-sample'
      assert_equal 503, response.status
    end

    should "404 Not Found if request is for an unknown format" do
      @controller.stubs(:respond_to).raises(ActionController::UnknownFormat)

      get :show, id: 'smart-answers-controller-sample'
      assert_response :not_found
    end

    should "send slimmer analytics headers" do
      get :show, id: 'smart-answers-controller-sample'
      assert_equal "smart_answer", @response.headers["X-Slimmer-Format"]
    end

    should "cope with no artefact found" do
      content_api_does_not_have_an_artefact 'sample'
      get :show, id: 'smart-answers-controller-sample'
      assert @response.success?
    end

    should "accept responses as GET params and redirect to canonical url" do
      submit_response "yes"
      assert_redirected_to '/smart-answers-controller-sample/y/yes'
    end

    context "a response has been accepted" do
      setup do
        get :show, id: 'smart-answers-controller-sample', started: 'y', responses: "no"
      end

      should "show response summary" do
        assert_select ".done-questions", /Do you like chocolate\?\s+No/
      end

      should "show the next question" do
        assert_select ".current", /Do you like jam\?/
      end

      should "link back to change the response" do
        assert_select ".done-questions a", /Change/ do |link_nodes|
          assert_equal '/smart-answers-controller-sample/y?previous_response=no', link_nodes.first['href']
        end
      end
    end

    context "format=json" do
      should "render content without layout" do
        get :show, id: 'smart-answers-controller-sample', started: 'y', responses: "no", format: "json"
        data = JSON.parse(response.body)
        assert_equal '/smart-answers-controller-sample/y/no', data['url']
        doc = Nokogiri::HTML(data['html_fragment'])
        assert_match /Smart answers controller sample/, doc.css('h1').first.to_s
        assert_equal 0, doc.css('head').size, "Should not have layout"
        assert_equal '/smart-answers-controller-sample/y/no', doc.css('form').first.attributes['action'].to_s
        assert_equal 'Do you like jam?', data['title']
      end
    end

    context "format=txt" do
      should "render govspeak text for outcome node" do
        document = stub('Govspeak::Document', to_html: 'html-output')
        Govspeak::Document.stubs(:new).returns(document)

        get :show, id: 'smart-answers-controller-sample', started: 'y', responses: "yes", format: "txt"

        assert_match /sweet-tooth-outcome-title/, response.body
        assert_match /sweet-tooth-outcome-govspeak-body/, response.body
        assert_match /sweet-tooth-outcome-govspeak-next-steps/, response.body
      end

      should "render govspeak text for the landing page" do
        get :show, id: 'smart-answers-controller-sample', format: 'txt'
        assert response.body.start_with?("Smart answers controller sample")
      end

      should "render not found for a question node" do
        document = stub('Govspeak::Document', to_html: 'html-output')
        Govspeak::Document.stubs(:new).returns(document)

        get :show, id: 'smart-answers-controller-sample', started: 'y', format: "txt"

        assert_response :missing
      end

      context "when Rails.application.config.expose_govspeak is not set" do
        setup do
          Rails.application.config.stubs(:expose_govspeak).returns(false)
        end

        should "render not found" do
          get :show, id: 'smart-answers-controller-sample', started: 'y', responses: "yes", format: "txt"

          assert_response :missing
        end
      end
    end

    context "debugging" do
      should "render debug information on the page when enabled" do
        @controller.stubs(:debug?).returns(true)
        get :show, id: 'smart-answers-controller-sample', started: 'y', responses: "no", debug: "1"

        assert_select "pre.debug"
      end

      should "not render debug information on the page when not enabled" do
        @controller.stubs(:debug?).returns(false)
        get :show, id: 'smart-answers-controller-sample', started: 'y', responses: "no", debug: nil

        assert_select "pre.debug", false, "The page should not render debug information"
      end
    end
  end
end
