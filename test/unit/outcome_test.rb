require_relative '../test_helper'

module SmartAnswer
  class OutcomeTest < ActiveSupport::TestCase
    test '#template_directory returns nil by default' do
      outcome = Outcome.new(nil, 'outcome-name')
      assert_equal nil, outcome.template_directory
    end

    test '#template_directory returns the path to the templates belonging to the flow' do
      outcome_options = { flow_name: 'flow-name' }
      outcome = Outcome.new(nil, 'outcome-name', outcome_options)

      load_path = FlowRegistry.instance.load_path
      expected_directory = Pathname.new(load_path).join('flow-name')
      assert_equal expected_directory, outcome.template_directory
    end
  end
end
