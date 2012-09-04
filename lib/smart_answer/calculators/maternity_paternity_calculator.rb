module SmartAnswer::Calculators
  class MaternityPaternityCalculator
  
    attr_reader :expected_week, :qualifying_week, :employment_start, :notice_of_leave_deadline, 
      :leave_earliest_start_date, :proof_of_pregnancy_date
    attr_accessor :employment_contract, :leave_start_date, :average_weekly_earnings
    
    LOWER_EARNING_LIMITS = { 2011 => 102, 2012 => 107 }
    MATERNITY_RATE_B = PATERNITY_RATE_B = 135.45
    
    def initialize(due_date)
      @due_date = due_date
      expected_start = due_date - due_date.wday
      @expected_week = expected_start .. expected_start + 6.days
      @notice_of_leave_deadline = qualifying_start = 15.weeks.ago(expected_start)
      @qualifying_week = qualifying_start .. qualifying_start + 6.days
      @employment_start = 26.weeks.ago(expected_start)
      @leave_earliest_start_date = 11.weeks.ago(due_date)
      @proof_of_pregnancy_date = 13.weeks.ago(due_date)
    end
    
    def leave_end_date
      52.weeks.since(@leave_start_date)
    end
    
    def pay_start_date
      @leave_start_date
    end
    
    def pay_end_date
      39.weeks.since(pay_start_date)
    end
    
    def statutory_maternity_rate
      (@average_weekly_earnings.to_f * 0.9).round(2)
    end
    
    def statutory_maternity_pay_a
      (statutory_maternity_rate * 6).round(2)
    end
    
    def statutory_maternity_pay_b
      weekly_pay = (MATERNITY_RATE_B < statutory_maternity_rate ? MATERNITY_RATE_B : statutory_maternity_rate)
      (weekly_pay * 33).round(2)
    end
    
    def lower_earning_limit(year=Date.today.year)
      LOWER_EARNING_LIMITS[year]
    end
  end
end
