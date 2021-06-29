module SmartAnswer
  class Outcome < Node
    PRESENTER_CLASS = OutcomePresenter

    def outcome?
      true
    end

    def transition(*_args)
      raise InvalidNode
    end
  end
end
