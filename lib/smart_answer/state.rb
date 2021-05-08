require "ostruct"

module SmartAnswer
  class State < OpenStruct
    include Question::NextNodeBlock::InstanceMethods

    def initialize(responses, requested_node)
      super(
        responses: responses,
        requested_node: requested_node,
      )
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

    def to_hash
      @table
    end

  private

    def initialize_copy(orig)
      super
      self.responses = orig.responses.dup
      self.path = orig.path.dup
    end
  end
end
