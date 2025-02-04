module SmartAnswer
  class YearRangeWithFixedStartDate
    def initialize(start_date)
      start_date = Date.parse(start_date.to_s)
      @start_day = start_date.day
      @start_month = start_date.month
    end

    def starting_in(start_year)
      # To handle the very rare case where we hit a leap year
      # Prevents us trying to call a nonexistent date e.g. 29th Feb 2025
      if (@start_month == 2) && (@start_day == 29) && !Date.leap?(start_year)
        @start_month = 3
        @start_day = 1
      end

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
