require 'ics_renderer'

module SmartAnswer
  class Calendar

    def initialize(&block)
      @block = block if block_given?
    end

    def evaluate(state)
      return CalendarState.new(state, &@block)
    end

    def to_ics(calendar_state)
      ICSRenderer.new(calendar_state.dates, calendar_state.path).render
    end

  end
end
