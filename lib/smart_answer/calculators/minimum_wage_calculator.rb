module SmartAnswer::Calculators
  class MinimumWageCalculator

    attr_accessor :overtime_hours, :overtime_hourly_rate, :accommodation_cost

    def initialize(params = {})
      @age = params[:age]
      @date = (params[:date].nil? ? Date.today : params[:date])
      @basic_hours = params[:basic_hours].to_f
      @basic_pay = params[:basic_pay].to_f
      @is_apprentice = params[:is_apprentice]
      @pay_frequency = params[:pay_frequency] || 7
      @overtime_hours = params[:overtime_hours].to_i || 0
      @overtime_hourly_rate = 0
      @accommodation_cost = 0
      @minimum_wage_data = minimum_wage_data_for_date(@date)
    end

    def basic_rate
      rate = @basic_pay / @basic_hours
      if overtime_hours > 0 and overtime_hourly_rate > 0 and rate > overtime_hourly_rate
        overtime_hourly_rate
      else
        rate
      end
    end

    def basic_total
      basic_rate * @basic_hours
    end

    def basic_hourly_rate
      basic_rate.round(2)
    end

    def minimum_hourly_rate
      if @is_apprentice
        @minimum_wage_data[:apprentice_rate]
      else
        per_hour_minimum_wage
      end
    end

    def total_hours
      (@basic_hours + overtime_hours).round(2)
    end

    def total_overtime_pay
      @overtime_hourly_rate = basic_hourly_rate if overtime_hourly_rate > basic_hourly_rate
      (@overtime_hours * overtime_hourly_rate).round(2)
    end

    def total_pay
      (basic_total + total_overtime_pay + @accommodation_cost).round(2)
    end

    def total_hourly_rate
      if total_hours < 1
        0.00
      else
        (total_pay / total_hours).round(2)
      end
    end

    def total_entitlement
      minimum_hourly_rate * total_hours
    end

    def total_underpayment
      underpayment = total_entitlement - total_pay
      underpayment > 0 ? (underpayment).round(2) : 0.0
    end

    def historical_entitlement
      (minimum_hourly_rate * total_hours).round(2)
    end

    def underpayment
      if total_pay >= historical_entitlement
        0
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
        accommodation_cost = charged_accomodation_adjustment(charge, number_of_nights)
      else
        accommodation_cost = free_accommodation_adjustment(number_of_nights)
      end
      @accommodation_cost = (accommodation_cost * weekly_multiplier).round(2)
    end

    def per_hour_minimum_wage(date = @date)
      data = minimum_wage_data_for_date(date)
      if @is_apprentice
        data[:apprentice_rate]
      else
        rates = data[:minimum_rates]
        rates.find do |r|
          @age >= r[:min_age] and @age < r[:max_age]
        end[:rate]
      end
    end

    def minimum_wage_data_for_date(date = Date.today)
      historical_minimum_wage_data.find do |d|
        date >= d[:start_date] and date <= d[:end_date]
      end
    end

    def free_accommodation_rate
      @minimum_wage_data[:accommodation_rate]
    end

    protected

    def weekly_multiplier
      (@pay_frequency.to_f / 7).round(3)
    end

    def free_accommodation_adjustment(number_of_nights)
      (free_accommodation_rate * number_of_nights).round(2)
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
      @@historical_minimum_wage_data ||= YAML.load_file(Rails.root.join("lib/data/minimum_wage_data.yml"))[:minimum_wage_data]
    end

  end
end
