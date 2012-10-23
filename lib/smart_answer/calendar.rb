module SmartAnswer
  class Calendar

    attr_reader :dates

    def initialize(&block)
      @dates = []
      instance_eval(&block) if block_given?
    end

    def date(name, date_or_range)
      @dates << [name, date_or_range]
    end

    def to_ics
      RiCal.Calendar do |cal|
        @dates.each do |(title,date)|
          cal.event do |event|
            event.summary = title.to_s

            if date.is_a?(Range)
              event.dtstart = date.first
              event.dtend = date.last
            elsif date.is_a?(Date)
              event.dtstart = date
              event.dtend = date
            end
          end
        end
      end.export
    end

  end
end
