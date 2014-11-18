require 'smartdown/model/answer/money'
require 'smartdown/model/answer/date'

module SmartdownPlugins
  module PayLeaveForParents

    def self.continuity_start_date(date)
      "TODO"
    end

    def self.continuity_end_date(date)
      "TODO"
    end

    def self.lower_earnings_start_date(date)
      "TODO"
    end

    def self.lower_earnings_end_date(date)
      "TODO"
    end

    def self.earnings_employment_start_date(date)
      "TODO"
    end

    def self.earnings_employment_end_date(date)
      "TODO"
    end

    def self.claim_date_maternity_allowance(date)
      "TODO"
    end

    def self.earliest_start_mat_leave(date)
      "TODO"
    end

    def self.end_of_additional_paternity_leave(date)
      "TODO"
    end

    def self.end_of_shared_parental_leave(date)
      build_date_answer(date.value + 1.year)
    end

    def self.latest_pat_leave(date)
      "TODO"
    end

    def self.maternity_leave_notice_date(date)
      "TODO"
    end

    def self.paternity_leave_notice_date(date)
      preceding_monday = date.value - (date.value.wday - 1).days
      build_date_answer(preceding_monday - 15.weeks)
    end

    def self.start_of_additional_paternity_leave(date)
      "TODO"
    end

    def self.start_of_maternity_allowance(date)
      "TODO"
    end

    def self.rate_of_maternity_allowance(salary_1_66_weeks)
      build_money_answer(nine_tenths_weekly_salary_capped_at_138_point_18(salary_1_66_weeks))
    end

    def self.rate_of_paternity_pay(salary_2)
      build_money_answer(nine_tenths_weekly_salary_capped_at_138_point_18(salary_2))
    end

    def self.rate_of_shpp(salary)
      build_money_answer(nine_tenths_weekly_salary_capped_at_138_point_18(salary))
    end

    def self.rate_of_smp_6_weeks(salary_1)
      build_money_answer((salary_1.value / 52) * 0.9)
    end

    def self.rate_of_smp_33_weeks(salary_1)
      build_money_answer(nine_tenths_weekly_salary_capped_at_138_point_18(salary_1))
    end

    def self.total_aspp(salary_2)
      build_money_answer(rate_of_paternity_pay(salary_2) * 26)
    end

    def self.total_maternity_allowance(salary_1_66_weeks)
      build_money_answer(rate_of_maternity_allowance(salary_1_66_weeks) * 39)
    end

    def self.total_smp(salary_1)
      build_money_answer((rate_of_smp_6_weeks(salary_1) * 6) + (rate_of_smp_33_weeks(salary_1) * 33))
    end

  private

    def self.build_date_answer(date)
      Smartdown::Model::Answer::Date.new(date.to_s)
    end

    def self.build_money_answer(amount)
      Smartdown::Model::Answer::Money.new(amount)
    end

    def self.nine_tenths_weekly_salary_capped_at_138_point_18(salary)
      weekly_salary = salary.value / 52
      rate = weekly_salary * 0.9
      rate < 138.18 ? rate : 138.18
    end
  end
end
