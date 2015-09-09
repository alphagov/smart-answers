module SmartAnswer
  class Outcome < Node
    def initialize(flow, name, options = {}, &block)
      @options = options
      super
    end

    def outcome?
      true
    end

    def transition(*args)
      raise InvalidNode
    end

    def template_directory
      return unless @options[:flow_name]
      load_path = FlowRegistry.instance.load_path
      Pathname.new(load_path).join(@options[:flow_name])
    end
  end
end
