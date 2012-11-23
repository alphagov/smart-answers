module SmartAnswer::Calculators
  class StatutorySickPayCalculator
  
    attr_reader :daily_rate, :waiting_days, :normal_workdays, :lower_earning_limit, :ssp_weekly_rate, :pattern_days

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

    # ssp weekly rate will be updated in April 2013, we'll know about it in Jan 2013
    def ssp_rates
      [
        {min: Date.parse("6 April 2011"), max: Date.parse("5 April 2012"), ssp_weekly_rate: 81.60},
        {min: Date.parse("6 April 2012"), max: Date.parse("5 April 2012"), ssp_weekly_rate: 85.85}
      ]
    end

    def ssp_weekly_rate
      ssp_rate = ssp_rates.find { |c| c[:min] <= @sick_start_date and c[:max] >= @sick_start_date }
      (ssp_rate ? ssp_rate[:ssp_weekly_rate] : SSP_WEEKLY_RATE)
    end

    
    def initialize(prev_sick_days, sick_start_date, sick_end_date, days_of_the_week_worked)
    	@prev_sick_days = prev_sick_days
    	@waiting_days = (@prev_sick_days >= 3 ? 0 : 3 - @prev_sick_days) 
      @sick_start_date = sick_start_date
      @sick_end_date = sick_end_date
      @pattern_days = days_of_the_week_worked.length
      @normal_workdays_missed = init_normal_workdays_missed(days_of_the_week_worked)
      @normal_workdays = @normal_workdays_missed.length
      # we need to calculate the daily rate by truncating to four decimal places to match unrounded daily rates used by HMRC 
      # doing .round(6) after multiplication to avoid float precision issues
      # Simply using .round(4) on ssp_weekly_rate/@pattern_days will be off by 0.0001 for 3 and 7 pattern days and lead to 1p difference in some statutory amount calculations
      @daily_rate = @pattern_days > 0 ? ((((ssp_weekly_rate / @pattern_days) * 10000).round(6).floor)/10000.0) : 0.0000 
    end

    def max_days_that_can_be_paid
      (28 * @pattern_days).round(10)
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
      current_days_to_pay = @normal_workdays - @waiting_days
      if current_days_to_pay < days_that_can_be_paid_for_this_period
        current_days_to_pay
      else
        days_that_can_be_paid_for_this_period
      end
    end

    def ssp_payment
      (days_to_pay * @daily_rate).round(2)
    end

    private
    def init_normal_workdays_missed(days_of_the_week_worked)
      dates = @sick_start_date..@sick_end_date
      # create an array of all dates that would have been normal workdays
      normal_workdays_missed = []
      dates.each do |d|
        if days_of_the_week_worked.include?(d.wday.to_s)
          normal_workdays_missed << d
        end
      end
      normal_workdays_missed
    end

    def init_days_payable
      ## TODO: 
      ## 1. remove up to 3 first dates if there are waiting days in this period
      ## 2. take only the first days_that_can_be_paid_for_this_period
      ## 3. work out how many of those days are before April 6 and how many after, and use appropriate daily rates
    end
  end
end
