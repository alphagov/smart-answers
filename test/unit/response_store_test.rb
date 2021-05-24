require_relative "../test_helper"

class ResponseStoreTest < ActiveSupport::TestCase
  context "#all" do
    should "return hash of keys and responses for flow" do
      responses = { "key" => "value", "key2" => "value2" }
      response_store = ResponseStore.new(responses: responses)

      assert_equal responses, response_store.all
    end
  end

  context "#add" do
    should "add response to empty store" do
      responses = {}
      response_store = ResponseStore.new(responses: responses)
      response_store.add("key", "value")

      assert_equal "value", responses["key"]
    end

    should "replace existing entry" do
      responses = { "key" => "value" }
      response_store = ResponseStore.new(responses: responses)
      response_store.add("key", "another_value")

      assert_equal "another_value", responses["key"]
    end
  end

  context "#get" do
    should "get value of key" do
      responses = { "key" => "value" }
      response_store = ResponseStore.new(responses: responses)

      assert_equal "value", response_store.get("key")
    end
  end

  context "#clear" do
    should "remove entries from session" do
      responses = { "key" => "value" }
      response_store = ResponseStore.new(responses: responses)

      response_store.clear
      assert_equal({}, response_store.all)
    end
  end
end
