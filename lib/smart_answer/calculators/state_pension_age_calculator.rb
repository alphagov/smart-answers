require "state_pension_date_query"

module SmartAnswer::Calculators
  class StatePensionAgeCalculator
    attr_reader :dob
    attr_accessor :gender

    def initialize(answers)
      @dob = answers[:dob]
      @gender = answers[:gender] ? answers[:gender].to_sym : nil
    end

    def state_pension_date(gender_for_calculation = gender)
      StatePensionDateQuery.state_pension_date(dob, gender_for_calculation)
    end

    def can_apply?
      Time.zone.today >= earliest_application_date
    end

    def pension_on_feb_29?(gender_for_calculation = gender)
      pension_date = state_pension_date(gender_for_calculation)
      pension_date.month == 2 && pension_date.day == 29
    end

    def state_pension_age(gender_for_calculation = gender)
      pension_date = state_pension_date(gender_for_calculation)
      pension_date -= 1 if birthday_on_feb_29? && !pension_on_feb_29?(gender_for_calculation)
      SmartAnswer::DateRange.new(begins_on: dob, ends_on: pension_date).friendly_time_diff
    end

    def birthday_on_feb_29?
      dob.month == 2 && dob.day == 29
    end

    def before_state_pension_date?(days: 0)
      Time.zone.today < state_pension_date - days.days
    end

    def bus_pass_qualification_date
      StatePensionDateQuery.bus_pass_qualification_date(dob)
    end

    def pension_credit_date
      StatePensionDateQuery.pension_credit_date(dob)
    end

    def before_pension_credit_date?(days: 0)
      Time.zone.today < pension_credit_date - days.days
    end

    def old_state_pension?
      state_pension_date < Date.parse("6 April 2016")
    end

    def over_16_years_old?
      dob < 16.years.ago
    end

    def how_to_claim_url
      old_state_pension? ? "/state-pension/how-to-claim" : "/new-state-pension/how-to-claim"
    end

    def pension_age_based_on_gender?
      dob < Date.parse("6 December 1953")
    end

    def non_binary?
      %i[prefer_not_to_say].include?(gender)
    end

  private

    def earliest_application_date
      state_pension_date - 2.months
    end
  end
end
