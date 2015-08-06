require_relative '../test_helper'
require_relative '../../lib/smartdown_adapter/registry.rb'
require_relative '../../lib/smart_answer/flow_registry.rb'

class DuplicateFlowTest < Minitest::Test
  def setup
    @original = FLOW_REGISTRY_OPTIONS[:preload_flows]
    FLOW_REGISTRY_OPTIONS[:preload_flows] = false
  end

  def teardown
    FLOW_REGISTRY_OPTIONS[:preload_flows] = @original
  end

  should "Not have any smartdown and smartanswer flows with the same name" do
    SmartdownAdapter::Registry.reset_instance
    smartdown_flows = SmartdownAdapter::Registry.instance.available_flows
    smart_answer_flows = SmartAnswer::FlowRegistry.instance.available_flows
    dup_names = smartdown_flows & smart_answer_flows
    assert_equal [], dup_names
  end
end
