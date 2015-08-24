module SmartAnswer
  class YearRange < DateRange
    def initialize(begins_on:)
      super(begins_on: begins_on, ends_on: begins_on.to_date + 1.year - 1)
    end
  end
end
