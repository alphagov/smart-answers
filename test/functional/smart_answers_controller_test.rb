require_relative '../test_helper'
require_relative '../helpers/fixture_flows_helper'
require_relative '../fixtures/smart_answer_flows/smart-answers-controller-sample'
require_relative 'smart_answers_controller_test_helper'

class SmartAnswersControllerTest < ActionController::TestCase
  include FixtureFlowsHelper
  include SmartAnswersControllerTestHelper
  include GovukAbTesting::MinitestHelpers

  def setup
    setup_fixture_flows
    stub_shared_component_locales
  end

  def teardown
    teardown_fixture_flows
  end

  context "GET /" do
    setup do
      @flow_a = stub("flow", name: "flow-a")
      @flow_b = stub("flow", name: "flow-b")
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
      assert_select "ul li a[href='/flow-a']", text: "flow-a"
      assert_select "ul li a[href='/flow-b']", text: "flow-b"
    end

    should "render links to visualise flows" do
      get :index
      assert_select "ul li a[href='/flow-a/visualise']", text: "visualise"
      assert_select "ul li a[href='/flow-b/visualise']", text: "visualise"
    end
  end

  context "GET /<slug>" do
    setup do
      stub_smart_answer_in_content_store("smart-answers-controller-sample")
    end

    should "respond with 404 if not found" do
      @registry = stub("Flow registry")
      @registry.stubs(:find).raises(SmartAnswer::FlowRegistry::NotFound)
      @controller.stubs(:flow_registry).returns(@registry)
      get :show, params: { id: 'smart-answers-controller-sample' }
      assert_response :missing
    end

    should "display landing page in html if no questions answered yet" do
      get :show, params: { id: 'smart-answers-controller-sample' }
      assert_select "h1", /Smart answers controller sample/
    end

    context "when a smart answer exist on the content store" do
      setup do
        @content_item = {
            base_path: "/smart-answers-controller-sample",
            links: {
              taxons: [
                {
                  title: "A Taxon",
                  base_path: "/a-taxon",
                }
              ],
            },
          }.with_indifferent_access
        ContentItemRetriever.stubs(:without_links_organisations)
          .returns(@content_item)
        get :show, params: { id: "smart-answers-controller-sample" }
      end

      should "assign response from content store" do
        assert_equal @content_item, assigns(:content_item)
      end

      should "assign navigation_helpers" do
        assert_kind_of GovukNavigationHelpers::NavigationHelper, assigns(:navigation_helpers)
      end
    end

    context "when a smart answer does not exist on the content store" do
      setup do
        ContentItemRetriever.stubs(:without_links_organisations).returns({})
        get :show, params: { id: "smart-answers-controller-sample" }
      end

      should "assign empty hash to content_item" do
        assert_equal Hash.new, assigns(:content_item)
      end

      should "assign nil to navigation_helpers" do
        assert_nil assigns(:navigation_helpers)
      end
    end

    should "not have noindex tag on landing page" do
      get :show, params: { id: 'smart-answers-controller-sample' }
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
        get :show, params: { id: 'smart-answers-controller-sample' }
        assert_select "head meta[name=description]" do |meta_tags|
          assert_equal 'This is a test description', meta_tags.first['content']
        end
      end
    end

    should "display first question after starting" do
      get :show, params: { id: 'smart-answers-controller-sample', started: 'y' }
      assert_select ".step.current [data-test=question]", /Do you like chocolate\?/
      assert_select "input[name=response][value=yes]"
      assert_select "input[name=response][value=no]"
    end

    should "show outcome when smart answer is complete so that 'smartanswerOutcome' JS event is fired" do
      get :show, params: { id: 'smart-answers-controller-sample', started: 'y', responses: 'yes' }
      assert_select ".outcome"
    end

    should "have meta robots noindex on question pages" do
      get :show, params: { id: 'smart-answers-controller-sample', started: 'y' }
      assert_select "head meta[name=robots][content=noindex]"
    end

    should "accept responses as GET params and redirect to canonical url" do
      submit_response "yes"
      assert_redirected_to '/smart-answers-controller-sample/y/yes'
    end

    context "a response has been accepted" do
      setup do
        get :show, params: { id: 'smart-answers-controller-sample', started: 'y', responses: "no" }
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

    context "format=txt" do
      should "render govspeak text for outcome node" do
        document = stub('Govspeak::Document', to_html: 'html-output')
        Govspeak::Document.stubs(:new).returns(document)

        get :show, params: { id: 'smart-answers-controller-sample', started: 'y', responses: "yes", format: "txt" }

        assert_match(/sweet-tooth-outcome-title/, response.body)
        assert_match(/sweet-tooth-outcome-govspeak-body/, response.body)
        assert_match(/sweet-tooth-outcome-govspeak-next-steps/, response.body)
      end

      should "render govspeak text for the landing page" do
        get :show, params: { id: 'smart-answers-controller-sample', format: 'txt' }
        assert response.body.start_with?("Smart answers controller sample")
      end

      should "render govspeak text for a question node" do
        document = stub('Govspeak::Document', to_html: 'html-output')
        Govspeak::Document.stubs(:new).returns(document)

        get :show, params: { id: 'smart-answers-controller-sample', started: 'y', format: "txt" }
        assert_match(/Do you like chocolate\?/, response.body)
        assert_match(/yes\: Yes/, response.body)
        assert_match(/no\: No/, response.body)
      end

      context "when Rails.application.config.expose_govspeak is not set" do
        setup do
          Rails.application.config.stubs(:expose_govspeak).returns(false)
        end

        should "render not found" do
          get :show, params: { id: 'smart-answers-controller-sample', started: 'y', responses: "yes", format: "txt" }

          assert_response :missing
        end
      end
    end

    context "debugging" do
      should "render debug information on the page when enabled" do
        @controller.stubs(:debug?).returns(true)
        get :show, params: { id: 'smart-answers-controller-sample', started: 'y', responses: "no", debug: "1" }

        assert_select "pre.debug"
      end

      should "not render debug information on the page when not enabled" do
        @controller.stubs(:debug?).returns(false)
        get :show, params: { id: 'smart-answers-controller-sample', started: 'y', responses: "no", debug: nil }

        assert_select "pre.debug", false, "The page should not render debug information"
      end
    end

    context "A/B testing" do
      context "pages under A/B test" do
        setup do
          content_item = {
            "base_path" => '/education-sample',
            "links" => {
              "taxons" => [
                {
                  "title" => "A Taxon",
                  "base_path" => "/a-taxon",
                }
              ],
            },
          }

          Services.content_store.stubs(:content_item)
            .with("/education-sample")
            .returns(content_item)

          navigation_helper = GovukNavigationHelpers::NavigationHelper.new(content_item)
          navigation_helper.stubs(:breadcrumbs).returns(breadcrumbs: ['NormalBreadcrumb'])
          navigation_helper.stubs(:taxon_breadcrumbs).returns(breadcrumbs: ['TaxonBreadcrumb'])
          GovukNavigationHelpers::NavigationHelper.stubs(:new)
            .with(content_item)
            .returns(navigation_helper)
        end

        should "show normal breadcrumbs by default" do
          get :show, params: { id: 'education-sample' }

          assert_match(/NormalBreadcrumb/, response.body)
          refute_match(/TaxonBreadcrumb/, response.body)
          sidebar = Nokogiri::HTML.parse(response.body).at_css(".related-container")
          refute_match(/A Taxon/, sidebar)
        end

        should "show normal breadcrumbs for the 'A' version" do
          with_variant EducationNavigation: "A" do
            get :show, params: { id: 'education-sample' }

            assert_match(/NormalBreadcrumb/, response.body)
            refute_match(/TaxonBreadcrumb/, response.body)
            sidebar = Nokogiri::HTML.parse(response.body).at_css(".related-container")
            refute_match(/A Taxon/, sidebar)
          end
        end

        should "show taxon breadcrumbs for the 'B' version" do
          with_variant EducationNavigation: "B" do
            get :show, params: { id: 'education-sample' }

            assert_match(/TaxonBreadcrumb/, response.body)
            refute_match(/NormalBreadcrumb/, response.body)
            sidebar = Nokogiri::HTML.parse(response.body).at_css(".related-container")
            assert_match(/A Taxon/, sidebar)
          end
        end
      end

      context "pages outside the A/B test" do
        %w(A B).each do |variant|
          should "not modify response when visited in #{variant} variant" do
            stub_smart_answer_in_content_store("smart-answers-controller-sample")

            setup_ab_variant("EducationNavigation", variant)

            get :show, params: { id: 'smart-answers-controller-sample' }

            assert_response_not_modified_for_ab_test('EducationNavigation')
          end
        end
      end
    end
  end

  context "GET /<slug>/visualise" do
    should "display the visualisation" do
      stub_smart_answer_in_content_store("smart-answers-controller-sample")

      get :visualise, params: { id: 'smart-answers-controller-sample' }

      assert_select "h1", /Smart answers controller sample/
    end
  end
end
