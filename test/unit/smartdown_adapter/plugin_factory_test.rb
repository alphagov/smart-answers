require 'test_helper'
require 'smartdown_adapter/plugin_factory'

module SmartdownAdapter
  class PluginFactoryTest < ActiveSupport::TestCase
    module ExampleIncludedPlugins
      def self.included_method_based_plugin(arg_1)
        arg_1 * 30
      end
    end

    module ExamplePlugins
      include ExampleIncludedPlugins

      def self.method_based_plugin(arg_1)
        arg_1 * 10
      end
    end

    SmartdownAdapter::PluginFactory.add_plugin_module('flow-with-plugins', :render_time, ExamplePlugins)

    def get_processed_render_time_plugins
      SmartdownAdapter::PluginFactory.for('flow-with-plugins')[:render_time]
    end

    test "the plugin should have been added and should be retreivable with .for" do
      refute SmartdownAdapter::PluginFactory.for('flow-with-plugins').nil?
    end

    test "plugins should be exposed as members of the plugin set by the method name as a string" do
      assert_equal 100, get_processed_render_time_plugins['method_based_plugin'].call(10)
    end

    test "plugins defined in included modules are also included in the plugin set" do
      refute get_processed_render_time_plugins['included_method_based_plugin'].nil?
    end
  end

  class PluginFactoryTestWithFileFixtures < ActiveSupport::TestCase
    # Uses fixtures in /test/fixtures/smartdown_plugins

    setup do
      SmartdownAdapter::PluginFactory.stubs(:plugin_path).returns(Rails.root.join('test/fixtures/smartdown_plugins'))
      SmartdownAdapter::PluginFactory.stubs(:extendable_path).returns(Rails.root.join('test/fixtures/smartdown_plugins/shared'))
    end

    def plugins_for_factory_test
      SmartdownAdapter::PluginFactory.for('plugin-factory-test')
    end

    test "When calling .for with a slug the factory does not yet know about, it should look in the plugin_path for an appropriatly named file and add the contained module" do
      refute SmartdownAdapter::PluginFactory.for('plugin-factory-test')[:render_time]['test_method'].nil?
    end

    test "when a module file isn't present, it should return an empty hash" do
      SmartdownAdapter::PluginFactory.for('not-a-slug').each do |plugin_type, plugin|
        assert_equal({}, plugin)
      end
    end

    test "when a module file is present but doesn't define a module with the corresponding name, it should raise an exception" do
      assert_raises(SmartdownAdapter::PluginFactory::PluginModuleNotDefined) do
        SmartdownAdapter::PluginFactory.for('plugin-factory-test-without-correct-module')
      end
    end

    test "should ignore other modules in plugin definintion files" do
      plugins_for_factory_test[:render_time]['unwanted_method'].nil?
    end

    test "should include methods from includeable that have been called with extend" do
      refute plugins_for_factory_test[:render_time]['includeable_method'].nil?
    end

    test "plugins are returned as a hash depending on their type" do
      plugins = SmartdownAdapter::PluginFactory.for('plugin-factory-test')
      SmartdownAdapter::PluginFactory::TYPES_OF_PLUGIN.each do |plugin_type|
        refute plugins[plugin_type].nil?
      end
    end
  end
end
