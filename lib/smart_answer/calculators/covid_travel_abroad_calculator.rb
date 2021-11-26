module SmartAnswer::Calculators
  class CovidTravelAbroadCalculator
    MAX_COUNTRIES = 99

    attr_accessor :countries, :vaccination_status, :any_other_countries
    attr_reader :transit_countries, :travelling_with_children

    def initialize
      @countries = []
      @transit_countries = []
      @travelling_with_children = []
    end

    def location(slug)
      WorldLocation.find(slug)
    end

    def travel_rules
      countries.map do |country|
        location(country)
      end
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
        transit_country_options[country] = country.humanize
      end

      transit_country_options
    end

    def countries_with_content_headers_converted
      %w[
        spain
        usa
        france
        italy
        netherlands
        germany
        united-arab-emirates
        turkey
        ireland
        portugal
        poland
        belgium
        india
        austria
        switzerland
        mexico
        hungary
        thailand
        egypt
        australia
      ]
    end
  end
end
