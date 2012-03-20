# coding:utf-8

require_relative '../test_helper'

module SmartAnswer
  class FlowRegistryTest < ActiveSupport::TestCase
    def registry(options={})
      FlowRegistry.new(options.merge(load_path: File.dirname(__FILE__) + '/../fixtures/'))
    end

    test "Can load a flow from a file" do
      flow = registry.find('flow_sample')
      assert_equal 1, flow.questions.size
      assert_equal :hotter_or_colder?, flow.questions.first.name
      assert_equal %w{hotter colder}, flow.questions.first.options
      assert_equal [:hot, :cold], flow.outcomes.map(&:name)
    end

    test "Raises NotFound error if file not found" do
      assert_raises FlowRegistry::NotFound do
        registry.find("/etc/passwd")
      end
    end

    test "should raise NotFound error for draft flow if show_drafts is not specified" do
      assert_raises FlowRegistry::NotFound do
        registry(show_drafts: false).find("draft_flow_sample")
      end
    end

    test "should find draft flow if show_drafts is specified" do
      assert registry(show_drafts: true).find("draft_flow_sample")
    end

    test "Should enumerate all flows" do
      flows = registry.flows
      assert_kind_of Enumerable, flows
      assert_kind_of Flow, flows.first
      assert_equal "flow_sample", flows.first.name
    end
  end
end
