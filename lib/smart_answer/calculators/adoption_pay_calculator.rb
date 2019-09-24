module SmartAnswer::Calculators
  class AdoptionPayCalculator < MaternityPayCalculator
    attr_reader :adoption_placement_date, :match_date, :matched_week
    attr_accessor :employee_has_contract_adoption

    def initialize(match_date)
      @match_date = match_date

      super(match_date, "adoption")

      @matched_week = @expected_week
      @a_employment_start = @matched_week.weeks_after(-25).ends_on
    end

    def lower_earning_limit
      RatesQuery.from_file("maternity_paternity_adoption").rates(relevant_week.last).lower_earning_limit_rate
    end

    def relevant_week
      @matched_week
    end

    def adoption_placement_date=(date)
      @adoption_placement_date = date
      @leave_earliest_start_date = 14.days.ago(date)
    end

    def adoption_qualifying_start
      @match_date.sunday? ? @match_date : @match_date.beginning_of_week(:sunday)
    end

    def a_notice_leave
      @match_date + 7
    end

    def no_contract_not_on_payroll?
      employee_has_contract_adoption == "no" && on_payroll == "no"
    end

    def has_contract_not_on_payroll?
      employee_has_contract_adoption == "yes" && on_payroll == "no"
    end

    def overseas_adoption_leave_employment_threshold
      26.weeks.ago(leave_start_date)
    end

  private

    def rate_for(date)
      awe = truncate((average_weekly_earnings.to_f / 100) * 90)
      if date < 6.weeks.since(leave_start_date) && @match_date >= Date.parse("5 April 2015")
        awe
      else
        [statutory_rate(date), awe].min
      end
    end
  end
end
