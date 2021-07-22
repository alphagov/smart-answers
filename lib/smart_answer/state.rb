require "ostruct"

module SmartAnswer
  class State < OpenStruct
    def initialize(start_node_name)
      super(current_node_name: start_node_name,
            accepted_responses: {},
            current_response: nil,
            error: nil)
    end

    def method_missing(method_name, *args)
      if respond_to_missing?(method_name)
        super
      else
        raise NoMethodError, "undefined method '#{method_name}' for #{self.class}"
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      method_name =~ /=$/ || super
    end

    def transition_to(new_node_name, input)
      dup.tap do |new_state|
        new_state.current_node_name = new_node_name
        new_state.accepted_responses[current_node_name] = input
        new_state.freeze
      end
    end

    def to_hash
      @table
    end

  private

    def initialize_copy(orig)
      super
      self.accepted_responses = orig.accepted_responses.dup
    end
  end
end
