require_relative "../test_helper"

module SmartAnswer
  class FlowRegistryTest < ActiveSupport::TestCase
    setup { require_fixture_flows }

    def registry(options = {})
      FlowRegistry.new(options.merge(smart_answer_load_path: File.expand_path("../fixtures/flows", __dir__)))
    end

    test "Can load a flow from a file" do
      flow = registry.find("radio-sample")
      assert_equal 2, flow.questions.size
      assert_equal :hotter_or_colder?, flow.questions.first.name
      assert_equal %w[hotter colder], flow.questions.first.option_keys
      assert_equal %i[hot cold frozen], flow.outcomes.map(&:name)
    end

    test "Raises NotFound error if file not found" do
      assert_raises FlowRegistry::NotFound do
        registry.find("/etc/passwd")
      end
    end

    test "Should enumerate all flows" do
      flows = registry.flows
      assert_kind_of Enumerable, flows
      assert_kind_of Flow, flows.first
    end
  end
end
