module SmartAnswer::Calculators
  class MinimumWageCalculator
    def per_hour_minimum_wage(age)
      case age
        when "21_or_over"
          6.08
        when "18_to_20"
          4.98
        when "under_18"
          3.68
        when "under_19", "19_or_over"
          2.6
        else
          raise "Invalid age [#{age}]"
      end
    end

    def per_week_minimum_wage(age, hours_per_week)
      (hours_per_week.to_f * per_hour_minimum_wage(age)).round(2)
    end

    def per_piece_hourly_wage(pay_per_piece, pieces_per_week, hours_per_week)
      (pay_per_piece.to_f * pieces_per_week.to_f / hours_per_week.to_f).round(2)
    end

    def is_below_minimum_wage?(age, pay_per_piece, pieces_per_week, hours_per_week)
      per_piece_hourly_wage(pay_per_piece, pieces_per_week, hours_per_week).to_f < per_hour_minimum_wage(age)
    end
  end
end