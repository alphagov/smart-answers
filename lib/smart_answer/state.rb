require "ostruct"

module SmartAnswer
  class State < OpenStruct
    def initialize(start_node, forwarding_responses: {})
      super(current_node: start_node,
            accepted_responses: {},
            forwarding_responses: forwarding_responses,
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

    def transition_to(new_node, input)
      dup.tap do |new_state|
        new_state.current_node = new_node
        new_state.accepted_responses[current_node] = input
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
      self.forwarding_responses = orig.forwarding_responses.dup
    end
  end
end
