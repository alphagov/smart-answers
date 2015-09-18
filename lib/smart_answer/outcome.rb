module SmartAnswer
  class Outcome < Node
    def outcome?
      true
    end

    def transition(*args)
      raise InvalidNode
    end
  end
end
