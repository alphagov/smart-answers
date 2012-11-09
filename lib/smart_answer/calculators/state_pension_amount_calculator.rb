require "data/state_pension_query"

module SmartAnswer::Calculators
  class StatePensionAmountCalculator
    include ActionView::Helpers::TextHelper

    attr_reader :gender, :dob, :qualifying_years, :available_years #,:automatic_years
    attr_accessor :qualifying_years

    def initialize(answers)
      @gender = answers[:gender].to_sym
      @dob = DateTime.parse(answers[:dob])
      @qualifying_years = answers[:qualifying_years].to_i
      @available_years = ni_years_to_date
    end

    def current_weekly_rate
      107.45
    end

    # Everyone needs 30 qualifying years in all cases - no need to worry about old rules
    def years_needed
      30
    end

    def current_year
      Date.today.year
    end

    def years_to_pension
      t = Date.today
      speny = state_pension_date.month >= 4 ? state_pension_year : state_pension_year-1
      speny = state_pension_date.day < 6 && state_pension_date.month == 4 ? speny-1 : speny
      speny - t.year
    end

    def pension_loss
      current_weekly_rate - what_you_get
    end

    def what_you_get
      what_you_get_raw.round(2)
    end

    def what_you_get_raw
      if qualifying_years < years_needed
        (qualifying_years.to_f / years_needed.to_f) * current_weekly_rate
      else
        current_weekly_rate
      end
    end

    # what would you get if all remaining years to pension were qualifying years
    def what_you_would_get_if_not_full
      if (qualifying_years + years_to_pension) < years_needed
        ((qualifying_years + years_to_pension).to_f / years_needed.to_f) * current_weekly_rate
      else
        current_weekly_rate
      end
    end

    def state_pension_year
      state_pension_date.year
    end

    def state_pension_date(sp_gender = gender)
      StatePensionQuery.find(dob, sp_gender)
    end

    def state_pension_age
      spd = state_pension_date
      syear = state_pension_date.year - dob.year

      pension_age = syear.years.since(dob)
      years = syear
      
      if pension_age > state_pension_date 
        pension_age = 1.year.ago(pension_age) 
        years -= 1
      end
      
      month_and_day = friendly_time_diff(pension_age, state_pension_date)
      month_and_day = month_and_day.empty? ? month_and_day : ", " + month_and_day
      "#{pluralize(years, 'year')}#{month_and_day}"
    end

    def friendly_time_diff(from_time, to_time)
      from_time = from_time.to_time if from_time.respond_to?(:to_time)
      to_time = to_time.to_time if to_time.respond_to?(:to_time)
      components = []

      %w(year month day).map do |interval|
        distance_in_seconds = (to_time.to_i - from_time.to_i).round(1)
        delta = (distance_in_seconds / 1.send(interval)).floor
        delta -= 1 if from_time + delta.send(interval) > to_time
        from_time += delta.send(interval)
        components << pluralize(delta, interval) if distance_in_seconds >= 1.send(interval)
      end

      components.join(", ")
    end

    def before_state_pension_date?
      Date.today < state_pension_date
    end

    ## return true if today is within four months and four days from state pension date
    def within_four_months_four_days_from_state_pension?
      Date.today.advance(:months => 4, :days => 4) >= state_pension_date
    end

    def under_20_years_old?
      dob > 20.years.ago
    end
    
    def three_year_credit_age?
      dob >= Date.parse('1959-04-06') and dob <= Date.parse('1992-04-05')
    end
    
    def credit_bands
      [
        { min: Date.parse('1957-04-06'), max: Date.parse('1958-04-05'), credit: 1, validate: 0 },
        { min: Date.parse('1993-04-06'), max: Date.parse('1994-04-05'), credit: 1, validate: 0 },
        { min: Date.parse('1958-04-06'), max: Date.parse('1959-04-05'), credit: 2, validate: 1 },
        { min: Date.parse('1992-04-06'), max: Date.parse('1993-04-05'), credit: 2, validate: 1 }
      ]
    end


    def calc_qualifying_years_credit(entered_num=0)
      credit_band = credit_bands.find { |c| c[:min] <= dob and c[:max] >= dob }
      if credit_band
        case credit_band[:validate]
        when 0
          entered_num > 0 ? 0 : 1
        when 1
          rval = (1..2).find{ |c| c + entered_num == 2 } 
          entered_num < 2 ? rval : 0
        else
          0
        end
      else
        0
      end  
    end

    # Automatic years calculation removed for initial release
    # applies to men born before 6 Oct 1953
    # def auto_years
    #   [
    #     { before: Date.parse("1950-10-06"), credit: 5 },
    #     { before: Date.parse("1951-10-06"), credit: 4 },
    #     { before: Date.parse("1952-10-06"), credit: 3 },
    #     { before: Date.parse("1953-07-06"), credit: 2 },
    #     { before: Date.parse("1953-10-06"), credit: 1 }
    #   ]
    # end

    # def allocate_automatic_years
    #   auto_year = auto_years.find { |c| c[:before] > dob }
    #   @automatic_years = (auto_year ? auto_year[:credit] : 0 )   
    # end

    # def automatic_years
    #   @automatic_years
    # end
    
    def ni_start_date
      (dob + 19.years)
    end

    def ni_years_to_date
      today = Date.today
      years = today.year - ni_start_date.year
      years = ((ni_start_date.month > today.month) ? years - 1 : years)
      # NOTE: leave this code in case we need to work out by day
      # years = ((ni_start_date.month == today.month and ni_start_date.day > today.day) ? years - 1 : years)
      years
    end

    def available_years_sum(qual_years = @qualifying_years)
      (@available_years - qual_years)
    end

    def has_available_years?(qual_years = @qualifying_years)
      ! (available_years_sum(qual_years) < 0)
    end

    def enough_qualifying_years?(qual_years = @qualifying_years)
      qual_years > 29
    end

    def no_more_available_years?(qual_years = @qualifying_years)
      available_years_sum(qual_years) < 1
    end


    def years_can_be_entered(ay,max_num)
      (ay > max_num ? max_num : ay)
    end

  end
end
