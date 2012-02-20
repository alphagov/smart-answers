module SmartAnswer
  class Outcome < Node
    def is_outcome?
      true
    end

    def transition(*args)
      raise InvalidNode
    end
  end
end