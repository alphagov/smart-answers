module SmartAnswer
  class StartNode < Node
    def initialize(options = {}, &block)
      @options = options
      super(:start_page, options, &block)
    end

    def outcome?
      false
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
