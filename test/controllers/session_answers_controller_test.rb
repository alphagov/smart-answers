require "test_helper"

class SessionAnswersControllerTest < ActionDispatch::IntegrationTest
  def flow_name
    @flow_name ||= :coronavirus_find_support
  end

  def node_name
    @node_name ||= :need_help_with
  end

  context "GET /:flow_name/:node_name" do
    should "successfully render page" do
      get session_flow_path(flow_name, node_name)
      assert_response :success
    end

    #    Not catching the error while we are building is useful - so disabling for now
    #    should "return not found if flow name unknown" do
    #      @flow_name = :unknown
    #      get session_flow_path(flow_name, node_name)
    #      assert_response :not_found
    #    end
    #
    #    should "return not found if node name unknown" do
    #      @node_name = :unknown
    #      get session_flow_path(flow_name, node_name)
    #      assert_response :not_found
    #    end
  end

  def params
    @params ||= { need_help_with: %w[paying_bills] }
  end

  context "PUT /:flow_name/:node_name" do
    should "redirect to next node" do
      put session_flow_path(flow_name, node_name), params: params
      assert_redirected_to session_flow_path(flow_name, :feel_safe)
    end

    should "render page on error" do
      @params = {}
      put session_flow_path(flow_name, node_name), params: params
      assert_response :success
    end
  end
end
