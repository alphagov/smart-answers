module SmartAnswer::Calculators
  class PaternityPayCalculator < MaternityPayCalculator
    attr_accessor :paternity_leave_duration

    def initialize(due_date, leave_type = "paternity")
      super(due_date, leave_type)
    end

    # Pay duration is the same for paternity and paternity_adoption
    # leave types.
    def pay_duration
      paternity_leave_duration == "one_week" ? 1 : 2
    end

  private

    def rate_for(date)
      awe = (average_weekly_earnings.to_f * 0.9).round(2)
      [statutory_rate(date), awe].min
    end
  end
end
