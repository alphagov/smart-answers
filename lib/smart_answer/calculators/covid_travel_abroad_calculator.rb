module SmartAnswer::Calculators
  class CovidTravelAbroadCalculator
    MAX_COUNTRIES = 99

    attr_accessor :countries, :vaccine_status, :any_other_countries, :country_count

    def initialize
      @countries = []
      @country_count = 0
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
