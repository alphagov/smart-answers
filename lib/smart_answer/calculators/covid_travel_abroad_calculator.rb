module SmartAnswer::Calculators
  class CovidTravelAbroadCalculator
    MAX_COUNTRIES = 99

    attr_accessor :countries, :country_count, :vaccine_status

    def initialize
      @countries = []
    end

    def location(slug)
      WorldLocation.find(slug)
    end

    def travel_rules
      countries.map do |country|
        location(country)
      end
    end
  end
end
