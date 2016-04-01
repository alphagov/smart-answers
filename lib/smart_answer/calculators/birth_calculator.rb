module SmartAnswer::Calculators
  class BirthCalculator
    include ActionView::Helpers::DateHelper

    attr_reader :due_date

    def initialize(match_or_due_date)
      @due_date = @match_date = match_or_due_date
    end

    def expected_week
      expected_start = @due_date - @due_date.wday
      expected_start..expected_start + 6.days
    end

    def qualifying_week
      qualifying_start = 15.weeks.ago(expected_week.first)
      qualifying_start..qualifying_start + 6.days
    end

    def employment_start
      25.weeks.ago(qualifying_week.last)
    end
  end
end
