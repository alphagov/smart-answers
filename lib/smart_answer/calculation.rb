module SmartAnswer
  class Calculation
    def initialize(variable_name, &block)
      @variable_name = variable_name
      @calculation = block
    end

    def evaluate(previous_state, response = nil)
      args = [response].compact
      variable_value = previous_state.instance_exec(*args, &@calculation)
      new_state = previous_state.dup
      new_state.send("#{@variable_name}=", variable_value)
      new_state.freeze
    end
  end
end
