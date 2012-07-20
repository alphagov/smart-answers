module SmartAnswer::Calculators
  class MinimumWageCalculator
  
    ACCOMMODATION_CHARGE_THRESHOLD = 4.73
    
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
    
    def accommodation_adjustment(charge, number_of_nights)
      charge = charge.to_f
      number_of_nights = number_of_nights.to_i
      
      if charge > 0
        charged_accomodation_adjustment(charge, number_of_nights) 
      else
        free_accommodation_adjustment(number_of_nights)
      end
    end
    
    protected
    
    def free_accommodation_adjustment(number_of_nights)
      (ACCOMMODATION_CHARGE_THRESHOLD * number_of_nights).round(2)
    end
    
    def charged_accomodation_adjustment(charge, number_of_nights)
      if charge < ACCOMMODATION_CHARGE_THRESHOLD
        0
      else
        free_accommodation_adjustment(number_of_nights) - (charge * number_of_nights).round(2)
      end
    end
  end
end
