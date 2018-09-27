module SmartAnswer::Calculators
  class AdoptionPayCalculator < MaternityPayCalculator
    attr_reader :adoption_placement_date

    def initialize(due_date)
      super(due_date, "adoption")
    end

    def lower_earning_limit
      RatesQuery.from_file('maternity_paternity_adoption').rates(@qualifying_week.last).lower_earning_limit_rate
    end

    def adoption_placement_date=(date)
      @adoption_placement_date = date
      @leave_earliest_start_date = 14.days.ago(date)
    end

    def adoption_qualifying_start
      @match_date.sunday? ? @match_date : @match_date.beginning_of_week(:sunday)
    end

  private

    def rate_for(date)
      awe = (average_weekly_earnings.to_f * 0.9).round(2)
      if date < 6.weeks.since(leave_start_date) && @match_date >= Date.parse('5 April 2015')
        awe
      else
        [statutory_rate(date), awe].min
      end
    end
  end
end
