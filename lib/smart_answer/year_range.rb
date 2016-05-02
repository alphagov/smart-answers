module SmartAnswer
  class YearRange < DateRange
    def initialize(begins_on:)
      ends_on = begins_on - 1 + 1.year
      if ends_on.month == 2 && ends_on.day == 28 && ends_on.leap?
        ends_on += 1
      end
      super(begins_on: begins_on, ends_on: ends_on)
    end
  end
end
