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
    setup do
      put session_flow_path(flow_name, node_name), params: params
    end

    should "redirect to next node" do
      assert_redirected_to session_flow_path(flow_name, :afford_rent_mortgage_bills)
    end
  end

  context "PUT /:flow_name/:node_name on error" do
    setup do
      @params = {}
      put session_flow_path(flow_name, node_name), params: params
    end

    should "re-render page" do
      assert_response :success
    end

    should "display an error on element" do
      assert_match(/govuk-error-message/, response.body)
    end

    should "display an error summary" do
      assert_match(/govuk-error-summary/, response.body)
    end
  end
end
