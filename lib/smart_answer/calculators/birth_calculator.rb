module SmartAnswer::Calculators
  class BirthCalculator
    include ActionView::Helpers::DateHelper

    attr_reader :due_date

    def initialize(match_or_due_date)
      @due_date = @match_date = match_or_due_date
    end

    def expected_week
      expected_start = @due_date - @due_date.wday
      SmartAnswer::DateRange.new(
        begins_on: expected_start,
        ends_on: expected_start + 6.days,
      )
    end

    def qualifying_week
      qualifying_start = 15.weeks.ago(expected_week.begins_on)
      SmartAnswer::DateRange.new(
        begins_on: qualifying_start,
        ends_on: qualifying_start + 6.days,
      )
    end

    def employment_start
      25.weeks.ago(qualifying_week.ends_on)
    end
  end
end
