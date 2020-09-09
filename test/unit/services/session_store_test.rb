require "test_helper"

class SessionStoreTest < ActiveSupport::TestCase
  def flow_name
    @flow_name ||= :flow_name
  end

  def node_name
    @node_name ||= :node_name
  end

  def response
    @response ||= SecureRandom.uuid
  end

  def responses
    @responses ||= {}
  end

  def session
    @session ||= { flow_name => responses }
  end

  def session_store
    @session_store ||= SessionStore.new(flow_name: flow_name, current_node: node_name, session: session)
  end

  context "#add_response" do
    should "adds response to empty store" do
      session_store.add_response(response)
      assert_equal response, session.dig(flow_name, node_name)
    end

    should "replace existing entry" do
      @responses = { a: "a", node_name => "b", c: "c" }
      session_store.add_response(response)
      assert_equal response, session.dig(flow_name, node_name)
    end

    should "not alter order of responses" do
      @responses = { a: "a", node_name => "b", c: "c" }
      session_store.add_response(response)
      assert_equal [:a, node_name, :c], session[flow_name].keys
    end
  end
end
