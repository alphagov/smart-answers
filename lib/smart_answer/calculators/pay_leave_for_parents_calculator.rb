module SmartAnswer::Calculators
  class PayLeaveForParentsCalculator
    def continuity_start_date(date)
      saturday_before(date - 39.weeks)
    end

    def continuity_end_date(date)
      sunday_before(date - 15.weeks)
    end

    def lower_earnings_amount(due_date)
      start_date = lower_earnings_start_date(due_date)
      if in_2013_2014_fin_year?(start_date)
        SmartAnswer::Money.new(109)
      elsif in_2014_2015_fin_year?(start_date)
        SmartAnswer::Money.new(111)
      elsif in_2015_2016_fin_year?(start_date)
        SmartAnswer::Money.new(112)
      else
        SmartAnswer::Money.new(112)
      end
    end

    def lower_earnings_start_date(date)
      saturday_before(date - 22.weeks)
    end

    def lower_earnings_end_date(date)
      saturday_before(date - 14.weeks)
    end

    def earnings_employment_start_date(date)
      sunday_before(date - 66.weeks)
    end

    def earnings_employment_end_date(date)
      saturday_before(date)
    end

    def continuity(job_before, job_after)
      job_before == "yes" && job_after == "yes"
    end

    #Lower earnings test: person has earned more than
    #the lower earnings limit
    def lower_earnings(lel)
      lel == "yes"
    end

    #Earnings and employment test
    def earnings_employment(earnings_employment, work_employment)
      earnings_employment == "yes" && work_employment == "yes"
    end

    def range_in_2013_2014_fin_year?(date)
      date_in_39_week_range?(2013, 2014, date)
    end

    def range_in_2014_2015_fin_year?(date)
      date_in_39_week_range?(2014, 2015, date)
    end

    def range_in_2015_2016_fin_year?(date)
      date_in_39_week_range?(2015, 2016, date)
    end

    def start_of_maternity_allowance(date)
      sunday_before(date - 11.weeks)
    end

    def earliest_start_mat_leave(date)
      sunday_before(date - 11.weeks)
    end

    def maternity_leave_notice_date(date)
      saturday_before(date - 14.weeks)
    end

    def paternity_leave_notice_date(date)
      saturday_before(date - 14.weeks)
    end

    def in_2013_2014_fin_year?(date)
      (Date.new(2013, 05, 06)..Date.new(2014, 05, 05)).cover?(date)
    end

    def in_2014_2015_fin_year?(date)
      (Date.new(2014, 05, 06)..Date.new(2015, 05, 05)).cover?(date)
    end

    def in_2015_2016_fin_year?(date)
      (Date.new(2015, 05, 06)..Date.new(2016, 05, 05)).cover?(date)
    end

    private

    def saturday_before(date)
      (date - date.wday) - 1.day
    end

    def sunday_before(date)
      date - date.wday
    end

    def date_in_39_week_range?(range_start, range_end, date)
      start_date = date
      end_date = start_date + 39.weeks
      (Date.new(range_start, 05, 06)..Date.new(range_end, 05, 05)).cover?(start_date) ||
      (Date.new(range_start, 05, 06)..Date.new(range_end, 05, 05)).cover?(end_date)
    end
  end
end
