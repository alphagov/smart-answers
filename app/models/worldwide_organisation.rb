class WorldwideOrganisation
  attr_reader :title, :web_url, :offices, :sponsors, :main_office, :other_offices

  def self.for_location(location_slug)
    organisations = Services.worldwide_api.organisations_for_world_location(location_slug).map do |response|
      new(response.to_hash) if response.present?
    end
    organisations.compact
  end

  def initialize(organisation)
    @organisation = organisation.with_indifferent_access
    @title = @organisation.fetch("title", "")
    @web_url = @organisation.fetch("web_url", "")
    @offices = @organisation.fetch("offices", {})
    @sponsors = @organisation.fetch("sponsors", {})
    @main_office = @offices.fetch("main", {})
    @other_offices = @offices.fetch("other", [])
  end

  def all_offices
    [@main_office] + @other_offices
  end

  def fco_sponsored?
    @sponsors.any? { |sponsor| sponsor["details"]["acronym"] == "FCO" }
  end

  def offices_with_service(service_title)
    return [] unless all_offices.any?

    embassies = all_offices.select do |office|
      office["services"].any? do |service|
        service["title"].include?(service_title)
      end
    end
    embassies << @main_office if embassies.empty?
    embassies
  end
end
