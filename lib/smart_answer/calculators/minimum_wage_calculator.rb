module SmartAnswer::Calculators
  class MinimumWageCalculator
    
    attr_accessor :overtime_hours, :overtime_hourly_rate, :accommodation_cost
    
    def initialize(params={})
      @age = params[:age]
      @date = (params[:date].nil? ? Date.today : params[:date])
      @basic_hours = params[:basic_hours].to_f
      @basic_pay = params[:basic_pay].to_f
      @is_apprentice = params[:is_apprentice]
      @overtime_hours = 0
      @overtime_hourly_rate = 0
      @accommodation_cost = 0
      @minimum_wage_data = minimum_wage_data_for_date(@date)
    end
    
    def basic_hourly_rate
      (@basic_pay / @basic_hours).round(2)
    end
    
    def minimum_hourly_rate
      if @is_apprentice
        @minimum_wage_data[:apprentice_rate]
      else
        per_hour_minimum_wage
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
      if total_hours < 1
        0.00
      else 
        (total_pay / total_hours).round(2)
      end
    end
    
    def historical_entitlement
      (minimum_hourly_rate * total_hours).round(2)
    end
    
    def underpayment
      if total_pay > historical_entitlement
        (total_pay - historical_entitlement).round(2)
      else
        (historical_entitlement - total_pay).round(2)
      end
    end
    
    def historical_adjustment
      (underpayment / minimum_hourly_rate * per_hour_minimum_wage(Date.today)).round(2)
    end
    
    def minimum_wage_or_above?
      minimum_hourly_rate <= total_hourly_rate
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
    
    def per_hour_minimum_wage(date = @date)
      rates = minimum_wage_data_for_date(date)[:minimum_rates]
      rates.find do |r|
        @age >= r[:min_age] and @age < r[:max_age]
      end[:rate]
    end
    
    def minimum_wage_data_for_date(date = Date.today)
      historical_minimum_wage_data.find do |d|
        date >= d[:start_date] and date <= d[:end_date]
      end
    end
    
    def format_money(value)
      # regex strips zeros
      str = sprintf("%.#{2}f", value).to_s.sub(/\.0+$/, '')
    end
    
    protected
    
    def free_accommodation_adjustment(number_of_nights)
      accommodation_rate = @minimum_wage_data[:accommodation_rate]
      (accommodation_rate * number_of_nights).round(2)
    end
    
    def charged_accomodation_adjustment(charge, number_of_nights)
      accommodation_rate = @minimum_wage_data[:accommodation_rate]
      if charge < accommodation_rate
        0
      else
        (free_accommodation_adjustment(number_of_nights) - (charge * number_of_nights)).round(2)
      end
    end
    
    def historical_minimum_wage_data
      @historical_minimum_wage_data ||= YAML.load(File.open("lib/data/minimum_wage_data.yml").read)[:minimum_wage_data]
    end
    
  end
end
