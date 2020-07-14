module SmartAnswer::Calculators
  class PlanAdoptionLeave
    include ActionView::Helpers::DateHelper
    include SmartAnswer::DateHelper

    attr_accessor :match_date, :arrival_date, :start_date

    def valid_arrival_date?
      arrival_date > match_date
    end

    def valid_start_date?
      dist = (arrival_date - start_date).to_i
      (1..14).include? dist
    end

    def distance_start
      distance_of_time_in_words(arrival_date, start_date)
    end

    def arrival_date_formatted
      formatted_date(arrival_date)
    end

    ## borrowed methods

    def earliest_start
      arrival_date - 14
    end

    def earliest_start_formatted
      formatted_date(earliest_start)
    end

    def expected_week
      sunday = match_date - match_date.wday
      saturday = sunday + 6
      SmartAnswer::DateRange.new begins_on: sunday, ends_on: saturday
    end

    def qualifying_week
      expected_week && expected_week.weeks_after(-1)
    end

    def last_qualifying_week_formatted
      formatted_date(qualifying_week.ends_on)
    end

    def period_of_ordinary_leave
      SmartAnswer::DateRange.new begins_on: start_date, ends_on: start_date + 26 * 7
    end

    def period_of_additional_leave
      period_of_ordinary_leave && period_of_ordinary_leave.weeks_after(26)
    end
  end
end
