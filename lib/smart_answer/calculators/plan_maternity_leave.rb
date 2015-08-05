module SmartAnswer::Calculators
  class PlanMaternityLeave
    include ActionView::Helpers::DateHelper

    attr_reader :formatted_due_date, :formatted_start_date, :leave_earliest_start_date

    def initialize(options = {})
      @due_date = Date.parse(options[:due_date])
      due_date_week_start = @due_date - @due_date.wday
      @leave_earliest_start_date = 11.weeks.ago(due_date_week_start)
      @formatted_due_date = @due_date.strftime("%A, %d %B %Y")
    end

    def enter_start_date(entered_start_date)
      @start_date = Date.parse(entered_start_date)
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
      distance_of_time_in_words(@due_date, @start_date)
    end

    ## borrowed methods

    def expected_week_of_childbirth
      sunday = @due_date - @due_date.wday
      saturday = sunday + 6
      sunday..saturday
    end

    def qualifying_week
      expected_week_of_childbirth && weeks_later(expected_week_of_childbirth, -15)
    end

    def earliest_start
      expected_week_of_childbirth && expected_week_of_childbirth.first - 11 * 7
    end

    def period_of_ordinary_leave
      @start_date..@start_date + 26 * 7 - 1
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
