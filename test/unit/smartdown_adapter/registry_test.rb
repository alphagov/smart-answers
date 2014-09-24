# coding:utf-8

require_relative '../../test_helper'

module SmartdownAdapter
  class RegistryTest < ActiveSupport::TestCase
    
    def test_options
      {
        load_path: Rails.root.join("test", "fixtures", "smartdown_flows").to_s,
        show_drafts: true
      }
    end

    def reset_registry(options={})
      SmartdownAdapter::Registry.reset_instance
      silence_warnings do
        SmartdownAdapter::Registry.const_set(:FLOW_REGISTRY_OPTIONS, test_options.merge(options))    
      end
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
      reset_registry
      flow1 = SmartdownAdapter::Registry.instance.find("animal-example-simple")            
      flow2 = SmartdownAdapter::Registry.instance.find("animal-example-simple")
      assert_equal Smartdown::Api::Flow, flow1.class
      assert_equal Smartdown::Api::Flow, flow2.class
      refute_equal flow1, flow2
    end
    test "flows are cacheable depending on registry options" do
      reset_registry(preload_flows: true)
      flow1 = SmartdownAdapter::Registry.instance.find("animal-example-simple")            
      flow2 = SmartdownAdapter::Registry.instance.find("animal-example-simple")
      assert_equal Smartdown::Api::Flow, flow1.class
      assert_equal Smartdown::Api::Flow, flow2.class
      assert_equal flow1, flow2
    end
    test "flows method includes and excludes drafts by config" do
      reset_registry(show_drafts: true)
      flows = SmartdownAdapter::Registry.instance.flows
      assert_equal 1,  flows.size
      assert_kind_of Enumerable, flows 
      reset_registry(show_drafts: false)
      assert_empty  SmartdownAdapter::Registry.instance.flows
      reset_registry(show_drafts: false, preload_flows: true)
      assert_empty  SmartdownAdapter::Registry.instance.flows
    end
  end
end
