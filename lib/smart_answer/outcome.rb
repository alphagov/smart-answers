module SmartAnswer
  class Outcome < Node
    PRESENTER_CLASS = OutcomePresenter

    def outcome?
      true
    end

    def transition(*_args)
      raise InvalidTransition, "can't transition once an outcome has been reached"
    end
  end
end
