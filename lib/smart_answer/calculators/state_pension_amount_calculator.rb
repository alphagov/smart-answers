require "data/state_pension_query"

module SmartAnswer::Calculators
  class StatePensionAmountCalculator
    include FriendlyTimeDiff

    attr_reader :gender, :dob, :qualifying_years, :available_years , :starting_credits, :pays_reduced_ni_rate
    attr_accessor :qualifying_years

    NEW_RULES_START_DATE = Date.parse('6 April 2016')

    def initialize(answers)
      @gender = answers[:gender].to_sym
      @dob = answers[:dob]
      @qualifying_years = answers.fetch(:qualifying_years, 0)
      @available_years = ni_years_to_date_from_dob
      @starting_credits = allocate_starting_credits
      @pays_reduced_ni_rate = answers[:pays_reduced_ni_rate]
    end

    def new_rules_and_less_than_10_ni? ni
      (ni < 10) && (state_pension_date >= NEW_RULES_START_DATE)
    end

    def automatic_ni_age_group?
      (Date.parse('1959-04-06')..Date.parse('1992-04-05')).cover?(dob)
    end

    def woman_born_in_married_stamp_era?
      (Date.parse('6 April 1953')..Date.parse('5 April 1961')).cover?(dob) && gender == :female
    end

    def current_weekly_rate
      @current_weekly_rate ||= SmartAnswer::Calculators::RatesQuery.new('state_pension').rates.weekly_rate
    end

    # Everyone needs 30 qualifying years in all cases - no need to worry about old rules
    def years_needed
      30
    end

    def years_to_pension
      pension_period_end_year(state_pension_date) - pension_period_end_year(Date.today)
    end

    def pension_loss
      current_weekly_rate - what_you_get
    end

    def what_you_get
      BigDecimal(what_you_get_raw.to_s).round(2).to_f
    end

    def what_you_get_raw
      if qualifying_years < years_needed
        (qualifying_years.to_f / years_needed.to_f * current_weekly_rate).round(10)
      else
        current_weekly_rate
      end
    end

    # what would you get if all remaining years to pension were qualifying years
    def what_you_would_get_if_not_full
      BigDecimal(what_you_would_get_if_not_full_raw.to_s).round(2).to_f
    end

    def what_you_would_get_if_not_full_raw
      if (qualifying_years + years_to_pension) < years_needed
        ((qualifying_years + years_to_pension) / years_needed.to_f * current_weekly_rate).round(10)
      else
        current_weekly_rate
      end
    end

    def pension_period_end_year(date)
      date < Date.civil(date.year, 4, 6) ? date.year - 1 : date.year
    end

    def state_pension_date(sp_gender = gender)
      StatePensionQuery.find(dob, sp_gender)
    end

    def state_pension_age
      if birthday_on_feb_29?
        friendly_time_diff(dob, state_pension_date - 1.day)
      else
        friendly_time_diff(dob, state_pension_date)
      end
    end

    def birthday_on_feb_29?
      dob.month == 2 and dob.day == 29
    end

    def before_state_pension_date?
      Date.today < state_pension_date
    end

    def within_four_months_one_day_from_state_pension?
      Date.today > state_pension_date.months_ago(4)
    end

    def under_20_years_old?
      dob > 20.years.ago
    end

    def credit_age?
      dob < Date.parse('1959-04-06') || dob > Date.parse('1992-04-05')
    end

    # these people always get 3 years of starting credits
    def three_year_credit_age?
      dob >= Date.parse('1959-04-06') and dob <= Date.parse('1992-04-05')
    end

    # these people always get at least 2 years of starting credits
    def at_least_two_year_credit_age?
      ( dob >= Date.parse('1958-04-06') and dob <= Date.parse('1959-04-05')) or
      ( dob >= Date.parse('1992-04-06') and dob <= Date.parse('1993-04-05'))
    end

    # these people always get at least 1 year of starting credits
    def at_least_one_year_credit_age?
      ( dob >= Date.parse('1957-04-06') and dob <= Date.parse('1958-04-05')) or
      ( dob >= Date.parse('1993-04-06') and dob <= Date.parse('1994-04-05'))
    end

     CREDIT_BANDS= [
                    { min: Date.parse('1957-04-06'), max: Date.parse('1958-04-05'), credit: 1, validate: 0 },
                    { min: Date.parse('1993-04-06'), max: Date.parse('1994-04-05'), credit: 1, validate: 0 },
                    { min: Date.parse('1958-04-06'), max: Date.parse('1959-04-05'), credit: 2, validate: 1 },
                    { min: Date.parse('1992-04-06'), max: Date.parse('1993-04-05'), credit: 2, validate: 1 },
                   ]

    # these people get different starting credits based on when they were born and what they answer to Q10
    def credit_band
      CREDIT_BANDS.find { |c| c[:min] <= dob and c[:max] >= dob }
    end

    def calc_qualifying_years_credit(entered_num = 0)
      return 0 unless credit_band && entered_num < 2
      if entered_num == 0
        credit_band[:validate] + 1
      else
        credit_band[:validate] == 1 ? 1 : 0
      end
    end

    ## this is done just to control flow
    def allocate_starting_credits
      if three_year_credit_age?
        @starting_credits = 3
      elsif at_least_two_year_credit_age?
        @starting_credits = 2
      elsif at_least_one_year_credit_age?
        @starting_credits = 1
      else
        @starting_credits = 0
      end
    end

    def ni_start_date
      (dob + 19.years)
    end

    def ni_years_to_date_from_dob
      today = Date.today
      years = today.year - ni_start_date.year
      if (today.month < dob.month) || ((today.month == dob.month) && (today.day < dob.day))
        years = years - 1
      end
      years
    end

    def available_years_sum(qual_years = @qualifying_years)
      (@available_years - qual_years)
    end

    def has_available_years?(qual_years = @qualifying_years)
      ! (available_years_sum(qual_years) < 0)
    end

    # used for flow optimisation so users who haven't entered enough qy but will get
    # 1,2 or 3 starting credit years are sent to last question or result
    def enough_qualifying_years_and_credits?(qual_years = @qualifying_years)
      (qual_years + @starting_credits) > 29
    end

    # are there any more years users can enter based on how many years there are between today and time they were 19?
    # used in flow to test if we should ask more questions
    def no_more_available_years?(qual_years = @qualifying_years)
      available_years_sum(qual_years) < 1
    end

    def years_can_be_entered(ay, max_num)
      (ay > max_num ? max_num : ay)
    end

    def qualifies_for_rre_entitlements?
      rre_start_date = Date.new(1953,4,6)
      rre_end_date = Date.new(1961,4,5)

      pays_reduced_ni_rate &&
        gender == :female &&
        qualifying_years.between?(10,29) &&
        dob.between?(rre_start_date, rre_end_date)
    end

    def over_55?
      dob <= 55.years.ago
    end
  end
end
