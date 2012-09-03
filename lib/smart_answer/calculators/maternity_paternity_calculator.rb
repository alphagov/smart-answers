module SmartAnswer::Calculators
  class MaternityPaternityCalculator
  
    attr_reader :expected_week, :qualifying_week, :employment_start, :notice_of_leave_deadline, :max_leave_start_date
    attr_accessor :employment_contract, :leave_start_date
    
    def initialize(due_date)
      @due_date = due_date
      expected_start = due_date - due_date.wday
      @expected_week = expected_start .. expected_start + 6.days
      @notice_of_leave_deadline = qualifying_start = 15.weeks.ago(expected_start)
      @qualifying_week = qualifying_start .. qualifying_start + 6.days
      @employment_start = 26.weeks.ago(expected_start)
      @max_leave_start_date = 11.weeks.ago(due_date)
    end
    
    def leave_end_date
      52.weeks.since(@leave_start_date)
    end
  end
end
