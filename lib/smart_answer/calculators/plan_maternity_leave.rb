module SmartAnswer::Calculators
  class PlanMaternityLeave
    include ActionView::Helpers::DateHelper
    include SmartAnswer::DateHelper

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

    def distance_start
      distance_of_time_in_words(@due_date, @start_date)
    end

    ## borrowed methods

    def expected_week_of_childbirth
      sunday = @due_date - @due_date.wday
      saturday = sunday + 6
      SmartAnswer::DateRange.new(begins_on: sunday, ends_on: saturday)
    end

    def qualifying_week
      expected_week_of_childbirth && expected_week_of_childbirth.weeks_after(-15)
    end

    def earliest_start
      expected_week_of_childbirth && expected_week_of_childbirth.begins_on - 11 * 7
    end

    def period_of_ordinary_leave
      SmartAnswer::DateRange.new(
        begins_on: @start_date,
        ends_on: @start_date + 26 * 7 - 1,
      )
    end

    def period_of_additional_leave
      period_of_ordinary_leave && period_of_ordinary_leave.weeks_after(26)
    end
  end
end
