module SmartAnswer::Calculators
  class PaternityAdoptionPayCalculator < PaternityPayCalculator
    extend Forwardable

    def_delegators :@adoption_calculator,
      :adoption_qualifying_start, :a_notice_leave,
      :matched_week, :a_employment_start

    attr_reader :match_date

    def initialize(match_date)
      @match_date = match_date
      @adoption_calculator = AdoptionPayCalculator.new(match_date)

      super(match_date, 'paternity_adoption')
    end
  end
end
