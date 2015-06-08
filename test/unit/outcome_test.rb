require_relative '../test_helper'

module SmartAnswer
  class OutcomeTest < ActiveSupport::TestCase
    test '#use_template? returns nil by default' do
      outcome = Outcome.new('outcome-name')
      assert_equal nil, outcome.use_template?
    end

    test '#use_template? returns true if we supply the use_outcome_templates option' do
      outcome_options = { use_outcome_templates: true }
      outcome = Outcome.new('outcome-name', outcome_options)

      assert_equal true, outcome.use_template?
    end

    test '#template_directory returns nil by default' do
      outcome = Outcome.new('outcome-name')
      assert_equal nil, outcome.template_directory
    end

    test '#template_directory returns the path to the templates belonging to the flow' do
      outcome_options = { flow_name: 'flow-name' }
      outcome = Outcome.new('outcome-name', outcome_options)

      load_path = FlowRegistry.instance.load_path
      expected_directory = Pathname.new(load_path).join('flow-name')
      assert_equal expected_directory, outcome.template_directory
    end
  end
end
