module SmartAnswer
  class Outcome < Node
    def initialize(name, options = {}, &block)
      @options = options
      super
    end

    def outcome?
      true
    end

    def transition(*args)
      raise InvalidNode
    end

    def use_template?
      @options[:use_outcome_templates]
    end

    def flow_name
      @options[:flow_name]
    end
  end
end
