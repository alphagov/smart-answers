module SmartAnswer::Calculators
  class StatutorySickPayCalculator
  
    attr_reader :daily_rate, :waiting_days, :normal_work_days, :lower_earning_limit, :ssp_weekly_rate
    attr_accessor :pattern_days, :normal_work_days

    # LEL changes on 1 April each year - update when we know the April 2013 rate
    LOWER_EARNING_LIMIT = 107.00
    SSP_WEEKLY_RATE = 85.85

    def earning_limit_rates
      [
        {min: Date.parse("6 April 2010"), max: Date.parse("5 April 2011"), lower_earning_limit_rate: 97},
        {min: Date.parse("6 April 2011"), max: Date.parse("5 April 2012"), lower_earning_limit_rate: 102},
        {min: Date.parse("6 April 2012"), max: Date.parse("5 April 2013"), lower_earning_limit_rate: 107}
      ]
    end

    # default to current limit if we don't find it
    def lower_earning_limit
      earning_limit_rate = earning_limit_rates.find { |c| c[:min] <= @sick_start_date and c[:max] >= @sick_start_date }
      (earning_limit_rate ? earning_limit_rate[:lower_earning_limit_rate] : LOWER_EARNING_LIMIT)
    end

    # ssp weekly rate will be updated in April 2013
    # TODO: find out what the rate was for before 6 april 2011
    def ssp_rates
      [
        {min: Date.parse("6 April 2011"), max: Date.parse("5 April 2012"), ssp_weekly_rate: 81.60 },
        {min: Date.parse("6 April 2012"), max: Date.parse("5 April 2012"), ssp_weekly_rate: 85.85}
      ]
    end

    def ssp_weekly_rate
      ssp_rate = ssp_rates.find { |c| c[:min] <= @sick_start_date and c[:max] >= @sick_start_date }
      (ssp_rate ? ssp_rate[:ssp_weekly_rate] : SSP_WEEKLY_RATE)
    end

    
    def initialize(prev_sick_days, sick_start_date)
    	@prev_sick_days = prev_sick_days
    	@waiting_days = (@prev_sick_days >= 3 ? 0 : 3 - @prev_sick_days) 
      @sick_start_date = sick_start_date
    end

    # TODO use truncate to four decimal places to match unrounded daily rates used by HMRC for 2012-13 for 3 and 7 pattern days
    # The current calculation will match rates for 2011-12 exactly
    def set_daily_rate(pattern_days)
      @pattern_days = pattern_days
    	@daily_rate = pattern_days > 0 ? (ssp_weekly_rate / pattern_days.to_f).round(4) : 0.0000 
    end

    def set_normal_work_days(normal_work_days)
      @normal_work_days = normal_work_days
    end

    def max_days_that_can_be_paid
      28 * @pattern_days
    end

    def days_paid_in_linked_period
      if @prev_sick_days > 3
        @prev_sick_days - 3
      else
        0
      end
    end

    def days_that_can_be_paid_for_this_period
      [max_days_that_can_be_paid - days_paid_in_linked_period, 0].max
    end

    def days_to_pay
      current_days_to_pay = @normal_work_days - @waiting_days
      if current_days_to_pay < days_that_can_be_paid_for_this_period
        current_days_to_pay
      else
        days_that_can_be_paid_for_this_period
      end
    end

    def ssp_payment
      (days_to_pay * @daily_rate).round(2)
    end

  end
end
