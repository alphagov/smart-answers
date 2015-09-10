require_relative '../test_helper'

module SmartAnswer
  class OutcomeTest < ActiveSupport::TestCase
    setup do
      @flow = Flow.new
      @outcome = Outcome.new(@flow, 'outcome-name')
    end

    test '#template_directory returns nil if flow has no name' do
      assert_equal nil, @outcome.template_directory
    end

    test '#template_directory returns the path to the templates belonging to the flow' do
      @flow.name('flow-name')

      load_path = FlowRegistry.instance.load_path
      expected_directory = Pathname.new(load_path).join('flow-name')
      assert_equal expected_directory, @outcome.template_directory
    end
  end
end
