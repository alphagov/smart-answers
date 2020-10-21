require "mocha/api"

module SmartAnswer
  module FlowUnitTestHelper
    class TestNode
      include Mocha::API
      attr_reader :state

      def initialize(flow, name)
        @flow = flow
        @name = name
        @question = @flow.node(name)
        @state = SmartAnswer::State.new(@question)
        @calculator_stubs = {}
      end

      def with(initial_state = {})
        initial_state.each do |(state_variable, value)|
          @state.send("#{state_variable}=", value)
        end
        self
      end

      def with_stubbed_calculator(stubs = {})
        @calculator_stubs.merge!(stubs)
        with(calculator: stub_everything(@calculator_stubs))
      end

      def answer_with(response)
        @response = response
        self
      end

      def next_node
        @question.transition(state, @response)
      end
    end
  end
end
