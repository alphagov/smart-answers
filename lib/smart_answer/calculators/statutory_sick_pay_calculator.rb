module SmartAnswer::Calculators
  class StatutorySickPayCalculator
  
    attr_reader :daily_rate, :waiting_days, :normal_work_days
    attr_accessor :pattern_days, :normal_work_days

    # LEL will need updating for April 2013 if it changes
    LOWER_EARNING_LIMIT = 107.00
    
    def initialize(prev_sick_days)
    	@prev_sick_days = prev_sick_days
    	@waiting_days = (@prev_sick_days >= 4 ? 0 : 3) 
    end

    def set_daily_rate(pattern_days)
    	@daily_rate = pattern_days > 0 ? (85.85 / pattern_days.to_f).round(2) : 0.00 
    end
    def set_normal_work_days(normal_work_days)
      @normal_work_days = normal_work_days
    end

    def ssp_payment
    	(@normal_work_days - @waiting_days) * @daily_rate
    end


  end
end
