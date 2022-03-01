require "httparty"

class TravelAdviceHeaderChecker
  attr_reader :country_slug

  def initialize(country_slug)
    @country_slug = country_slug
  end

  def has_content_headers?
    entry_requirements = entry_requirements_body_content
    return false if entry_requirements.blank?

    content_headers.each do |header|
      return false unless has_content_header?(entry_requirements, header)
    end

    true
  end

private

  def base_url
    "https://www.gov.uk/api/content/foreign-travel-advice"
  end

  def request_headers
    { "Content-Type" => "application/json" }
  end

  def content_headers
    [
      "all-travellers",
      "if-youre-transiting-through-#{country_slug}",
      "if-youre-not-fully-vaccinated",
      "if-youre-fully-vaccinated",
      "children-and-young-people",
      "exemptions",
    ]
  end

  def entry_requirements_body_content
    response = get_response("#{base_url}/#{country_slug}")
    return nil if response.blank? || response.body.blank?

    parsed_response = parse_response(response)
    return nil if parsed_response.blank?

    parsed_response.dig("details", "parts").each do |part|
      if part["slug"] == "entry-requirements"
        return Nokogiri::HTML.parse(part["body"])
      end
    end

    nil
  end

  def get_response(url)
    HTTParty.get(url, headers: request_headers)
  rescue HTTParty::Error
    nil
  rescue StandardError
    nil
  end

  def parse_response(response)
    JSON.parse(response.body)
  rescue JSON::ParserError
    nil
  end

  def has_content_header?(entry_requirements, header)
    node = entry_requirements.at_css("[id='#{header}']")
    node.present? && node.children.any?
  end
end
