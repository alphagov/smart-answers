require_relative "../test_helper"
require_relative "smart_answers_controller_test_helper"

class SmartAnswersControllerTest < ActionController::TestCase
  include SmartAnswersControllerTestHelper

  setup { setup_fixture_flows }
  teardown { teardown_fixture_flows }

  context "GET /" do
    setup do
      @flow_a = stub(name: "flow-a",
                     class: stub(name: "FlowA"),
                     status: :published,
                     questions: stub(count: 2),
                     outcomes: stub(count: 3),
                     start_node: stub(presenter: stub(title: "Flow A")))

      @flow_b = stub(name: "flow-b",
                     class: stub(name: "FlowB"),
                     status: :draft,
                     questions: stub(count: 3),
                     outcomes: stub(count: 0),
                     start_node: stub(presenter: stub(title: "Flow B")))

      registry = stub("Flow registry")
      registry.stubs(:flows).returns([@flow_b, @flow_a])
      @controller.stubs(:flow_registry).returns(registry)
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
      assert_select "table td a[href='https://www.github.com/alphagov/smart-answers/blob/main/app/flows/flow_a.rb']", text: "Definition"
      assert_select "table td a[href='https://www.github.com/alphagov/smart-answers/blob/main/app/flows/flow_a']", text: "Content files"

      assert_select "table td a[href='https://www.github.com/alphagov/smart-answers/blob/main/app/flows/flow_b.rb']", text: "Definition"
      assert_select "table td a[href='https://www.github.com/alphagov/smart-answers/blob/main/app/flows/flow_b']", text: "Content files"
    end
  end

  context "GET /<slug>" do
    should "respond with 404 if not found" do
      @registry = stub("Flow registry")
      @registry.stubs(:find).raises(SmartAnswer::FlowRegistry::NotFound)
      @controller.stubs(:flow_registry).returns(@registry)
      get :show, params: { id: "radio-sample" }
      assert_response :missing
    end

    context "when a smart answer exist on the content store" do
      setup do
        @content_item = {
          base_path: "/radio-sample",
        }.with_indifferent_access

        ContentItemRetriever.stubs(:fetch)
          .returns(@content_item)

        get :show, params: { id: "radio-sample" }
      end

      should "assign response from content store" do
        assert_equal @content_item, assigns(:content_item)
      end
    end

    context "when a smart answer does not exist on the content store" do
      setup do
        ContentItemRetriever.stubs(:fetch).returns({})
        get :show, params: { id: "radio-sample" }
      end

      should "assign empty hash to content_item" do
        assert_equal({}, assigns(:content_item))
      end
    end

    should "display first question after starting" do
      get :show, params: { id: "radio-sample", started: "y" }
      assert_contains css_select("title").first.content, /Hotter or colder\?/
      assert_contains css_select("title").first.content, /Sample radio question/
      assert_select ".govuk-fieldset__legend", /Hotter or colder\?/
      assert_select "input[name=response][value=hotter]"
      assert_select "input[name=response][value=colder]"
    end

    should "show outcome when smart answer is complete so that 'smartanswerOutcome' JS event is fired" do
      get :show, params: { id: "radio-sample", started: "y", responses: "hotter" }
      assert_contains css_select("title").first.content, /Hot outcome title/
      assert_contains css_select("title").first.content, /Sample radio question/
      assert_select ".outcome"
    end

    should "show default outcome title when none is supplied" do
      get :show, params: { id: "radio-sample", started: "y", responses: "colder/no" }
      assert_contains css_select("title").first.content, /Outcome/
      assert_contains css_select("title").first.content, /Sample radio question/
      assert_select ".outcome"
    end

    should "have meta robots noindex on question pages" do
      get :show, params: { id: "radio-sample", started: "y" }
      assert_select "head meta[name=robots][content=noindex]"
    end

    should "accept responses as GET params and redirect to canonical path" do
      submit_response "hotter"
      assert_redirected_to "/radio-sample/y/hotter"
    end

    context "a response has been accepted" do
      setup do
        get :show, params: { id: "radio-sample", started: "y", responses: "colder" }
      end

      should "show response summary" do
        assert_select ".govuk-summary-list", /Hotter or colder\?\s+Colder/
      end

      should "show the next question" do
        assert_select "#current-question", /Frozen\?/
      end

      should "link back to change the response" do
        assert_select ".govuk-summary-list__actions a", /Change/ do |link_nodes|
          assert_equal "/radio-sample/y?previous_response=colder", link_nodes.first["href"]
        end
      end
    end

    context "flow response store is query parameters" do
      should "redirect to the query parameter url" do
        get :show, params: { id: "query-parameters-based", started: "y", responses: "response1" }
        assert_redirected_to "/query-parameters-based/question2?question1=response1"
      end

      should "redirect to the query parameter url for first question" do
        get :show, params: { id: "query-parameters-based", started: "y" }
        assert_redirected_to "/query-parameters-based/question1"
      end

      should "redirect to the query parameter url with correct question branching" do
        get :show, params: { id: "query-parameters-based", started: "y", responses: "response3" }
        assert_redirected_to "/query-parameters-based/question3?question1=response3"
      end
    end

    context "debugging" do
      should "render debug information on the page when enabled" do
        @controller.stubs(:debug?).returns(true)
        get :show, params: { id: "radio-sample", started: "y", responses: "no", debug: "1" }

        assert_select "pre.debug"
      end

      should "not render debug information on the page when not enabled" do
        @controller.stubs(:debug?).returns(false)
        get :show, params: { id: "radio-sample", started: "y", responses: "no", debug: nil }

        assert_select "pre.debug", false, "The page should not render debug information"
      end
    end
  end

  context "GET /<slug>/visualise" do
    should "display the visualisation" do
      stub_content_store_has_item("/radio-sample")

      get :visualise, params: { id: "radio-sample" }

      assert_contains css_select("title").first.content, /Sample radio question/
      assert_select "h1", /Sample radio question/
    end
  end

  context "GET /<slug>/visualise.gz" do
    should "display the visualisation in graphviz format" do
      stub_content_store_has_item("/radio-sample")

      get :visualise, format: :gv, params: { id: "radio-sample" }

      assert_equal "text/vnd.graphviz", response.media_type
      assert_match "digraph", response.body
    end
  end
end
