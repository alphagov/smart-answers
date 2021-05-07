module SmartAnswer
  class Block
    def initialize(&block)
      @block = block
    end

    def evaluate(previous_state, response = nil)
      args = [response].compact
      previous_state.instance_exec(*args, &@block)
    end
  end
end
