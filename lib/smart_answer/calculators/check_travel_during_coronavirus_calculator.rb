module SmartAnswer::Calculators
  class CheckTravelDuringCoronavirusCalculator
    attr_reader :transit_countries, :travelling_with_children
    attr_accessor :countries, :vaccination_status, :any_other_countries, :going_to_countries_within_10_days, :travelling_with_young_people

    MAX_COUNTRIES = 99

    def initialize
      @countries = []
      @transit_countries = []
      @travelling_with_children = []
      @travelling_with_young_people = nil
    end

    def location(slug)
      WorldLocation.find(slug)
    end

    def country_locations
      countries.map do |country|
        location(country)
      end
    end

    def travelling_with_children=(travelling_with_children)
      travelling_with_children.split(",").each do |response|
        @travelling_with_children << response
      end
    end

    def travelling_with_young_people?
      travelling_with_young_people == "yes"
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

    def travelling_to_red_list_country?
      going_to_countries_within_10_days == "yes" ||
        countries.length == 1 && red_list_countries.include?(countries.first)
    end

    def travelling_to_ireland?
      countries.include?("ireland")
    end

    def single_journey?
      countries.size == 1
    end

    def red_list_country_titles
      red_list_countries.map do |country|
        location(country).title
      end
    end

    def red_list_countries
      countries.map { |country| country if red_list_country?(country) }.compact
    end

    def red_list_country?(slug)
      world_location = location(slug)
      world_location.on_red_list?
    end

    def countries_with_content_headers_converted
      %w[spain germany]
    end
  end
end
