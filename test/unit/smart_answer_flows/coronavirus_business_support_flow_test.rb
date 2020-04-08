require_relative "../../test_helper"
require_relative "flow_unit_test_helper"

require "smart_answer_flows/coronavirus-business-support.rb"


module SmartAnswer
  class CoronavirusBusinessSupportFlowTest < ActiveSupport::TestCase
    include FlowUnitTestHelper

    setup do
      @calculator = Calculators::CoronavirusBusinessSupportCalculator.new
      @flow = CoronavirusBusinessSupportFlow.build
    end

    should "start :business_based? question" do
      assert_equal :business_based?, @flow.start_state.current_node
    end

    context "when answering :business_based? question" do
      setup do
        Calculators::CoronavirusBusinessSupportCalculator.stubs(:new).returns(@calculator)
        setup_states_for_question(:business_based?, responding_with: "england")
      end

      should "instantiate and store calculator" do
        assert_same @calculator, @new_state.calculator
      end

      should "set :business_based? to 'england'" do
        assert_equal "england", @calculator.business_based
      end

      should "go to :business_size? question" do
        assert_equal :business_size?, @new_state.current_node
        assert_node_exists :business_size?
      end
    end

    context "when answering :business_size? question" do
      setup do
        setup_states_for_question(:business_size?,
                                  responding_with: "small_medium_enterprise",
                                  initial_state: { calculator: @calculator })
      end

      should "store 'small_medium_enterprise' on calculator" do
        assert_equal "small_medium_enterprise", @calculator.business_size
      end

      should "go to :self_employed? question" do
        assert_equal :self_employed?, @new_state.current_node
        assert_node_exists :self_employed?
      end
    end

    context "when answering :self_employed? question" do
      setup do
        setup_states_for_question(:self_employed?,
                                  responding_with: "no",
                                  initial_state: { calculator: @calculator })
      end

      should "store 'no' for :self_employed? question" do
        assert_equal "no", @calculator.self_employed
      end

      should "go to :annual_turnover? question" do
        assert_equal :annual_turnover?, @new_state.current_node
        assert_node_exists :annual_turnover?
      end
    end

    context "when answering :annual_turnover? question" do
      setup do
        setup_states_for_question(:annual_turnover?,
                                  responding_with: "over_85k",
                                  initial_state: { calculator: @calculator })
      end

      should "store 'over_85k' for :annual_turnover? question" do
        assert_equal "over_85k", @calculator.annual_turnover
      end

      should "go to :business_rates? question" do
        assert_equal :business_rates?, @new_state.current_node
        assert_node_exists :business_rates?
      end
    end

    context "when answering :business_rates? question" do
      setup do
        setup_states_for_question(:business_rates?,
                                  responding_with: "yes",
                                  initial_state: { calculator: @calculator })
      end

      should "store 'yes' for :business_rates? question" do
        assert_equal "yes", @calculator.business_rates
      end

      should "go to :non_domestic_property? question" do
        assert_equal :non_domestic_property?, @new_state.current_node
        assert_node_exists :non_domestic_property?
      end
    end

    context "when answering :non_domestic_property? question" do
      setup do
        setup_states_for_question(:non_domestic_property?,
                                  responding_with: "over_15k",
                                  initial_state: { calculator: @calculator })
      end

      should "store 'over_15k' for :non_domestic_property? question" do
        assert_equal "over_15k", @calculator.non_domestic_property
      end

      should "go to :self_assessment_july_2020? question" do
        assert_equal :self_assessment_july_2020?, @new_state.current_node
        assert_node_exists :self_assessment_july_2020?
      end
    end

    context "when answering :self_assessment_july_2020? question" do
      setup do
        setup_states_for_question(:self_assessment_july_2020?,
                                  responding_with: "no",
                                  initial_state: { calculator: @calculator })
      end

      should "store 'no' for :self_assessment_july_2020? question" do
        assert_equal "no", @calculator.self_assessment_july_2020
      end

      should "go to :sectors? question" do
        assert_equal :sectors?, @new_state.current_node
        assert_node_exists :sectors?
      end
    end

    context "when answering :sectors? question" do
      setup do
        setup_states_for_question(:sectors?,
                                  responding_with: %w[retail hospitality leisure],
                                  initial_state: { calculator: @calculator })
      end

      should "store 'retail hospitality leisure' for :sectors? question" do
        assert_same_elements %w[retail hospitality leisure], @calculator.sectors
      end

      should "go to :results outcome" do
        assert_equal :results, @new_state.current_node
        assert_node_exists :results
      end
    end
  end
end
