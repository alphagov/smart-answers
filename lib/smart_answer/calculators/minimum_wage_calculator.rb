module SmartAnswer::Calculators
  class MinimumWageCalculator
  
    ACCOMMODATION_CHARGE_THRESHOLD = 4.73
    
    HISTORICAL_MINIMUM_WAGES = {
      "2012" => [3.68, 4.98, 6.08],
      "2011" => [3.68, 4.98, 6.08],
      "2010" => [3.64, 4.92, 5.93],
      "2009" => [3.57, 4.83, 5.80],
      "2008" => [3.53, 4.77, 5.73],
      "2007" => [3.40, 4.60, 5.52],
      "2006" => [3.30, 4.45, 5.35],
      "2005" => [3.00, 4.25, 5.05]
    }
    
    attr_accessor :overtime_hours, :overtime_hourly_rate, :accommodation_cost
    
    def initialize(params={})
      @age = params[:age]
      @year = (params[:year].nil? ? Date.today.year : params[:year].to_i) 
      @basic_hours = params[:basic_hours]
      @basic_pay = params[:basic_pay]
      @is_apprentice = params[:is_apprentice]
      @total_hours = @basic_hours
      @overtime_hours = 0
      @overtime_hourly_rate = 0
      @accommodation_cost = 0
    end
    
    def basic_hourly_rate
      (@basic_pay / @basic_hours).round(2)
    end
    
    def minimum_hourly_rate
      if @is_apprentice
        apprentice_rate(@year)
      else
        per_hour_minimum_wage(@age, @year)
      end
    end
    
    def total_hours
      (@basic_hours + @overtime_hours).round(2)
    end
    
    def total_overtime_pay
      @overtime_hourly_rate = basic_hourly_rate if @overtime_hourly_rate > basic_hourly_rate
      (@overtime_hours * @overtime_hourly_rate).round(2)
    end
    
    def total_pay
      (@basic_pay + total_overtime_pay + @accommodation_cost).round(2)
    end
    
    def total_hourly_rate
      (total_pay / total_hours).round(2)
    end
    
    def historical_entitlement
      (minimum_hourly_rate * total_hours).round(2)
    end
    
    def underpayment
      (total_pay - historical_entitlement).round(2)
    end
    
    def historical_adjustment
      ((underpayment / minimum_hourly_rate) * per_hour_minimum_wage(@age)).round(2)
    end
    
    def adjusted_total_underpayment
      (underpayment + historical_adjustment).round(2)
    end
    
    def above_minimum_wage?
      minimum_hourly_rate < total_hourly_rate
    end
    
    def accommodation_adjustment(charge, number_of_nights)
      charge = charge.to_f
      number_of_nights = number_of_nights.to_i
      
      if charge > 0
        @accommodation_cost = charged_accomodation_adjustment(charge, number_of_nights) 
      else
        @accommodation_cost = free_accommodation_adjustment(number_of_nights)
      end
    end
    
    def per_hour_minimum_wage(age, year = Date.today.year)
      wages = HISTORICAL_MINIMUM_WAGES[year.to_s]
      if age < 18
        wages.first
      # Before 2010 the mid-age range was 18 to 21, after 2010 it was 18 to 20
      elsif age >= 18 and ((year.to_i < 2010 and age < 22) or (age < 21))
        wages.second
      else
        wages.third
      end
    end
    
    def apprentice_rate(year = Date.today.year)
      if year.to_i < 2010
        0
      elsif year.to_i < 2011
        2.5
      else
        2.6
      end
    end

    def per_week_minimum_wage(age, hours_per_week)
      (hours_per_week.to_f * per_hour_minimum_wage(age)).round(2)
    end

    def is_below_minimum_wage?(age, total_hourly_rate)
      total_hourly_rate.to_f < per_hour_minimum_wage(age)
    end
    
    protected
    
    def free_accommodation_adjustment(number_of_nights)
      (ACCOMMODATION_CHARGE_THRESHOLD * number_of_nights).round(2)
    end
    
    def charged_accomodation_adjustment(charge, number_of_nights)
      if charge < ACCOMMODATION_CHARGE_THRESHOLD
        0
      else
        (free_accommodation_adjustment(number_of_nights) - (charge * number_of_nights)).round(2)
      end
    end
  end
end
