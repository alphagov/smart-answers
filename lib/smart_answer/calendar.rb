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
      output = "BEGIN:VCALENDAR\r\nVERSION:2.0\r\n"
      output << "PRODID:-//uk.gov/GOVUK smart-answers//EN\r\n"
      output << "CALSCALE:GREGORIAN\r\n"
      @dates.each do |(title,date_or_range)|
        output << "BEGIN:VEVENT\r\n"
        if date_or_range.is_a?(Range)
          output << "DTEND;VALUE=DATE:#{ date_or_range.last.strftime("%Y%m%d") }\r\n"
          output << "DTSTART;VALUE=DATE:#{ date_or_range.first.strftime("%Y%m%d") }\r\n"
        elsif date_or_range.is_a?(Date)
          output << "DTEND;VALUE=DATE:#{ date_or_range.strftime("%Y%m%d") }\r\n"
          output << "DTSTART;VALUE=DATE:#{ date_or_range.strftime("%Y%m%d") }\r\n"
        end
        output << "SUMMARY:#{ title }\r\n"
        output << "END:VEVENT\r\n"
      end
      output << "END:VCALENDAR\r\n"
    end

  end
end
