require_relative "../test_helper"

class SessionResponseStoreTest < ActiveSupport::TestCase
  context "#all" do
    should "return hash of keys and responses for flow" do
      session = { "flow" => { "key" => "value", "key2" => "value2" } }
      response_store = SessionResponseStore.new(flow_name: "flow", session:)

      assert_equal({ "key" => "value", "key2" => "value2" }, response_store.all)
    end
  end

  context "#add" do
    should "add response to empty store" do
      session = {}
      response_store = SessionResponseStore.new(flow_name: "flow", session:)
      response_store.add("key", "value")

      assert_equal "value", session.dig("flow", "key")
    end

    should "replace existing entry" do
      session = { "flow" => { "key" => "another_value" } }
      response_store = SessionResponseStore.new(flow_name: "flow", session:)
      response_store.add("key", "value")

      assert_equal "value", session.dig("flow", "key")
    end
  end

  context "#get" do
    should "get value of key" do
      session = { "flow" => { "key" => "value" } }
      response_store = SessionResponseStore.new(flow_name: "flow", session:)

      assert_equal "value", response_store.get("key")
    end
  end

  context "#clear" do
    should "remove entries from session" do
      session = { "flow" => { "key" => "value" } }
      response_store = SessionResponseStore.new(flow_name: "flow", session:)
      response_store.clear

      assert_equal({}, session)
    end

    should "not change other data in session" do
      session = { "flow" => { "key" => "value" }, "flow-2" => { "key" => "value" } }
      response_store = SessionResponseStore.new(flow_name: "flow", session:)
      response_store.clear

      assert_equal({ "flow-2" => { "key" => "value" } }, session)
    end
  end

  context "#forwarding_responses" do
    should "return empty hash" do
      session = { "flow" => { "key" => "value" } }
      response_store = SessionResponseStore.new(flow_name: "flow", session:)

      assert_equal({}, response_store.forwarding_responses)
    end
  end
end
