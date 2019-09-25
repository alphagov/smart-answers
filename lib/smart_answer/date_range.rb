module SmartAnswer
  class DateRange
    include SmartAnswer::DateHelper
    include ActionView::Helpers::TextHelper

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

    def initialize(begins_on: nil, ends_on: nil)
      @begins_on = (begins_on || EARLIEST_DATE).to_date
      @ends_on = (ends_on || LATEST_DATE).to_date
    end

    def include?(date)
      (ComparableDate.new(date.to_date) >= ComparableDate.new(@begins_on)) &&
        (ComparableDate.new(date.to_date) <= ComparableDate.new(@ends_on))
    end

    def intersection(other)
      latest_begins_on = [ComparableDate.new(begins_on), ComparableDate.new(other.begins_on)].max.date
      earliest_ends_on = [ComparableDate.new(ends_on), ComparableDate.new(other.ends_on)].min.date
      self.class.new(begins_on: latest_begins_on, ends_on: earliest_ends_on)
    end

    alias_method :&, :intersection
    alias_method :first, :begins_on
    alias_method :last, :ends_on

    def number_of_days
      non_inclusive_days + 1
    end

    def non_inclusive_days
      infinite? ? Float::INFINITY : (@ends_on - @begins_on).to_i
    end

    def ==(other)
      other.is_a?(DateRange) && ([begins_on, ends_on] == [other.begins_on, other.ends_on])
    end

    def eql?(other)
      (self.class == other.class) && ([begins_on, ends_on] == [other.begins_on, other.ends_on])
    end

    def +(other)
      DateRange.new begins_on: begins_on + other, ends_on: ends_on + other
    end

    def hash
      self.class.hash ^ [begins_on, ends_on].hash
    end

    def infinite?
      [@begins_on, @ends_on].any?(&:infinite?)
    end

    def empty?
      number_of_days <= 0
    end

    def begins_before?(other)
      ComparableDate.new(begins_on) < ComparableDate.new(other.begins_on)
    end

    def gap_between(other)
      self.class.new(
        begins_on: [ComparableDate.new(ends_on), ComparableDate.new(other.ends_on)].min.date + 1,
        ends_on: [ComparableDate.new(begins_on), ComparableDate.new(other.begins_on)].max.date - 1,
      )
    end

    def years
      (begins_on.year..ends_on.year).to_a
    end

    def feb29th_date(year)
      Date.new(year, 2, 29)
    end

    def leap_dates
      years.inject([]) { |mem, year|
        if Date.leap?(year) && include?(feb29th_date(year))
          mem << feb29th_date(year)
        end
        mem
      }
    end

    def leap?
      leap_dates.any?
    end

    def weeks_after(weeks)
      self + weeks * 7
    end

    def to_s
      "#{formatted_date begins_on} to #{formatted_date ends_on}"
    end

    def to_r
      begins_on..ends_on
    end
    alias_method :to_range, :to_r

    def friendly_time_diff
      describe
    end

    def describe
      date_parts.compact.join(", ")
    end

  private

    def date_parts
      [
        date_part("year", whole_years_away),
        date_part("month", whole_months_away),
        date_part("day", whole_days_away),
      ]
    end

    def date_part(label, amount)
      amount.positive? ? "#{amount} #{label.pluralize(amount)}" : nil
    end

    def whole_years_away
      month_difference / 12
    end

    def whole_months_away
      month_difference % 12
    end

    def month_difference
      month = 0
      loop do
        month += 1
        break unless (begins_on >> month) <= ends_on
      end
      month - 1
    end

    def whole_days_away
      begins_on_shifted_to_ends_on_month = (begins_on >> month_difference)
      (ends_on - begins_on_shifted_to_ends_on_month).to_i
    end
  end
end
