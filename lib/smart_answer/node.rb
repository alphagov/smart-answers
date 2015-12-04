require 'active_support/inflector'

module SmartAnswer
  class Node
    attr_reader :name, :calculations, :next_node_calculations, :precalculations

    def initialize(flow, name, options = {}, &block)
      @flow = flow
      @name = name
      @calculations = []
      @next_node_calculations = []
      @precalculations = []
      instance_eval(&block) if block_given?
    end

    def to_sym
      name.to_sym
    end

    def to_s
      name.to_s
    end

    def filesystem_friendly_name
      to_s.sub(/\?$/, '')
    end

    def calculate(variable_name, &block)
      @calculations << Calculation.new(variable_name, &block)
    end

    def next_node_calculation(variable_name, &block)
      @next_node_calculations << Calculation.new(variable_name, &block)
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

    def flow_name
      @flow.name
    end
  end
end
