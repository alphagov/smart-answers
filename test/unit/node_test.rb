require_relative '../test_helper'

module SmartAnswer
  class NodeTest < ActiveSupport::TestCase
    setup do
      @flow = Flow.new
      @node = Outcome.new(@flow, 'node-name')
      @load_path = FlowRegistry.instance.load_path
    end

    test '#template_directory returns flows load path if flow has no name' do
      assert_equal Pathname.new(@load_path), @node.template_directory
    end

    test '#template_directory returns the path to the templates belonging to the flow' do
      @flow.name('flow-name')

      expected_directory = Pathname.new(@load_path).join('flow-name')
      assert_equal expected_directory, @node.template_directory
    end
  end
end
