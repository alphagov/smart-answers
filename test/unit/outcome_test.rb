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

    test '#flow_name returns nil by default' do
      outcome = Outcome.new('outcome-name')
      assert_equal nil, outcome.flow_name
    end

    test '#flow_name returns the flow name specified in the options' do
      outcome_options = { flow_name: 'flow-name' }
      outcome = Outcome.new('outcome-name', outcome_options)

      assert_equal 'flow-name', outcome.flow_name
    end
  end
end
