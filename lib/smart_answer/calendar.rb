module SmartAnswer
  class Calendar

    attr_reader :dates

    def initialize(&block)
      @dates = []
      @block = block if block_given?
    end

    def evaluate(state)
      instance_exec(state, &@block) if @block and !@dates.any?
      return self
    end

    def date(name, date_or_range)
      @dates << [name, date_or_range]
    end

    def to_ics
      RiCal.Calendar do |cal|
        @dates.each do |(title,date_or_range)|
          cal.event do |event|
            event.summary = title.to_s

            if date_or_range.is_a?(Range)
              event.dtstart = date_or_range.first
              event.dtend = date_or_range.last
            elsif date_or_range.is_a?(Date)
              event.dtstart = date_or_range
              event.dtend = date_or_range
            end
          end
        end
      end.export
    end

  end
end
