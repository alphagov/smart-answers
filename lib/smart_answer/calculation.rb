module SmartAnswer
  class Calculation
    def initialize(variable_name, &block)
      @variable_name = variable_name
      @calculation = block
    end
    
    def evaluate(previous_state)
      variable_value = previous_state.instance_eval(&@calculation)
      new_state = previous_state.dup
      new_state.send("#{@variable_name}=", variable_value)
      new_state.freeze
    end
  end
end