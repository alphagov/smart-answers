module SmartAnswer::Calculators
  class CovidTravelAbroadCalculator
    MAX_COUNTRIES = 99

    attr_accessor :countries, :vaccination_status, :any_other_countries, :going_to_countries_within_10_days
    attr_reader :transit_countries, :travelling_with_children, :countries_within_10_days

    def initialize
      @countries = []
      @transit_countries = []
      @countries_within_10_days = []
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

    def countries_within_10_days=(countries_within_10_days)
      countries_within_10_days.split(",").each do |country|
        @countries_within_10_days << country
      end
    end

    def transit_country_options
      transit_country_options = {}
      countries.map do |country|
        transit_country_options[country] = country.humanize
      end

      transit_country_options
    end

    def travelling_to_red_list_country?
      @countries_within_10_days.intersection(red_list_countries).any?
    end

    def red_list_countries
      %w[
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
      ]
    end
  end
end
