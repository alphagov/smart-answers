module SmartAnswer
  class DateRange
    class ::Date::Infinity
      def to_date
        self
      end
    end

    LATEST_DATE = Date::Infinity.new

    attr_reader :begins_on, :ends_on

    def initialize(begins_on:, ends_on: LATEST_DATE, duration: nil)
      @begins_on = begins_on.to_date
      @ends_on = duration.present? ? (begins_on + duration - 1) : ends_on.to_date
    end

    def include?(date)
      (date >= @begins_on) && (date <= @ends_on)
    end

    def number_of_days
      (@ends_on == LATEST_DATE) ? Float::INFINITY : (@ends_on - @begins_on).to_i + 1
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
