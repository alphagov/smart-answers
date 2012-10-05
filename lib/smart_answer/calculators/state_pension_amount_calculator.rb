require "data/state_pension_query"

module SmartAnswer::Calculators
  class StatePensionAmountCalculator
    include ActionView::Helpers::TextHelper

    attr_reader :gender, :dob, :automatic_years, :qualifying_years, :available_years
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
      # state_pension_year - current_year
      t = Date.today
      y = t.month > 4 ? t.year : t.year - 1
      state_pension_year - y
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

    def state_pension_year
      state_pension_date.year
    end

    def state_pension_date
      StatePensionQuery.find(dob, gender)
    end

    def state_pension_age
      # state_pension_date.year - dob.year
      spd = state_pension_date
      year = spd.year - dob.year
      puts "[#{dob.month}, #{spd.month}][#{dob}, #{spd}]"
      if (dob.month == spd.month) and (dob.day == spd.day)
        "#{pluralize(year, 'year')}"
      else
        year = (dob.month > 4 ? year : year-1 )
        month = ( dob.month > 4 ? dob.month-4 : 12+(dob.month-4) )
        day = ( dob.day >= 6 ? dob.day-6 : 30+(dob.day-6) )
        "#{pluralize(year, 'year')}, #{pluralize(month, 'month')} and #{pluralize(day, 'day')}"
      end
    end

    # def

    def before_state_pension_date?
      Date.today < state_pension_date
    end

    def under_20_years_old?
      dob > 20.years.ago
    end
    
    def three_year_credit_age?
      # three_year_band = credit_bands.last # FIXME: why is line this here?
      dob >= Date.parse('1959-04-06') and dob <= Date.parse('1992-04-05')
    end
    
    def credit_bands
      [
        { min: Date.parse('1957-04-06'), max: Date.parse('1958-04-05'), credit: 1, validate: 0 },
        { min: Date.parse('1993-04-06'), max: Date.parse('1994-04-05'), credit: 1, validate: 0 },
        { min: Date.parse('1958-04-06'), max: Date.parse('1959-04-05'), credit: 2, validate: 1 },
        { min: Date.parse('1992-04-06'), max: Date.parse('1993-04-05'), credit: 2, validate: 2 }
      ]
    end
    
    # FIXME: is this still needed?
    def qualifying_years_credit
      credit_band = credit_bands.find { |c| c[:min] <= dob and c[:max] >= dob }
      (credit_band ? credit_band[:credit] : 0)
    end

    def calc_qualifying_years_credit(entered_num=0)
      credit_band = credit_bands.find { |c| c[:min] <= dob and c[:max] >= dob }
      case credit_band[:validate]
      when 0
        entered_num > 0 ? 0 : 1
      when 1
        rval = (1..2).find{ |c| c + entered_num == 2 } 
        entered_num < 2 ? rval : 0
      else
        0
      end  
    end

    def auto_years
      [
        { before: Date.parse("1950-10-06"), credit: 5 },
        { before: Date.parse("1951-10-06"), credit: 4 },
        { before: Date.parse("1952-10-06"), credit: 3 },
        { before: Date.parse("1953-07-06"), credit: 2 },
        { before: Date.parse("1953-10-06"), credit: 1 }
      ]
    end

    def allocate_automatic_years
      auto_year = auto_years.find { |c| c[:before] > dob }
      @automatic_years = (auto_year ? auto_year[:credit] : 0 )   
    end

    def automatic_years
      @automatic_years
    end
    
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

    def not_qualifying_or_available_test?(qual_years = @qualifying_years)
      (qual_years > 29) or (available_years_sum(qual_years) < 1)
    end

    def years_can_be_entered(ay,max_num)
      (ay > max_num ? max_num : ay)
    end

  end
end
