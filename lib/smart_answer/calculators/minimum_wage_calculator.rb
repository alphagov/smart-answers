module SmartAnswer
  class MinimumWageCalculator
    def calculate(payment_method, age, hours)
      hours = hours.to_i
      "%0.2f" % case age
        when "21_or_over"
          hours * 6.08
        when "18_to_20"
          hours * 4.98
        when "under_18"
          hours * 3.68
        when "under_19"
          hours * 2.6
      end
    end
  end
end