module SmartAnswer::Calculators
  class PayLeaveForParentsCalculator
    include ActiveModel::Model

    attr_accessor :two_carers
    attr_accessor :due_date
    attr_accessor :employment_status_of_mother
    attr_accessor :employment_status_of_partner
    attr_accessor :mother_started_working_before_continuity_start_date
    attr_accessor :mother_still_working_on_continuity_end_date
    attr_accessor :mother_earned_more_than_lower_earnings_limit
    attr_accessor :mother_worked_at_least_26_weeks
    attr_accessor :mother_earned_at_least_390
    attr_accessor :partner_started_working_before_continuity_start_date
    attr_accessor :partner_still_working_on_continuity_end_date
    attr_accessor :partner_earned_more_than_lower_earnings_limit
    attr_accessor :partner_worked_at_least_26_weeks
    attr_accessor :partner_earned_at_least_390

    def two_carers?
      two_carers == 'yes'
    end

    def continuity_start_date
      saturday_before(due_date - 39.weeks)
    end

    def continuity_end_date
      sunday_before(due_date - 15.weeks)
    end

    def lower_earnings_amount
      start_date = lower_earnings_start_date
      if in_2013_2014_fin_year?(start_date)
        SmartAnswer::Money.new(109)
      elsif in_2014_2015_fin_year?(start_date)
        SmartAnswer::Money.new(111)
      elsif in_2015_2016_fin_year?(start_date)
        SmartAnswer::Money.new(112)
      elsif in_2016_2017_fin_year?(start_date)
        SmartAnswer::Money.new(112)
      elsif in_2017_2018_fin_year?(start_date)
        SmartAnswer::Money.new(113)
      else
        SmartAnswer::Money.new(113)
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

    #Lower earnings test: person has earned more than
    #the lower earnings limit
    def lower_earnings(lel)
      lel == "yes"
    end

    def mother_earnings_employment?
      earnings_employment(mother_earned_at_least_390, mother_worked_at_least_26_weeks)
    end

    #Earnings and employment test
    def earnings_employment(earnings_employment, work_employment)
      earnings_employment == "yes" && work_employment == "yes"
    end

    (2013..2017).each do |year_start|
      year_end = year_start + 1
      define_method "range_in_#{year_start}_#{year_end}_fin_year?" do
        date_in_39_week_range?(year_start, due_date)
      end
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

    (2013..2017).each do |year_start|
      year_end = year_start + 1
      define_method "in_#{year_start}_#{year_end}_fin_year?" do |date|
        SmartAnswer::YearRange.new(
          begins_on: Date.new(year_start, 5, 6)
        ).include? date
      end
    end

  private

    def saturday_before(date)
      (date - date.wday) - 1.day
    end

    def sunday_before(date)
      date - date.wday
    end

    def date_in_39_week_range?(year_range_start, date)
      year_range = SmartAnswer::YearRange.new(
        begins_on: Date.new(year_range_start, 5, 6)
      )
      range_39_week = SmartAnswer::DateRange.new(
        begins_on: date,
        ends_on: date + 39.weeks
      )
      (range_39_week & year_range).number_of_days.positive?
    end
  end
end
