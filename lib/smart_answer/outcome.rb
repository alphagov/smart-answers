module SmartAnswer
  class Outcome < Node
    def outcome?
      true
    end

    def transition(*args)
      raise InvalidNode
    end

    def calendar(&block)
      @calendar = Calendar.new(&block)
    end

    def evaluate_calendar(state)
      @calendar.evaluate(state) if @calendar
    end
  end
end
