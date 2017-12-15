module SmartAnswer::Calculators
  class PlanAdoptionLeave
    include ActionView::Helpers::DateHelper
    include SmartAnswer::DateHelper

    attr_reader :formatted_match_date, :formatted_arrival_date, :formatted_start_date

    def initialize(options = {})
      @match_date = options[:match_date]
      @formatted_match_date = formatted_date(@match_date)
      @arrival_date = options[:arrival_date]
      @formatted_arrival_date = formatted_date(@arrival_date)
      @start_date = options[:start_date]
      @formatted_start_date = formatted_date(@start_date)
    end

    def distance_start
      distance_of_time_in_words(@arrival_date, @start_date)
    end

    ## borrowed methods

    def earliest_start
      @arrival_date - 14
    end

    def earliest_start_formatted
      formatted_date(earliest_start)
    end

    def expected_week
      sunday = @match_date - @match_date.wday
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
      SmartAnswer::DateRange.new begins_on: @start_date, ends_on: @start_date + 26 * 7
    end

    def period_of_additional_leave
      period_of_ordinary_leave && period_of_ordinary_leave.weeks_after(26)
    end
  end
end
