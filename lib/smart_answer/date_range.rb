module SmartAnswer
  class DateRange
    EARLIEST_DATE = -Date::Infinity.new
    LATEST_DATE = Date::Infinity.new

    ComparableDate = Struct.new(:date)
    class ComparableDate
      include Comparable

      def <=>(other)
        if date.infinite? && other.date.finite?
          result = other.date <=> date
          result && -result
        else
          date <=> other.date
        end
      end
    end

    attr_reader :begins_on, :ends_on

    def initialize(begins_on: EARLIEST_DATE, ends_on: LATEST_DATE)
      @begins_on = begins_on.to_date
      @ends_on = ends_on.to_date
    end

    def include?(date)
      (ComparableDate.new(date.to_date) >= ComparableDate.new(@begins_on)) && (ComparableDate.new(date.to_date) <= ComparableDate.new(@ends_on))
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
