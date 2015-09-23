
require_relative '../../test_helper'

module SmartdownAdapter
  class RegistryTest < ActiveSupport::TestCase

    def test_options
      {
        smartdown_load_path: Rails.root.join("test", "fixtures", "smartdown_flows").to_s,
        show_drafts: true
      }
    end

    test "constructor is private" do
      assert_raises NoMethodError do
        SmartdownAdapter::Registry.new
      end
    end
    test "registry is a singleton" do
      SmartdownAdapter::Registry.reset_instance
      a, b = SmartdownAdapter::Registry.instance, SmartdownAdapter::Registry.instance
      assert_equal a, b
    end
    test "flows are loaded dynamically depending on registry options" do
      SmartdownAdapter::Registry.reset_instance
      instance = SmartdownAdapter::Registry.instance(test_options)
      flow1 = instance.find("animal-example-simple")
      flow2 = instance.find("animal-example-simple")
      assert_equal Smartdown::Api::Flow, flow1.class
      assert_equal Smartdown::Api::Flow, flow2.class
      refute_equal flow1, flow2
    end
    test "flows are cacheable depending on registry options" do
      SmartdownAdapter::Registry.reset_instance
      instance = SmartdownAdapter::Registry.instance(test_options.merge(preload_flows: true))
      flow1 = instance.find("animal-example-simple")
      flow2 = instance.find("animal-example-simple")
      assert_equal Smartdown::Api::Flow, flow1.class
      assert_equal Smartdown::Api::Flow, flow2.class
      assert_equal flow1, flow2
    end
    test "flows method includes and excludes drafts by config" do
      SmartdownAdapter::Registry.reset_instance
      instance = SmartdownAdapter::Registry.instance(test_options.merge(show_drafts: true))
      assert instance.flows.any? { |flow| flow.name == 'animal-example-simple' }

      SmartdownAdapter::Registry.reset_instance
      instance = SmartdownAdapter::Registry.instance(test_options.merge(show_drafts: false))
      refute instance.flows.any? { |flow| flow.name == 'animal-example-simple' }

      SmartdownAdapter::Registry.reset_instance
      instance = SmartdownAdapter::Registry.instance(test_options.merge(show_drafts: false, preload_flows: true))
      refute instance.flows.any? { |flow| flow.name == 'animal-example-simple' }
    end
  end
end
