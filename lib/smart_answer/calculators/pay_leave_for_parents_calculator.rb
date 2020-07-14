module SmartAnswer::Calculators
  class PayLeaveForParentsCalculator
    include ActiveModel::Model

    attr_accessor :two_carers,
                  :due_date,
                  :employment_status_of_mother,
                  :employment_status_of_partner,
                  :mother_started_working_before_continuity_start_date,
                  :mother_still_working_on_continuity_end_date,
                  :mother_earned_more_than_lower_earnings_limit,
                  :mother_worked_at_least_26_weeks,
                  :mother_earned_at_least_390,
                  :partner_started_working_before_continuity_start_date,
                  :partner_still_working_on_continuity_end_date,
                  :partner_earned_more_than_lower_earnings_limit

    def first_day_in_year(year)
      date = Date.new(year, 4, 1)
      offset = (7 - date.wday) % 7

      date + offset
    end

    def last_day_in_year(year)
      first_day_in_year(year + 1) - 1
    end

    def formatted_first_day_in_year(year)
      first_day_in_year(year).strftime("%e %B %Y")
    end

    def formatted_last_day_in_year(year)
      last_day_in_year(year).strftime("%e %B %Y")
    end

    def two_carers?
      two_carers == "yes"
    end

    def continuity_start_date
      saturday_before(due_date - 39.weeks)
    end

    def continuity_end_date
      sunday_before(due_date - 15.weeks)
    end

    def lower_earnings_amount
      tax_year_start = SmartAnswer::YearRange.tax_year
        .including(lower_earnings_end_date)
        .begins_on

      case tax_year_start.year
      when 2013
        SmartAnswer::Money.new(109)
      when 2014
        SmartAnswer::Money.new(111)
      when 2015
        SmartAnswer::Money.new(112)
      when 2016
        SmartAnswer::Money.new(112)
      when 2017
        SmartAnswer::Money.new(113)
      when 2018
        SmartAnswer::Money.new(116)
      when 2019
        SmartAnswer::Money.new(118)
      when 2020
        SmartAnswer::Money.new(120)
      else
        SmartAnswer::Money.new(120)
      end
    end

    def lower_earnings_start_date
      saturday_before(due_date - 22.weeks)
    end

    def lower_earnings_end_date
      saturday_before(due_date - 14.weeks)
    end

    def earnings_employment_start_date
      sunday_before(due_date - 66.weeks)
    end

    def earnings_employment_end_date
      saturday_before(due_date)
    end

    def mother_continuity?
      continuity(mother_started_working_before_continuity_start_date, mother_still_working_on_continuity_end_date)
    end

    def partner_continuity?
      continuity(partner_started_working_before_continuity_start_date, partner_still_working_on_continuity_end_date)
    end

    def continuity(job_before, job_after)
      job_before == "yes" && job_after == "yes"
    end

    def mother_lower_earnings?
      lower_earnings(mother_earned_more_than_lower_earnings_limit)
    end

    def partner_lower_earnings?
      lower_earnings(partner_earned_more_than_lower_earnings_limit)
    end

    # Lower earnings test: person has earned more than
    # the lower earnings limit
    def lower_earnings(lel)
      lel == "yes"
    end

    def mother_earnings_employment?
      earnings_employment(mother_earned_at_least_390, mother_worked_at_least_26_weeks)
    end

    # Earnings and employment test
    def earnings_employment(earnings_employment, work_employment)
      earnings_employment == "yes" && work_employment == "yes"
    end

    def paid_leave_is_in_year?(year)
      (paid_leave_period & SmartAnswer::YearRange.new(begins_on: first_day_in_year(year))).number_of_days.positive?
    end

    def paid_leave_period
      SmartAnswer::DateRange.new(
        begins_on: due_date,
        ends_on: due_date + 39.weeks,
      )
    end

    def start_of_maternity_allowance
      sunday_before(due_date - 11.weeks)
    end

    def earliest_start_mat_leave
      start_of_maternity_allowance
    end

    def maternity_leave_notice_date
      saturday_before(due_date - 14.weeks)
    end
    alias_method :paternity_leave_notice_date, :maternity_leave_notice_date

  private

    def saturday_before(date)
      (date - date.wday) - 1.day
    end

    def sunday_before(date)
      date - date.wday
    end
  end
end
