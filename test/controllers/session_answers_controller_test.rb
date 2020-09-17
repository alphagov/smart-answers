require "test_helper"

class SessionAnswersControllerTest < ActionDispatch::IntegrationTest
  def flow_name
    :coronavirus_find_support
  end

  def nodes
    %i[need_help_with? afford_food?]
  end

  # Session is not directly accessible in controller tests
  # So mocking session store and using expectation on that mock to test session storage
  def session_store
    @session_store ||= begin
      session_store = mock("session_store")
      session_store.stubs(:hash).returns({})
      SessionStore.stubs(:new).returns(session_store)
      session_store
    end
  end

  context "GET /:id/s" do
    setup do
      get start_session_flow_path(flow_name)
    end

    should "redirect to show first node" do
      assert_redirected_to(session_flow_path(id: flow_name, node_name: nodes[0]))
    end
  end

  context "GET /:id/s/:node_name" do
    setup do
      get session_flow_path(id: flow_name, node_name: nodes[0])
    end

    should "be successful" do
      assert_response :success
    end

    should "render correct page" do
      assert_match(/What do you need help with because of coronavirus?/, response.body)
    end

    should "set a cache-control response header" do
      assert_equal response.headers["Cache-Control"], "no-cache, no-store"
    end

    should "set a pragma response header" do
      assert_equal response.headers["Pragma"], "no-cache"
    end

    should "set an expires response header" do
      assert_equal response.headers["Expires"], "Mon, 01 Jan 1990 00:00:00 GMT"
    end
  end

  def params
    { "response" => %w[getting_food], "next" => "1" }
  end

  context "GET /:id/s/:node_name/next" do
    should "redirect to next node" do
      get update_session_flow_path(id: flow_name, node_name: nodes[0]), params: params
      assert_redirected_to(session_flow_path(id: flow_name, node_name: nodes[1]))
    end

    should "updates session" do
      session_store.expects(:add_response).with(params["response"])
      get update_session_flow_path(id: flow_name, node_name: nodes[0]), params: params
    end
  end

  context "GET /:id/s/:node_name/next with error submission" do
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

  context "GET /:id/s/destroy_session" do
    setup do
      get update_session_flow_path(id: flow_name, node_name: nodes[0]), params: params
    end

    should "redirect to external sitewhen the ext_r option is present and true" do
      get destroy_session_flow_path(id: flow_name, ext_r: "true")
      assert_redirected_to "https://bbc.co.uk/news"
    end

    should "remove the session data for the flow when escaping" do
      session_store.expects(:clear)
      get destroy_session_flow_path(id: flow_name, ext_r: "true")
    end

    should "redirect to external sitewhen the ext_r option is present and false" do
      get destroy_session_flow_path(id: flow_name, ext_r: "false")
      assert_redirected_to "/#{flow_name}"
    end

    should "redirect to external sitewhen the ext_r option is not present" do
      get destroy_session_flow_path(id: flow_name)
      assert_redirected_to "/#{flow_name}"
    end

    should "remove the session data for the flow when not escaping" do
      session_store.expects(:clear)
      get destroy_session_flow_path(id: flow_name)
    end
  end
end
