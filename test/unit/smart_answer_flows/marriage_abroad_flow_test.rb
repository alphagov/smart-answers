require_relative '../../test_helper'
require_relative 'flow_unit_test_helper'

require 'smart_answer_flows/marriage-abroad'

module SmartAnswer
  class MarriageAbroadFlowTest < ActiveSupport::TestCase
    include FlowUnitTestHelper

    setup do
      @calculator = Calculators::MarriageAbroadCalculator.new
      @flow = MarriageAbroadFlow.build

      world_location = stub('WorldLocation',
        slug: 'afghanistan', name: 'Afghanistan', fco_organisation: nil)
      WorldLocation.stubs(:all).returns([world_location])
      WorldLocation.stubs(:find).with('afghanistan').returns(world_location)
    end

    should 'start with the country_of_ceremony? question' do
      assert_equal :country_of_ceremony?, @flow.start_state.current_node
    end

    context 'when answering country_of_ceremony? question' do
      setup do
        Calculators::MarriageAbroadCalculator.stubs(:new).returns(@calculator)
        setup_states_for_question(:country_of_ceremony?,
          responding_with: 'afghanistan')
      end

      should 'instantiate and store calculator' do
        assert_same @calculator, @new_state.calculator
      end
    end

    context 'when answering what_is_your_partners_nationality? question' do
      setup do
        Calculators::MarriageAbroadCalculator.stubs(:new).returns(@calculator)
        setup_states_for_question(:what_is_your_partners_nationality?,
          responding_with: 'partner_british', initial_state: {
            calculator: @calculator })
      end

      should 'store parsed response on calculator as partner_nationality' do
        assert_equal 'partner_british', @calculator.instance_variable_get('@partner_nationality')
      end
    end
  end
end
