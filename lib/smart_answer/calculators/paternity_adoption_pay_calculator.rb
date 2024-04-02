module SmartAnswer::Calculators
  class PaternityAdoptionPayCalculator < PaternityPayCalculator
    delegate :adoption_placement_date,
             :adoption_placement_date=,
             :adoption_qualifying_start,
             :a_notice_leave,
             :matched_week,
             :a_employment_start,
             to: :@adoption_calculator

    attr_reader :match_date

    def initialize(match_date)
      @match_date = match_date
      @adoption_calculator = AdoptionPayCalculator.new(match_date)

      super(match_date, "paternity_adoption")

      @matched_week = @expected_week
    end

    def paternity_deadline
      deadline_period = if adoption_placement_date < Date.new(2024, 4, 6)
                          55.days
                        else
                          364.days
                        end
      adoption_placement_date + deadline_period
    end

    def relevant_week
      @matched_week
    end

    def leave_must_be_taken_consecutively?
      adoption_placement_date <= Date.new(2024, 4, 5)
    end
  end
end
