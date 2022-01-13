require "httparty"
require "nokogiri"

module SmartAnswer::Calculators
  class CovidTravelAbroadCalculator
    attr_reader :transit_countries, :travelling_with_children
    attr_accessor :countries, :vaccination_status, :any_other_countries, :going_to_countries_within_10_days

    MAX_COUNTRIES = 99

    def initialize
      @countries = []
      @transit_countries = []
      @travelling_with_children = []
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
      going_to_countries_within_10_days == "yes"
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
      world_location.covid_status == "red"
    end

    def countries_with_content_headers_converted
      %w[denmark spain germany]
    end

    def foreign_travel_advice(slug)
      ForeignTravelAdvice.new(slug)
    end
  end

  class ForeignTravelAdvice
    @@root_url = "https://www.gov.uk/api/content/foreign-travel-advice"
    @@headers = { headers: { "Content-Type" => "application/json" } }

    attr_reader :slug, :content, :complete, :existing_sections

    def initialize(slug)
      @slug = slug
      @content = live_content
      @complete = live_content_complete?
      @existing_sections = live_existing_sections
    end

    def sections
      [
        "if-youre-transiting-through-#{@slug}",
        "if-youre-not-fully-vaccinated",
        "if-youre-fully-vaccinated",
        "children-and-young-people",
        "exemptions"
      ]
    end

    private

    def live_existing_sections
      existing_sections = []

      url = "#{@@root_url}/#{@slug}"
      response = HTTParty.get(url, @@headers)
      parsed_response = JSON.parse(response.body)

      parsed_response["details"]["parts"].each do |part|
        if part["slug"] == "entry-requirements"
          html = Nokogiri::HTML.parse(part["body"])
          sections.each do |id|
            section = html.at_css("[id='#{id}']")
            existing_sections << id if section.present?
          end
        end
      end
      existing_sections
    end

    def live_content_complete?
      @content.count == sections.count
    end

    def live_content
      content = {}
      url = "#{@@root_url}/#{@slug}"
      response = HTTParty.get(url, @@headers)
      parsed_response = JSON.parse(response.body)

      parsed_response["details"]["parts"].each do |part|
        if part["slug"] == "entry-requirements"
          entry_requirements = part
          html = Nokogiri::HTML.parse(entry_requirements["body"])
          sections.each do |id|
            node = html.at_css("[id='#{id}']")
            if node.present?
              content[node.text] = child_nodes(node)
            end
          end
        end
      end
      content
    end

    def child_nodes(node)
      current_node = node.next
      content = []
      loop do
        break if ["h1", "h2", "h3"].include?(current_node.name)
        content << current_node
        current_node = current_node.next
      end
      content
    end
  end
end
