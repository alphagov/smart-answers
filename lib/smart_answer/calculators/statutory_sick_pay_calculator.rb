module SmartAnswer::Calculators
  class StatutorySickPayCalculator
  
    attr_reader :waiting_days, :normal_workdays, :pattern_days

    # LEL changes on 1 April each year - update when we know the April 2013 rate
    LOWER_EARNING_LIMIT = 107.00
    SSP_WEEKLY_RATE = 85.85

    def self.earning_limit_rates
      [
        {min: Date.parse("6 April 2010"), max: Date.parse("5 April 2011"), lower_earning_limit_rate: 97},
        {min: Date.parse("6 April 2011"), max: Date.parse("5 April 2012"), lower_earning_limit_rate: 102},
        {min: Date.parse("6 April 2012"), max: Date.parse("5 April 2013"), lower_earning_limit_rate: 107}
      ]
    end

    # define as static so we don't have to instantiate the calculator too early in the flow
    def self.lower_earning_limit_on(date)
      earning_limit_rate = earning_limit_rates.find { |c| c[:min] <= date and c[:max] >= date }
      (earning_limit_rate ? earning_limit_rate[:lower_earning_limit_rate] : LOWER_EARNING_LIMIT)
    end

    # ssp weekly rate will be updated in April 2013, we'll know about it in Jan 2013
    def ssp_rates
      [
        {min: Date.parse("6 April 2011"), max: Date.parse("5 April 2012"), ssp_weekly_rate: 81.60},
        {min: Date.parse("6 April 2012"), max: Date.parse("5 April 2012"), ssp_weekly_rate: 85.85}
      ]
    end

    
    def daily_rate_on(date, pattern_days)
      rate = ssp_rates.find { |c| c[:min] <= date and c[:max] >= date }
      weekly_rate = (rate ? rate[:ssp_weekly_rate] : SSP_WEEKLY_RATE)
      # we need to calculate the daily rate by truncating to four decimal places to match unrounded daily rates used by HMRC 
      # doing .round(6) after multiplication to avoid float precision issues
      # Simply using .round(4) on ssp_weekly_rate/@pattern_days will be off by 0.0001 for 3 and 7 pattern days and lead to 1p difference in some statutory amount calculations
      pattern_days > 0 ? ((((weekly_rate / pattern_days) * 10000).round(6).floor)/10000.0) : 0.0000
    end

    
    def initialize(prev_sick_days, sick_start_date, sick_end_date, days_of_the_week_worked)
    	@prev_sick_days = prev_sick_days
    	@waiting_days = (@prev_sick_days >= 3 ? 0 : 3 - @prev_sick_days) 
      @sick_start_date = sick_start_date
      @sick_end_date = sick_end_date
      @pattern_days = days_of_the_week_worked.length
      @normal_workdays_missed = init_normal_workdays_missed(days_of_the_week_worked)
      @normal_workdays = @normal_workdays_missed.length
      @payable_days = init_payable_days 
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
      @payable_days.length
    end

    def ssp_payment
      if days_to_pay > 0
        daily_rate_at_start = daily_rate_on(@payable_days.first, @pattern_days)
        if days_to_pay > 1
          daily_rate_at_end = daily_rate_on(@payable_days.last, @pattern_days)
          if daily_rate_at_end == daily_rate_at_start
            ## simple case - not spanning tax years
            (days_to_pay * daily_rate_at_start).round(2)
          else
            days_before_6_april = 0
            days_on_or_after_6_april = 0
            # 6th of april after the start_date
            higher_rate_date = find_6th_april_after(@sick_start_date)
            ## 2. from @payable_days, count how many are before 6 April, how many after
            @payable_days.each do |date|
              if date < higher_rate_date
                days_before_6_april += 1
              else
                days_on_or_after_6_april +=1
              end
            end
            ## 3. multiply before and after by appropriate rate and add the two subtotals up
            raw_value1 = (days_before_6_april * daily_rate_at_start).round(10) # doesn't need adjusting
            raw_value2 = (days_on_or_after_6_april * daily_rate_at_end).round(10)
            ## round up amounts for 2012-13 on 3rd decimal place to match table of payments for part-weeks
            adjusted_value2 = ((raw_value2 * 100).ceil)/100.0
            (raw_value1 + adjusted_value2).round(2)
          end    
        else
          daily_rate_at_start.round(2)
        end
      else
        0.0
      end
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

    def init_payable_days
      # copy not to modify the instance variable we need to keep
      payable_days_temp = @normal_workdays_missed
      ## 1. remove up to 3 first dates from the array if there are waiting days in this period
      payable_days_temp.shift(@waiting_days)
      ## 2. return only the first days_that_can_be_paid_for_this_period
      payable_days_temp.shift(days_that_can_be_paid_for_this_period)
    end

    def find_6th_april_after(date)
      year = date.year
      if (date.month > 4) or (date.month == 4 and date.day > 6)
        year +=1
      end
      Date.new(year, 4, 6)
    end
  end
end
