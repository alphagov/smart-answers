module SmartAnswer
  class Outcome < Node
    def outcome?
      true
    end

    def transition(*args)
      raise InvalidNode
    end

    def template_directory
      load_path = FlowRegistry.instance.load_path
      Pathname.new(load_path).join(String(@flow.name))
    end
  end
end
