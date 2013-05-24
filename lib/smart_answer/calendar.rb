require 'ics_renderer'

module SmartAnswer
  class Calendar

    def initialize(&block)
      @block = block if block_given?
    end

    def evaluate(state)
      return CalendarState.new(state, &@block)
    end
  end
end
