module SmartAnswer
  class YearRangeWithFixedStartDate
    def initialize(start_date)
      start_date = Date.parse(start_date.to_s)
      @start_day = start_date.day
      @start_month = start_date.month
    end

    def starting_in(start_year)
      start_date = Date.new(start_year, @start_month, @start_day)
      YearRange.new(begins_on: start_date)
    end

    def including(date)
      range = starting_in(date.year)
      range.include?(date) ? range : range.previous
    end

    def current
      including(Time.zone.today)
    end
  end
end
