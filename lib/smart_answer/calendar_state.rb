module SmartAnswer
  class CalendarState
    attr_reader :dates, :state

    def initialize(state, &block)
      @dates = []
      @state = state

      instance_exec(state, &block) if block_given?
    end

    def date(name, date_or_range)
      @dates << OpenStruct.new(:title => name, :date => date_or_range)
    end

    def path
      @state.path.join('/')
    end

    def to_ics
      ICSRenderer.new(self.dates, self.path).render
    end
  end
end
