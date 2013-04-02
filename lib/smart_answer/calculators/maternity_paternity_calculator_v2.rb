require_relative "../date_helper"

module SmartAnswer::Calculators
  class MaternityPaternityCalculatorV2
    include DateHelper

    attr_reader :due_date, :expected_week, :qualifying_week, :employment_start, :notice_of_leave_deadline,
      :leave_earliest_start_date, :adoption_placement_date, :ssp_stop,
      :matched_week, :a_employment_start

    attr_accessor :employment_contract, :leave_start_date, :average_weekly_earnings, :a_notice_leave,
      :last_payday, :pre_offset_payday, :pay_date, :pay_day_in_month, :pay_day_in_week, 
      :pay_method, :pay_week_in_month

    LEAVE_TYPE_BIRTH = "birth"
    LEAVE_TYPE_ADOPTION = "adoption"

    def initialize(match_or_due_date, birth_or_adoption = LEAVE_TYPE_BIRTH)
      expected_start = match_or_due_date - match_or_due_date.wday
      qualifying_start = 15.weeks.ago(expected_start)

      @due_date = @match_date = match_or_due_date
      @leave_type = birth_or_adoption
      @expected_week = @matched_week = expected_start .. expected_start + 6.days
      @notice_of_leave_deadline = next_saturday(qualifying_start)
      @qualifying_week = qualifying_start .. qualifying_start + 6.days
      @employment_start = 25.weeks.ago(@qualifying_week.last)
      @a_employment_start = 25.weeks.ago(@matched_week.last)
      @leave_earliest_start_date = 11.weeks.ago(@expected_week.first)
      @ssp_stop = 4.weeks.ago(@expected_week.first)

      # Adoption instance vars
      @a_notice_leave = @match_date + 7
    end

    def format_date(date)
      date.strftime("%e %B %Y")
    end

    def format_date_day(date)
      date.strftime("%A, %d %B %Y")
    end

    def payday_offset
      8.weeks.ago(last_payday) + 1
    end

    def relevant_period
      [pre_offset_payday, last_payday]
    end

    def formatted_relevant_period
      relevant_period.map{ |p| format_date_day(p) }.join(" and ")
    end

    def leave_end_date
      52.weeks.since(@leave_start_date) - 1
    end

    def pay_start_date
      @leave_start_date
    end

    def pay_end_date
      39.weeks.since(pay_start_date) - 1
    end

    def notice_request_pay
      28.days.ago(pay_start_date)
    end

    # Rounds up at 2 decimal places.
    #
    def statutory_maternity_rate
      rate = average_weekly_earnings.to_f * 0.9
      (rate * 10**2).ceil.to_f / 10**2
    end

    def statutory_maternity_rate_a
      statutory_maternity_rate
    end

    def statutory_maternity_rate_b
      [current_statutory_rate, statutory_maternity_rate].min
    end

    def earning_limit_rates_birth
      [
        {min: Date.parse("17 July 2009"), max: Date.parse("16 July 2010"), lower_earning_limit_rate: 95},
        {min: Date.parse("17 July 2010"), max: Date.parse("16 July 2011"), lower_earning_limit_rate: 97},
        {min: Date.parse("17 July 2011"), max: Date.parse("14 July 2012"), lower_earning_limit_rate: 102},
        {min: Date.parse("15 July 2012"), max: Date.parse("13 July 2013"), lower_earning_limit_rate: 107}
      ]
    end

    def lower_earning_limit_birth
      earning_limit_rate = earning_limit_rates_birth.find { |c| c[:min] <= @due_date and c[:max] >= @due_date }
      (earning_limit_rate ? earning_limit_rate[:lower_earning_limit_rate] : 107)
    end

    def earning_limit_rates_adoption
      [
        {min: Date.parse("3 April 2010"), max: Date.parse("2 April 2011"), lower_earning_limit_rate: 97},
        {min: Date.parse("3 April 2011"), max: Date.parse("31 March 2012"), lower_earning_limit_rate: 102},
        {min: Date.parse("1 April 2012"), max: Date.parse("30 March 2013"), lower_earning_limit_rate: 107}
      ]
    end

    def lower_earning_limit_adoption
      earning_limit_rate = earning_limit_rates_adoption.find { |c| c[:min] <= @due_date and c[:max] >= @due_date }
      (earning_limit_rate ? earning_limit_rate[:lower_earning_limit_rate] : 107)
    end

    def lower_earning_limit
      if @leave_type == LEAVE_TYPE_BIRTH
        lower_earning_limit_birth
      else
        lower_earning_limit_adoption
      end
    end

    def employment_end
      @due_date
    end

    def adoption_placement_date=(date)
      @adoption_placement_date = date
      @leave_earliest_start_date = 14.days.ago(date)
    end

    def adoption_leave_start_date=(date)
      @leave_start_date = date
    end

    ## Paternity
    ##
    ## Statutory paternity rate
    def statutory_paternity_rate
      awe = (@average_weekly_earnings.to_f * 0.9).round(2)
      [current_statutory_rate, awe].min
    end

    ## Adoption
    ##
    ## Statutory adoption rate
    def statutory_adoption_rate
      statutory_maternity_rate_b
    end

    def pay_period_in_days
      (last_payday + 1 - pre_offset_payday).to_i
    end

    def calculate_average_weekly_pay(pay_pattern, pay)
      @average_weekly_earnings = (
        case pay_pattern
        when "irregularly"
          pay.to_f / pay_period_in_days * 7
        when "monthly"
          pay.to_f / 2 * 12 / 52
        else
          pay.to_f / 8
        end
      ).round(5) # HMRC rounding to 5 places.
    end

    # Total SMP is the sum of 6 weeks at the potentially higher rate A
    # and 33 weeks at the maximum statutory rate (B)
    #
    def total_statutory_pay
      ((statutory_maternity_rate_a * 6) + (statutory_maternity_rate_b * 33)).round(2)
    end

    def paydates_and_pay
      paydates = pay_method == 'a_certain_week_day_each_month' ? 
        paydates_for_a_certain_week_day_each_month : pay_pattern_start_dates 

      [].tap do |ary|
        paydates.each_with_index do |date, index|
          if next_paydate = paydates[index + 1]
            ary << { date: next_paydate, pay: pay_for_period(date, next_paydate) }
          end
        end
      end
    end

    def is_pay_date?(date)
      send(:"is_pay_date_#{pay_method}?", date)
    end

    # TODO: This includes the pay date prior to maternity pay start date which feels wrong
    # it would be better to modify paydates_and_pay to understand how to calculate the last pay date
    # possibly by adding a date parameter to last_pay_date
    def pay_pattern_start_dates
      step = 1
      case pay_method
      when 'every_2_weeks'
        step = 14
        range_start = pay_date
      when 'every_4_weeks'
        step = 28
        range_start = pay_date
      when 'first_day_of_the_month'
        range_start = Date.civil(pay_start_date.year, pay_start_date.month, 1)
      when 'last_day_of_the_month'
        range_start = Date.civil(pay_start_date.year, pay_start_date.month, -1) << 1
      else
        range_start = pay_start_date
      end

      [].tap do |ary|
        (range_start...39.weeks.since(range_start)).step(step).each do |d|
          ary << d if is_pay_date?(d)
        end
        ary << last_pay_date
      end
    end

    def paydates_for_a_certain_week_day_each_month
      def months_between_dates(start_date, end_date)
        start_date.beginning_of_month.step(end_date.beginning_of_month).select do |date|
          date.day == 1
        end
      end
      
      [].tap do |ary|
        months_between_dates(pay_start_date << 1, pay_end_date).each do |date|
          weekdays = weekdays_for_month(date, pay_day_in_week)
          ary << weekdays.send(pay_week_in_month)
        end
      end
    end

    def statutory_rate(date)
      rates = [
        { min: first_sunday_in_month(4, 2012), max: first_sunday_in_month(4, 2013), amount: 135.45 },
        { min: first_sunday_in_month(4, 2013), max: first_sunday_in_month(4, 2014), amount: 136.78 }
      ]
      rate = rates.find{ |r| r[:min] <= date and date < r[:max] } || rates.last
      rate[:amount]
    end

    def current_statutory_rate
      statutory_rate(Date.today)
    end
  
  private

    def pay_for_period(start_date, end_date)
      pay = 0.0
      (start_date...end_date).each_slice(7) do |week|
        # Calculate the rate for the week
        rate = rate_for(week.first)
        week.each do |day|
          # Increment the pay up until the pay end date.
          pay += (rate / 7) unless pay_start_date > day or day > pay_end_date
        end
      end
      pay.round(2) # TODO: Verify rounding here.
    end

    def rate_for(date)
      if date < 6.weeks.since(leave_start_date)
        statutory_maternity_rate_a
      else
        # Because uprating is calculated assuming payment in arrears the
        # rate should be calculated at the end of the week.
        statutory_rate(date + 6)
      end
    end

    def first_sunday_in_month(month, year)
      weekdays_for_month(Date.civil(year, month, 1), 0).first
    end

    def weekdays_for_month(date, weekday)
      date.beginning_of_month.step(date.end_of_month).select do |iter_date|
        weekday == iter_date.wday
      end
    end
    
    def is_pay_date_weekly_starting?(date)
      date.wday == pay_start_date.wday
    end

    def is_pay_date_weekly?(date)
      date.wday == pay_date.wday 
    end
    
    def is_pay_date_every_2_weeks?(date)
      true # The step in the pay date range handles this.
    end
    alias is_pay_date_every_4_weeks? is_pay_date_every_2_weeks?
    
    def is_pay_date_monthly?(date)
      date.day == pay_day_in_month
    end

    alias is_pay_date_specific_date_each_month? is_pay_date_monthly?
    
    def is_pay_date_irregularly?(date)
      # TODO: TBC irregular pay dates cannot be calculated on a 'usual pay date' basis.
    end
    
    def is_pay_date_first_day_of_the_month?(date)
      date.day == 1
    end
    
    def is_pay_date_last_day_of_the_month?(date)
      date == Date.new(date.year, date.month, -1)
    end
    
    def is_pay_date_specific_date_each_month?(date)
      date.day == pay_day_in_month
    end

    def last_working_day_of_the_month_offset(date)
      lwd = Date.new(date.year, date.month, -1) # Last weekday of the month.
      case lwd.wday
      when 0 then -3
      when 6 then -2
      else -1
      end
    end
    
    def is_pay_date_last_working_day_of_the_month?(date)
      date == Date.new(date.year, date.month, last_working_day_of_the_month_offset(date))
    end

    def last_pay_date
      case pay_method
      when 'monthly', 'specific_date_each_month'
        date = Date.civil(pay_end_date.year, pay_end_date.month, pay_day_in_month)
        date >> 1 if pay_day_in_month < pay_end_date.day
        date
      when 'first_day_of_the_month'
        Date.civil(pay_end_date.year, pay_end_date.month, 1) >> 1
      when 'last_day_of_the_month'
        Date.civil(pay_end_date.year, pay_end_date.month, -1)
      when 'last_working_day_of_the_month'
        Date.new(pay_end_date.year, pay_end_date.month, last_working_day_of_the_month_offset(pay_end_date))
      when 'weekly'
        number_of_weeks = pay_date < pay_start_date ? 40 : 39
        number_of_weeks.weeks.since(pay_date)
      when 'weekly_starting'
        39.weeks.since(pay_start_date)
      when 'every_2_weeks', 'every_4_weeks'
        40.weeks.since(pay_date)
      end  
    end
  end
end
