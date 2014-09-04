# coding:utf-8

require_relative '../../test_helper'

module SmartdownAdapter
  class RegistryTest < ActiveSupport::TestCase
    setup do
      @registry_options = { load_path: Rails.root.join("test", "fixtures", "smartdown_flows").to_s, show_drafts: true }
    end

    test "constructor is private" do
      assert_raises NoMethodError do
        SmartdownAdapter::Registry.new
      end
    end
    test "registry is a singleton" do
      a, b = SmartdownAdapter::Registry.instance, SmartdownAdapter::Registry.instance
      assert_equal a, b
    end
    test "flows are loaded dynamically depending on registry options" do
      SmartdownAdapter::Registry.reset_instance
      silence_warnings do
        SmartdownAdapter::Registry::FLOW_REGISTRY_OPTIONS = @registry_options      
      end
      flow1 = SmartdownAdapter::Registry.instance.find("animal-example-simple")            
      flow2 = SmartdownAdapter::Registry.instance.find("animal-example-simple")
      refute_equal flow1, flow2
    end
    test "flows are cacheable depending on registry options" do
      SmartdownAdapter::Registry.reset_instance
      silence_warnings do
        SmartdownAdapter::Registry::FLOW_REGISTRY_OPTIONS = @registry_options.merge(preload_flows: true)      
      end
      flow1 = SmartdownAdapter::Registry.instance.find("animal-example-simple")            
      flow2 = SmartdownAdapter::Registry.instance.find("animal-example-simple")
      assert_equal flow1, flow2
    end
  end
end
