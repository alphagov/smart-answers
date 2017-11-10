module SmartAnswer
  class YearRange < DateRange
    def self.resetting_on(date)
      YearRangeWithFixedStartDate.new(date)
    end

    def self.tax_year
      resetting_on("6 April")
    end

    def self.agricultural_holiday_year
      resetting_on("1 October")
    end

    def initialize(begins_on:)
      ends_on = begins_on - 1 + 1.year
      if ends_on.month == 2 && ends_on.day == 28 && ends_on.leap?
        ends_on += 1
      end
      super(begins_on: begins_on, ends_on: ends_on)
    end

    def next
      self.class.new(begins_on: begins_on + 1.year)
    end

    def previous
      self.class.new(begins_on: begins_on - 1.year)
    end
  end
end
