module SmartAnswer::Calculators
  class MaternityPaternityCalculator
  
    attr_reader :expected_week, :qualifying_week, :employment_start
  
    def initialize(due_date)
      @due_date = due_date
      expected_start = due_date - due_date.wday
      @expected_week = expected_start .. expected_start + 6.days
      qualifying_start = 15.weeks.ago(expected_start)
      @qualifying_week = qualifying_start .. qualifying_start + 6.days
      @employment_start = 26.weeks.ago(expected_start)
    end
  end
end
