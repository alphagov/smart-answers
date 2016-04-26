module SmartAnswer
  class YearRange < DateRange
    def initialize(begins_on:)
      super(begins_on: begins_on, ends_on: begins_on - 1 + 1.year)
    end
  end
end
