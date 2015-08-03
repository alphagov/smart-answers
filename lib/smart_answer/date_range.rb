module SmartAnswer
  class DateRange
    EARLIEST_DATE = -Date::Infinity.new
    LATEST_DATE = Date::Infinity.new

    attr_reader :begins_on, :ends_on

    def initialize(begins_on: EARLIEST_DATE, ends_on: LATEST_DATE)
      @begins_on = begins_on.to_date
      @ends_on = ends_on.to_date
    end

    def include?(date)
      (date >= @begins_on) && (date <= @ends_on)
    end

    def number_of_days
      [@begins_on, @ends_on].any?(&:infinite?) ? Float::INFINITY : (@ends_on - @begins_on).to_i + 1
    end

    def ==(other)
      eql?(other)
    end

    def eql?(other)
      (self.class == other.class) && ([begins_on, ends_on] == [other.begins_on, other.ends_on])
    end

    def hash
      self.class.hash ^ [begins_on, ends_on].hash
    end
  end
end
