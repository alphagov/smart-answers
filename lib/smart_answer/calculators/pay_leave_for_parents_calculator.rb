module SmartAnswer::Calculators
  class PayLeaveForParentsCalculator
    def continuity_start_date(date)
      saturday_before(date - 39.weeks)
    end

    def saturday_before(date)
      (date - date.wday) - 1.day
    end
  end
end
