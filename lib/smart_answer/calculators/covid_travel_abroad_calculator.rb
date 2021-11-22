module SmartAnswer::Calculators
  class CovidTravelAbroadCalculator
    MAX_COUNTRIES = 99

    attr_accessor :countries, :vaccination_status, :any_other_countries
    attr_reader :transit_countries

    def initialize
      @countries = []
      @transit_countries = []
    end

    def location(slug)
      WorldLocation.find(slug)
    end

    def travel_rules
      countries.map do |country|
        location(country)
      end
    end

    def country_count
      countries.count
    end

    def transit_countries=(transit_countries)
      transit_countries.split(",").each do |country|
        @transit_countries << country unless country == "none"
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
