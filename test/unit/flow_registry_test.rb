# coding:utf-8

require_relative '../test_helper'

module SmartAnswer
  class FlowRegistryTest < ActiveSupport::TestCase
    def setup
      @registry = FlowRegistry.new(File.dirname(__FILE__) + '/../fixtures/')
    end
    
    test "Can load a flow from a file" do
      flow = @registry.find('flow_sample')
      assert_equal 1, flow.questions.size
      assert_equal :hotter_or_colder?, flow.questions.first.name
      assert_equal %w{hotter colder}, flow.questions.first.options
      assert_equal [:hot, :cold], flow.outcomes.map(&:name)
    end

    test "Raises NotFound error if file not found" do
      assert_raises FlowRegistry::NotFound do
        @registry.find("/etc/passwd")
      end
    end

  end
end
