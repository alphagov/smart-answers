RSpec.describe SessionResponseStore do
  context "#all" do
    it "should return hash of keys and responses for flow" do
      session = { "flow" => { "key" => "value", "key2" => "value2" } }
      response_store = SessionResponseStore.new(flow_name: "flow", session: session)

      expect(response_store.all).to eq({ "key" => "value", "key2" => "value2" })
    end
  end

  context "#add" do
    it "adds response to empty store" do
      session = {}
      response_store = SessionResponseStore.new(flow_name: "flow", session: session)
      response_store.add("key", "value")

      expect(session.dig("flow", "key")).to eq("value")
    end

    it "replace existing entry" do
      session = { "flow" => { "key" => "another_value" } }
      response_store = SessionResponseStore.new(flow_name: "flow", session: session)
      response_store.add("key", "value")

      expect(session.dig("flow", "key")).to eq("value")
    end
  end

  context "#get" do
    it "get value of key" do
      session = { "flow" => { "key" => "value" } }
      response_store = SessionResponseStore.new(flow_name: "flow", session: session)

      expect(response_store.get("key")).to eq("value")
    end
  end

  context "#clear" do
    it "remove entries from session" do
      session = { "flow" => { "key" => "value" } }
      response_store = SessionResponseStore.new(flow_name: "flow", session: session)
      response_store.clear

      expect(session).to eq({})
    end

    it "not change other data in session" do
      session = { "flow" => { "key" => "value" }, "flow-2" => { "key" => "value" } }
      response_store = SessionResponseStore.new(flow_name: "flow", session: session)
      response_store.clear

      expect(session).to eq({ "flow-2" => { "key" => "value" } })
    end
  end
end
