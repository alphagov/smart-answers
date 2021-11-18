module SmartAnswer::Calculators
  class CovidTravelAbroadCalculator
    MAX_COUNTRIES = 99

    attr_accessor :countries, :vaccine_status, :any_other_countries, :country_count, :transit_countries

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

    def transit_country_options
      transit_country_options = {}
      countries.map do |country|
        transit_country_options[country] = country.humanize
      end

      transit_country_options
    end
  end
end
