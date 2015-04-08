require 'smartdown/model/answer/money'
require 'smartdown/model/answer/date'

module SmartdownPlugins
  module PayLeaveForParentsAdoption

    #Flow helpers

    def self.qualifies_for_14_week_maternity_allowance?(employment_status_1, employment_status_2)
      employment_status_2 == 'self-employed' && employment_status_1 == 'unemployed'
    end

    def self.qualifies_for_maternity_allowance?(employment_status, earnings, work_employment, job_before, job_after, lel)
      !qualifies_for_pay?(employment_status, job_before, job_after, lel) && earnings_employment(earnings, work_employment)
    end

    def self.qualifies_for_pay?(employment_status, job_before, job_after, lel)
      (employment_status == 'employee' || employment_status == 'worker') &&
      continuity(job_before, job_after) &&
      lower_earnings(lel)
    end

    def self.qualifies_for_leave?(employment_status, job_before, job_after)
      employment_status == 'employee' &&
      continuity(job_before, job_after)
    end

    def self.qualifies_for_maternity_leave?(employment_status, job_after)
      employment_status == 'employee' && job_after == 'yes'
    end

    def self.both_qualifies_for_shared_pay?(employment_status_1, job_before_1, job_after_1, lel_1, employment_status_2, job_before_2, job_after_2, lel_2)
      qualifies_for_pay?(employment_status_1, job_before_1, job_after_1, lel_1) &&
      qualifies_for_pay?(employment_status_2, job_before_2, job_after_2, lel_2)
    end

    def self.both_qualifies_for_shared_leave?(employment_status_1, job_before_1, job_after_1, lel_1, work_employment_1, earnings_employment_1, employment_status_2, job_before_2, job_after_2, lel_2, work_employment_2, earnings_employment_2)
      (qualifies_for_maternity_leave?(employment_status_1, job_after_1) ||
      qualifies_for_leave?(employment_status_1, job_before_1, job_after_1) ||
      qualifies_for_pay?(employment_status_1, job_before_1, job_after_1, lel_1) ||
      qualifies_for_pay?(employment_status_2, job_before_2, job_after_2, lel_2) ||
      qualifies_for_maternity_allowance?(employment_status_1, earnings_employment_1, work_employment_1, job_before_1, job_after_1, lel_1)) &&
      employment_status_1 == 'employee' &&
      continuity(job_before_1, job_after_1) &&
      earnings_employment(earnings_employment_1, work_employment_1) &&
      employment_status_2 == 'employee' &&
      continuity(job_before_2, job_after_2) &&
      earnings_employment(earnings_employment_2, work_employment_2)
    end

    #Continuity test
    def self.continuity(job_before, job_after)
      job_before == "yes" && job_after == "yes"
    end

    #Lower earnings test: person has earned more than
    #the lower earnings limit
    def self.lower_earnings(lel)
      lel == "yes"
    end

    #Earnings and employment test
    def self.earnings_employment(earnings_employment, work_employment)
      earnings_employment == "yes" && work_employment == "yes"
    end

    #Date calculations

    def self.continuity_start_date(date)
      build_date_answer(saturday_before(date.value - 39.weeks))
    end

    def self.continuity_end_date(date)
      build_date_answer(sunday_before(date.value - 15.weeks))
    end

    def self.lower_earnings_start_date(date)
      build_date_answer(saturday_before(date.value - 22.weeks))
    end

    def self.lower_earnings_end_date(date)
      build_date_answer(saturday_before(date.value - 14.weeks))
    end

    def self.earnings_employment_start_date(date)
      build_date_answer(sunday_before(date.value - 66.weeks))
    end

    def self.earnings_employment_end_date(date)
      build_date_answer(saturday_before(date.value))
    end

    def self.earliest_start_mat_leave(date)
      build_date_answer(sunday_before(date.value - 11.weeks))
    end

    def self.end_of_additional_paternity_leave(date)
      build_date_answer(date.value + 1.year)
    end

    def self.end_of_shared_parental_leave(date)
      build_date_answer(date.value + 1.year)
    end

    def self.latest_pat_leave(date)
      build_date_answer(date.value + 56.days)
    end

    def self.maternity_leave_notice_date(date)
      build_date_answer(saturday_before(date.value - 14.weeks))
    end

    def self.paternity_leave_notice_date(date)
      build_date_answer(saturday_before(date.value - 14.weeks))
    end

    def self.start_of_additional_paternity_leave(date)
      build_date_answer(date.value + 20.weeks)
    end

    def self.start_of_maternity_allowance(date)
      build_date_answer(sunday_before(date.value - 11.weeks))
    end

    #Money calculations

    def self.rate_of_maternity_allowance(salary_1_66_weeks)
      build_money_answer(nine_tenths_weekly_salary_capped(salary_1_66_weeks))
    end

    def self.rate_of_paternity_pay(salary_2)
      build_money_answer(nine_tenths_weekly_salary_capped(salary_2))
    end

    def self.rate_of_shpp(salary)
      build_money_answer(nine_tenths_weekly_salary_capped(salary))
    end

    def self.rate_of_smp_6_weeks(salary_1)
      build_money_answer((salary_1.value / 52) * 0.9)
    end

    def self.rate_of_smp_33_weeks(salary_1)
      build_money_answer(nine_tenths_weekly_salary_capped(salary_1))
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

    def self.sunday_before(date)
      date - date.wday
    end

    def self.saturday_before(date)
      (date - date.wday) - 1.day
    end

    def self.nine_tenths_weekly_salary_capped(salary)
      weekly_salary = salary.value / 52
      rate = weekly_salary * 0.9
      rate < 139.58 ? rate : 139.58
    end
  end
end
