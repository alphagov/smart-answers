module SmartAnswer::Calculators
  class PaternityPayCalculator < MaternityPayCalculator
    attr_accessor :paternity_leave_duration, :where_does_the_employee_live

    def initialize(due_date, leave_type = "paternity")
      super(due_date, leave_type)
    end

    # Pay duration is the same for paternity and paternity_adoption
    # leave types.
    def pay_duration
      paternity_leave_duration == "one_week" ? 1 : 2
    end

    def paternity_deadline
      deadline_period = if employee_lives_in_northern_ireland? || due_date <= Date.new(2024, 4, 6)
                          55.days
                        else
                          364.days
                        end
      start_date = [date_of_birth, due_date].max
      start_date + deadline_period
    end

    def leave_must_be_taken_consecutively?
      employee_lives_in_northern_ireland? || due_date <= Date.new(2024, 4, 6)
    end

    def paternity_pay_week_and_pay
      pay_week = 0
      lines = paydates_and_pay.map do |date_and_pay|
        %(Week #{pay_week += 1}|£#{sprintf('%.2f', date_and_pay[:pay])})
      end
      lines.join("\n")
    end

  private

    def employee_lives_in_northern_ireland?
      where_does_the_employee_live == "northern_ireland"
    end

    def rate_for(date)
      awe = (average_weekly_earnings.to_f * 0.9).round(2)
      [statutory_rate(date), awe].min
    end
  end
end
