require 'active_support/inflector'

module SmartAnswer
  class Node
    attr_reader :name, :calculations, :precalculations

    def initialize(name, options = {}, &block)
      @name = name
      @calculations = []
      @precalculations = []
      instance_eval(&block) if block_given?
    end

    def to_sym
      name.to_sym
    end

    def to_s
      name.to_s
    end

    def calculate(variable_name, &block)
      @calculations << Calculation.new(variable_name, &block)
    end

    def precalculate(variable_name, &block)
      @precalculations << Calculation.new(variable_name, &block)
    end

    def evaluate_precalculations(current_state)
      new_state = current_state.dup
      @precalculations.each do |calculation|
        new_state = calculation.evaluate(new_state)
      end
      new_state
    end

    def outcome?
      false
    end

    def question?
      false
    end
  end
end
