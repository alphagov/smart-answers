module SmartAnswer::Calculators
  class MaternityPaternityCalculator

    attr_reader :due_date, :expected_week, :qualifying_week, :employment_start, :notice_of_leave_deadline,
      :leave_earliest_start_date, :adoption_placement_date, :ssp_stop,
      :notice_request_pay, :matched_week, :a_employment_start

    attr_accessor :employment_contract, :leave_start_date, :average_weekly_earnings, :a_notice_leave

    MATERNITY_RATE = PATERNITY_RATE = 135.45
    LEAVE_TYPE_BIRTH = "birth"
    LEAVE_TYPE_ADOPTION = "adoption"

    # def initialize(match_or_due_date)
    def initialize(match_or_due_date, birth_or_adoption = LEAVE_TYPE_BIRTH)
      @due_date = @match_date = match_or_due_date
      @leave_type = birth_or_adoption
      expected_start = match_or_due_date - match_or_due_date.wday
      @expected_week = @matched_week = expected_start .. expected_start + 6.days
      @notice_of_leave_deadline = qualifying_start = 15.weeks.ago(expected_start)
      @qualifying_week = qualifying_start .. qualifying_start + 6.days
      @employment_start = 25.weeks.ago(@qualifying_week.last)
      @a_employment_start = 25.weeks.ago(@matched_week.last)
      @leave_earliest_start_date = 11.weeks.ago(@expected_week.first)
      @ssp_stop = 4.weeks.ago(@expected_week.first)
      @notice_request_pay = 27.days.ago(@due_date)

      # Adoption instance vars
      @a_notice_leave = @match_date + 7
    end

    def format_date_day(date)
      date.strftime("%A, %d %B %Y")
    end

    def payday_offset(lastpayday)
      8.weeks.ago(lastpayday)
    end

    def relevant_period(lastpayday, payday2)
      relevant_period_to = lastpayday
      relevant_period_from = payday2 + 1
      "#{format_date_day(relevant_period_from)} and #{format_date_day(relevant_period_to)}"
    end

    def leave_end_date
      52.weeks.since(@leave_start_date)
    end

    def pay_start_date
      @leave_start_date
    end

    def pay_end_date
      39.weeks.since(pay_start_date)
    end

    def statutory_maternity_rate
      (@average_weekly_earnings.to_f * 0.9).round(2)
    end

    def statutory_maternity_rate_a
      statutory_maternity_rate
    end

    def statutory_maternity_rate_b
      (MATERNITY_RATE < statutory_maternity_rate ? MATERNITY_RATE : statutory_maternity_rate)
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
      (PATERNITY_RATE < awe ? PATERNITY_RATE : awe)
    end

    ## Adoption
    ##
    ## Statutory adoption rate
    def statutory_adoption_rate
      statutory_maternity_rate_b
    end


  end
end
