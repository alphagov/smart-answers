module SmartAnswer
  class YearRange < DateRange
    def initialize(begins_on:)
      ends_on = begins_on - 1 + 1.year
      super(begins_on: begins_on, ends_on: ends_on)
    end
  end
end
