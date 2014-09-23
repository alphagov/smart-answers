require Rails.root.join("test/fixtures/smartdown_plugins/test-global-plugins")

module SmartdownTestFixture
  module PluginFactoryTest
    include TestGlobalPlugins

    def self.test_method
    end
  end

  module OtherIrrelevantModule
    def self.unwanted_method
    end
  end
end
