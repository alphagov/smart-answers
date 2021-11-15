module SmartAnswer::Calculators
  class CovidTravelAbroadCalculator
    MAX_COUNTRIES = 99

    attr_accessor :countries, :country_count, :vaccine_status

    def initialize
      @countries = []
    end
  end
end
