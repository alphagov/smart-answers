require 'ostruct'

module SmartAnswer
  class State < OpenStruct
    def initialize(start_node)
      super(current_node: start_node, path: [], responses: [])
    end
    
    def transition_to(new_node, input, &blk)
      clone.tap { |new_state|
        new_state.path << self.current_node
        new_state.current_node = new_node
        new_state.responses << input
        yield new_state if block_given?
        new_state.freeze
      }
    end
    
    def clone
      Marshal.load(Marshal.dump(self))
    end
    
    def to_hash
      @table
    end
    
    def save_input_as(name)
      __send__ "#{name}=", responses.last
    end
  end
end