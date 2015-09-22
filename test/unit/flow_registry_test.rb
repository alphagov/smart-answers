# coding:utf-8

require_relative '../test_helper'

module SmartAnswer
  class FlowRegistryTest < ActiveSupport::TestCase
    def registry(options = {})
      FlowRegistry.new(options.merge(smart_answer_load_path: File.expand_path('../../fixtures/', __FILE__)))
    end

    test "Can load a flow from a file" do
      flow = registry.find('flow-sample')
      assert_equal 2, flow.questions.size
      assert_equal :hotter_or_colder?, flow.questions.first.name
      assert_equal %w{hotter colder}, flow.questions.first.options
      assert_equal [:hot, :cold, :frozen], flow.outcomes.map(&:name)
    end

    test "Raises NotFound error if file not found" do
      assert_raises FlowRegistry::NotFound do
        registry.find("/etc/passwd")
      end
    end

    test "should raise NotFound error for draft flow if show_drafts is not specified" do
      assert_raises FlowRegistry::NotFound do
        registry(show_drafts: false).find("draft-flow-sample")
      end
    end

    test "should find draft flow if show_drafts is specified" do
      assert registry(show_drafts: true).find("draft-flow-sample")
    end

    test "Should enumerate all flows" do
      flows = registry.flows
      assert_kind_of Enumerable, flows
      assert_kind_of Flow, flows.first
      assert_equal "flow-sample", flows.first.name
    end

    context "without preloaded flows" do
      setup do
        @r = registry
      end

      should "build a new flow instance each time" do
        first_call = registry.find('flow-sample')
        second_call = registry.find('flow-sample')

        assert_equal first_call.name, second_call.name
        refute_equal first_call.object_id, second_call.object_id
      end
    end

    context "with preloaded flows" do
      setup do
        @r = registry(preload_flows: true)
      end

      should "not hit the filesystem when finding a flow" do
        Dir.expects(:[]).never
        File.expects(:read).never

        assert @r.find('flow-sample').is_a?(Flow)
      end

      should "not hit the filesystem when finding a non-existent flow" do
        Dir.expects(:[]).never
        File.expects(:read).never

        assert_raises FlowRegistry::NotFound do
          @r.find('non_existent')
        end
      end
    end
  end
end
