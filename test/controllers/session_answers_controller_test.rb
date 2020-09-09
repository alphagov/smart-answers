require "test_helper"

class SessionAnswersControllerTest < ActionDispatch::IntegrationTest
  def flow_name
    :coronavirus_find_support
  end

  def nodes
    %i[need_help_with? afford_food?]
  end

  context "GET /:id/:node_name" do
    setup do
      get session_flow_path(id: flow_name, node_name: nodes[0])
    end

    should "be successful" do
      assert_response :success
    end

    should "render correct page" do
      assert_match(/What do you need help with because of coronavirus?/, response.body)
    end
  end

  def params
    { "response" => %w[getting_food], "next" => "1" }
  end

  context "GET /:id/:node_name/next" do
    setup do
      get update_session_flow_path(id: flow_name, node_name: nodes[0]), params: params
    end

    should "redirect to next node" do
      assert_redirected_to(session_flow_path(id: flow_name, node_name: nodes[1]))
    end
  end

  context "GET /:id/:node_name/next with error submission" do
    setup do
      get update_session_flow_path(id: flow_name, node_name: nodes[0]), params: { "response" => [], "next" => "1" }
    end

    should "redirect back to show" do
      assert_redirected_to(session_flow_path(id: flow_name, node_name: nodes[0]))
    end

    should "display error" do
      follow_redirect!
      assert_match(/govuk-error-message/, response.body)
    end
  end
end
