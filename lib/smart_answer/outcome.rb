module SmartAnswer
  class Outcome < Node
    def outcome?
      true
    end

    def transition(*_args)
      raise InvalidNode
    end
  end
end
