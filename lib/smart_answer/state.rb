require 'ostruct'

module SmartAnswer
  class State < OpenStruct
    def initialize(start_node)
      super(current_node: start_node, path: [], responses: [], response: nil, error: nil)
    end

    def method_missing(method_name, *args)
      if method_name =~ /=$/
        super
      else
        raise NoMethodError.new("undefined method '#{method_name}' for #{self.class}")
      end
    end

    def transition_to(new_node, input, &blk)
      dup.tap { |new_state|
        new_state.path << self.current_node
        new_state.current_node = new_node
        new_state.responses << input
        yield new_state if block_given?
        new_state.freeze
      }
    end

    def to_hash
      @table
    end

    def save_input_as(name)
      __send__ "#{name}=", responses.last
    end

    private

    def initialize_copy(orig)
      super
      self.responses = orig.responses.dup
      self.path = orig.path.dup
    end
  end
end
