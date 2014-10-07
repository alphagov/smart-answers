module SmartdownPlugins
  module EmployeeParentalLeave

    def self.claim_date_maternity_allowance(date)
      date - 14.weeks
    end

    def self.earliest_start(date)
      date - 11.weeks
    end

    def self.earnings_test_start_date(date)
      date - 66.weeks
    end

    def self.end_of_14_week_maternity_allowance(date)
      date + 14.weeks
    end

    def self.end_of_additional_leave(date)
      date + 52.weeks
    end

    def self.end_of_additional_paternity_leave(date)
      date + 1.year
    end

    def self.end_of_additional_paternity_pay_from_leave(date)
      date + 52.weeks
    end

    def self.end_of_additional_paternity_pay_from_match_or_due_date(date)
      date + 28.weeks
    end

    def self.end_of_adoption_pay(date)
      date + 39.weeks
    end

    def self.end_of_maternity_allowance(date)
      date + 28.weeks
    end

    def self.end_of_maternity_pay(date)
      date + 39.weeks
    end

    def self.end_of_ordinary_leave(date)
      date + 26.weeks
    end

    def self.end_of_paternity_leave(date)
      date + 2.weeks
    end

    def self.end_of_shared_parental_leave(date)
      date + 1.year
    end

    def self.latest_pat_leave(date)
      date + 56.days
    end

    def self.lower_earnings_start(date)
      date - 23.weeks
    end

    def self.minimum_start_date(date)
      date - 41.weeks
    end

    def self.minimum_end_date(date)
      date - 15.weeks
    end

    def self.notice_date_sap(date)
      date - 28.days
    end

    def self.notice_date_smp(date)
      date - 28.days
    end

    def self.paternity_leave_notice_date(date)
      preceding_monday = date - (date.value.wday - 1).days
      preceding_monday - 15.weeks
    end

    def self.paternity_pay_notice_date(date_leave_2)
      date_leave_2 - 28.days
    end

    def self.qualifying_week(match_date)
      match_date + 7.days
    end

    def self.rate_of_paternity_pay(salary_2)
      nine_tenths_weekly_salary_capped_at_138_point_18(salary_2)
    end

    def self.rate_of_maternity_allowance(salary_1_66_weeks)
      nine_tenths_weekly_salary_capped_at_138_point_18(salary_1_66_weeks)
    end

    def self.rate_of_sap(salary_1)
      nine_tenths_weekly_salary_capped_at_138_point_18(salary_1)
    end

    def self.rate_of_shpp(salary)
      nine_tenths_weekly_salary_capped_at_138_point_18(salary)
    end

    def self.rate_of_smp_6_weeks(salary_1)
      (salary_1.value / 52) * 0.9
    end

    def self.rate_of_smp_33_weeks(salary_1)
      nine_tenths_weekly_salary_capped_at_138_point_18(salary_1)
    end

    def self.start_of_additional_leave(date_leave_1)
      date_leave_1 + 26.weeks + 1.day
    end

    def self.start_of_additional_paternity_leave(date)
      date + 20.weeks
    end

    def self.start_of_maternity_allowance(date)
      date - 11.weeks
    end

    def self.total_maternity_allowance(salary_1_66_weeks)
      rate_of_maternity_allowance(salary_1_66_weeks) * 39
    end

    def self.total_sap(salary_1)
      rate_of_sap(salary_1) * 39
    end

    def self.total_smp(salary_1)
      (rate_of_smp_6_weeks(salary_1) * 6) + (rate_of_smp_33_weeks(salary_1) * 33)
    end

  private
    def self.nine_tenths_weekly_salary_capped_at_138_point_18(salary)
      weekly_salary = salary.value / 52
      rate = weekly_salary * 0.9
      rate < 138.18 ? rate : 138.18
    end
  end
end
