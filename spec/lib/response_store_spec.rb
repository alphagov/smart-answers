RSpec.describe ResponseStore do
  context "#all" do
    it "it return hash of keys and responses for flow" do
      responses = { "key" => "value", "key2" => "value2" }
      response_store = ResponseStore.new(responses: responses)

      expect(response_store.all).to eq(responses)
    end
  end

  context "#add" do
    it "adds response to empty store" do
      responses = {}
      response_store = ResponseStore.new(responses: responses)
      response_store.add("key", "value")

      expect(responses["key"]).to eq("value")
    end

    it "replace existing entry" do
      responses = { "key" => "value" }
      response_store = ResponseStore.new(responses: responses)
      response_store.add("key", "another_value")

      expect(responses["key"]).to eq("another_value")
    end
  end

  context "#get" do
    it "get value of key" do
      responses = { "key" => "value" }
      response_store = ResponseStore.new(responses: responses)

      expect(response_store.get("key")).to eq("value")
    end
  end

  context "#clear" do
    it "remove entries from session" do
      responses = { "key" => "value" }
      response_store = ResponseStore.new(responses: responses)

      response_store.clear
      expect(response_store.all).to eq({})
    end
  end
end
