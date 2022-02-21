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

    def summary_text_fields
      fields = []

      return fields if travelling_to_ireland? && single_journey?

      fields << if unvaccinated?
                  "not_vaxed"
                else
                  "fully_vaxed"
                end

      fields << "red_list" if travelling_to_red_list_country?

      if travelling_with_children?
        fields << travelling_with_children
      elsif travelling_with_young_people?
        fields << "young_person"
      end

      fields.flatten
    end

    def travelling_with_children=(travelling_with_children)
      travelling_with_children.split(",").each do |response|
        @travelling_with_children << response
      end
    end

    def travelling_with_children?
      travelling_with_children.any? && travelling_with_children != %w[none]
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

    def travelling_to_ukraine?
      countries.include?("ukraine")
    end

    def single_journey?
      countries.size == 1
    end

    def multiple_journey?
      countries.size > 1
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
      %w[
        burundi
        cambodia
        canada
        colombia
        croatia
        cyprus
        egypt
        germany
        guyana
        iceland
        india
        ireland
        italy
        latvia
        luxembourg
        malta
        nepal
        new-zealand
        norway
        poland
        portugal
        romania
        saudi-arabia
        singapore
        slovenia
        spain
        suriname
        switzerland
        thailand
        turkey
        usa
        venezuela
      ]
    end

    def fully_vaccinated?
      vaccination_status_by_name("fully_vaccinated") == vaccination_status
    end

    def part_of_vaccine_trial?
      vaccination_status_by_name("vaccine_trial") == vaccination_status
    end

    def exemption_from_vaccination?
      vaccination_status_by_name("exemption_from_vaccination") == vaccination_status
    end

    def unvaccinated?
      vaccination_status_by_name("unvaccinated") == vaccination_status
    end

    def vaccination_option_keys
      vaccination_statuses.map do |status|
        status["code"]
      end
    end

    def vaccination_options
      options = {}
      vaccination_statuses.each do |status|
        options[status["code"]] = status["option_text"]
      end

      options
    end

    def vaccination_status_by_name(name)
      vax_status = vaccination_statuses.select { |status| status["name"] == name }.first
      vax_status["code"]
    end

  private

    def vaccination_statuses
      @vaccination_statuses ||= YAML.load_file(Rails.root.join("config/smart_answers/check_travel_during_coronavirus/vaccination_status.yml"))
    end
  end
end
