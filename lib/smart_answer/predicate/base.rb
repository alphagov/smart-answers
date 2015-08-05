module SmartAnswer
  module Predicate
    class Base
      def initialize(label = nil, callable = nil)
        @label = label
        @callable = callable
      end

      def call(state, input)
        @callable.call(state, input)
      end

      def or(other, new_label = nil)
        SmartAnswer::Predicate::Base.new(new_label || "#{self.label} | #{other.label}", ->(state, input) do
          self.call(state, input) || other.call(state, input)
        end)
      end

      alias_method :|, :or

      def and(other, new_label = nil)
        SmartAnswer::Predicate::Base.new(new_label || "#{self.label} AND #{other.label}", ->(state, input) do
          self.call(state, input) && other.call(state, input)
        end)
      end

      alias_method :&, :and

      def label
        @label || "-- undefined --"
      end
    end
  end
end
