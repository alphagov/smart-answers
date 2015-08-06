module SmartAnswer::Calculators
  class PlanAdoptionLeave
    include ActionView::Helpers::DateHelper

    attr_reader :formatted_match_date, :formatted_arrival_date, :formatted_start_date

    def initialize(options = {})
      @match_date = options[:match_date]
      @formatted_match_date = formatted_date(@match_date)
      @arrival_date = options[:arrival_date]
      @formatted_arrival_date = formatted_date(@arrival_date)
      @start_date = options[:start_date]
      @formatted_start_date = formatted_date(@start_date)
    end

    def formatted_date(dt)
      dt.strftime("%d %B %Y")
    end

    def format_date_range(range)
      first = formatted_date(range.first)
      last = formatted_date(range.last)
      (first + " to " + last)
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
      sunday..saturday
    end

    def qualifying_week
      expected_week && weeks_later(expected_week, -1)
    end

    def last_qualifying_week_formatted
      formatted_date(qualifying_week.last)
    end

    def period_of_ordinary_leave
      @start_date..@start_date + 26 * 7
    end

    def period_of_additional_leave
      period_of_ordinary_leave && weeks_later(period_of_ordinary_leave, 26)
    end

    private
      def weeks_later(range, weeks)
        (range.first + weeks * 7)..(range.last + weeks * 7)
      end
  end
end
