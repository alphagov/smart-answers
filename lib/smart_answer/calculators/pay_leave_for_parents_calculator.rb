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
  end
end
