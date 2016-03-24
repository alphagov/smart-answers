module SmartAnswer
  class Block
    def initialize(&block)
      @block = block
    end

    def evaluate(previous_state, response = nil)
      args = [response].compact
      previous_state.instance_exec(*args, &@block)
      new_state = previous_state.dup
      new_state.freeze
    end
  end
end
