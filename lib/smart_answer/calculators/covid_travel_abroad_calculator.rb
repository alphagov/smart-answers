module SmartAnswer::Calculators
  class CovidTravelAbroadCalculator
    attr_reader :transit_countries, :travelling_with_children
    attr_accessor :countries, :vaccination_status, :any_other_countries

    MAX_COUNTRIES = 99

    def initialize
      @countries = []
      @transit_countries = []
      @travelling_with_children = []
    end

    def location(slug)
      WorldLocation.find(slug)
    end

    def travelling_with_children=(travelling_with_children)
      travelling_with_children.split(",").each do |response|
        @travelling_with_children << response
      end
    end

    def transit_countries=(transit_countries)
      transit_countries.split(",").each do |country|
        @transit_countries << country
      end
    end

    def transit_country_options
      transit_country_options = {}
      countries.map do |country|
        transit_country_options[country] = location(country).title
      end

      transit_country_options
    end
  end
end
