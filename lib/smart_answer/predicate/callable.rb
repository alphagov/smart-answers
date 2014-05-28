module SmartAnswer
  module Predicate
    class Callable < Base
      def initialize(label = nil, callable = nil, &block)
        callable_expecting_state_as_binding = block_given? ? block : callable
        callable_taking_state_as_arg = ->(state, input) {
          state.instance_exec(input, &callable_expecting_state_as_binding)
        }

        super(label || "--defined by code--", callable_taking_state_as_arg)
      end
    end
  end
end
