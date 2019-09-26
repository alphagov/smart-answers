require_relative "../test_helper"
require_relative "../helpers/fixture_flows_helper"
require_relative "../fixtures/smart_answer_flows/smart-answers-controller-sample"

class SmartAnswersControllerDebugTemplatePathTest < ActionController::TestCase
  tests SmartAnswersController

  include FixtureFlowsHelper

  def setup
    setup_fixture_flows
    registry = SmartAnswer::FlowRegistry.instance
    flow_name = "smart-answers-controller-sample"
    @template_directory = registry.load_path.join(flow_name)

    stub_smart_answer_in_content_store("smart-answers-controller-sample")
  end

  def teardown
    teardown_fixture_flows
  end

  context "rendering landing page" do
    setup do
      get :show, params: { id: "smart-answers-controller-sample" }
    end

    should "include element with debug-template-path data attribute" do
      template_name = "smart_answers_controller_sample.govspeak.erb"
      template_path = relative_template_path(template_name)
      assert_select "*[data-debug-template-path=?]", template_path
    end
  end

  context "rendering question page" do
    setup do
      get :show, params: { id: "smart-answers-controller-sample", started: "y" }
    end

    should "include element with debug-template-path data attribute" do
      template_name = "questions/do_you_like_chocolate.govspeak.erb"
      template_path = relative_template_path(template_name)
      assert_select "*[data-debug-template-path=?]", template_path
    end
  end

  context "rendering outcome page" do
    setup do
      get :show, params: { id: "smart-answers-controller-sample", started: "y", responses: "yes" }
    end

    should "include element with debug-template-path data attribute" do
      template_name = "outcomes/you_have_a_sweet_tooth.govspeak.erb"
      template_path = relative_template_path(template_name)
      assert_select "*[data-debug-template-path=?]", template_path
    end
  end

  def relative_template_path(template_name)
    @template_directory.join(template_name).relative_path_from(Rails.root).to_s
  end
end
