require_relative "../test_helper"
require_relative "../fixtures/smart_answer_flows/smart-answers-controller-sample"
require_relative "smart_answers_controller_test_helper"

class SmartAnswersControllerTest < ActionController::TestCase
  include SmartAnswersControllerTestHelper

  def setup
    setup_fixture_flows
  end

  def teardown
    teardown_fixture_flows
  end

  context "GET /" do
    setup do
      @flow_a = stub(name: "flow-a", status: :published, questions: stub(count: 2), outcomes: stub(count: 3))
      @flow_b = stub(name: "flow-b", status: :draft, questions: stub(count: 3), outcomes: stub(count: 0))
      registry = stub("Flow registry")
      registry.stubs(:flows).returns([@flow_b, @flow_a])
      @controller.stubs(:flow_registry).returns(registry)
      FlowPresenter.any_instance.stubs(:start_node).returns(stub(title: "Flow Name"))
    end

    should "assign flows sorted alphabetically by name" do
      get :index
      assert_equal [@flow_a, @flow_b], assigns(:flows)
    end

    should "render index template" do
      get :index
      assert_template "index"
    end

    should "render list of links to flows" do
      get :index
      assert_select "table td a[href='/flow-a']", text: "/flow-a"
      assert_select "table td a[href='/flow-b']", text: "/flow-b"
    end

    should "render links to published flows and status" do
      get :index
      assert_select "table td a[href='https://www.gov.uk/flow-a']", text: "Published"
      assert_select "table td a[href='https://draft-origin.publishing.service.gov.uk/flow-b']", text: "Draft"
    end

    should "render links to visualise flows" do
      get :index
      assert_select "table td a[href='/flow-a/y/visualise']", text: "Visualise"
      assert_select "table td a[href='/flow-b/y/visualise']", text: "Visualise"
    end

    should "render links to code" do
      get :index
      assert_select "table td a[href='https://www.github.com/alphagov/smart-answers/blob/master/lib/smart_answer_flows/flow-a.rb']", text: "Definition"
      assert_select "table td a[href='https://www.github.com/alphagov/smart-answers/blob/master/lib/smart_answer_flows/flow-a']", text: "Content files"

      assert_select "table td a[href='https://www.github.com/alphagov/smart-answers/blob/master/lib/smart_answer_flows/flow-b.rb']", text: "Definition"
      assert_select "table td a[href='https://www.github.com/alphagov/smart-answers/blob/master/lib/smart_answer_flows/flow-b']", text: "Content files"
    end
  end

  context "GET /<slug>" do
    setup do
      stub_content_store_has_item("/smart-answers-controller-sample")
    end

    should "respond with 404 if not found" do
      @registry = stub("Flow registry")
      @registry.stubs(:find).raises(SmartAnswer::FlowRegistry::NotFound)
      @controller.stubs(:flow_registry).returns(@registry)
      get :show, params: { id: "smart-answers-controller-sample" }
      assert_response :missing
    end

    should "display landing page in html if no questions answered yet" do
      get :show, params: { id: "smart-answers-controller-sample" }
      assert_select "h1", /Smart answers controller sample/
    end

    context "when a smart answer exist on the content store" do
      setup do
        @content_item = {
          base_path: "/smart-answers-controller-sample",
        }.with_indifferent_access

        ContentItemRetriever.stubs(:fetch)
          .returns(@content_item)

        get :show, params: { id: "smart-answers-controller-sample" }
      end

      should "assign response from content store" do
        assert_equal @content_item, assigns(:content_item)
      end
    end

    context "when a smart answer does not exist on the content store" do
      setup do
        ContentItemRetriever.stubs(:fetch).returns({})
        get :show, params: { id: "smart-answers-controller-sample" }
      end

      should "assign empty hash to content_item" do
        assert_equal({}, assigns(:content_item))
      end
    end

    should "not have noindex tag on landing page" do
      get :show, params: { id: "smart-answers-controller-sample" }
      assert_select "meta[name=robots][content=noindex]", count: 0
    end

    should "have cache headers set to 30 mins" do
      with_cache_control_expiry do
        get :show, params: { id: "smart-answers-controller-sample" }
        assert_equal "max-age=1800, public", @response.header["Cache-Control"]
      end
    end

    context "meta description in erb template" do
      should "be shown" do
        get :show, params: { id: "smart-answers-controller-sample" }
        assert_select "head meta[name=description]" do |meta_tags|
          assert_equal "This is a test description", meta_tags.first["content"]
        end
      end
    end

    should "display first question after starting" do
      get :show, params: { id: "smart-answers-controller-sample", started: "y" }
      assert_contains css_select("title").first.content, /Do you like chocolate?/
      assert_contains css_select("title").first.content, /Smart answers controller sample/
      assert_select ".govuk-fieldset__legend", /Do you like chocolate\?/
      assert_select "input[name=response][value=yes]"
      assert_select "input[name=response][value=no]"
    end

    should "show outcome when smart answer is complete so that 'smartanswerOutcome' JS event is fired" do
      get :show, params: { id: "smart-answers-controller-sample", started: "y", responses: "yes" }
      assert_contains css_select("title").first.content, /sweet-tooth-outcome-title/
      assert_contains css_select("title").first.content, /Smart answers controller sample/
      assert_select ".outcome"
    end

    should "show default outcome title when none is supplied" do
      get :show, params: { id: "smart-answers-controller-sample", started: "y", responses: %w[no no] }
      assert_contains css_select("title").first.content, /Outcome/
      assert_contains css_select("title").first.content, /Smart answers controller sample/
      assert_select ".outcome"
    end

    should "have meta robots noindex on question pages" do
      get :show, params: { id: "smart-answers-controller-sample", started: "y" }
      assert_select "head meta[name=robots][content=noindex]"
    end

    should "accept responses as GET params and redirect to canonical url" do
      submit_response "yes"
      assert_redirected_to "/smart-answers-controller-sample/y/yes"
    end

    context "a response has been accepted" do
      setup do
        get :show, params: { id: "smart-answers-controller-sample", started: "y", responses: "no" }
      end

      should "show response summary" do
        assert_select ".govuk-table", /Do you like chocolate\?\s+No/
      end

      should "show the next question" do
        assert_select "#current-question", /Do you like jam\?/
      end
    end

    context "debugging" do
      should "render debug information on the page when enabled" do
        @controller.stubs(:debug?).returns(true)
        get :show, params: { id: "smart-answers-controller-sample", started: "y", responses: "no", debug: "1" }

        assert_select "pre.debug"
      end

      should "not render debug information on the page when not enabled" do
        @controller.stubs(:debug?).returns(false)
        get :show, params: { id: "smart-answers-controller-sample", started: "y", responses: "no", debug: nil }

        assert_select "pre.debug", false, "The page should not render debug information"
      end
    end
  end

  context "GET /<slug>/visualise" do
    should "display the visualisation" do
      stub_content_store_has_item("/smart-answers-controller-sample")

      get :visualise, params: { id: "smart-answers-controller-sample" }

      assert_select "h1", /Smart answers controller sample/
    end
  end

  context "GET /<slug>/visualise.gz" do
    should "display the visualisation in graphviz format" do
      stub_content_store_has_item("/smart-answers-controller-sample")

      get :visualise, format: :gv, params: { id: "smart-answers-controller-sample" }

      assert_equal "text/vnd.graphviz", response.media_type
      assert_match "digraph", response.body
    end
  end
end
