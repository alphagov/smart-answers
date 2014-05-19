module SmartAnswer
  module Predicate
    class Callable < Base
      def initialize(callable)
        @callable = callable
      end

      def call(state, input)
        state.instance_exec(input, &@callable)
      end

      def label
        "--defined by code--"
      end
    end
  end
end
