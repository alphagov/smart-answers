module SmartAnswer
  class Outcome < Node
    PRESENTER_CLASS = OutcomePresenter

    def requires_action?(_state)
      true
    end

    def outcome?
      true
    end

    def transition(*_args)
      raise InvalidNode
    end
  end
end
